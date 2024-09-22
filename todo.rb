require "sinatra"
require "sinatra/reloader" if development?
require "sinatra/content_for"
require "tilt/erubis"

configure do
    enable :sessions
    set :session_secret, SecureRandom.hex(32)
end

before do
    session[:lists] ||= []
end

get "/" do
    redirect "/lists"
end

#view all the lists 
get "/lists" do
    @lists = session[:lists]
    erb :lists, layout: :layout
end

#render the new list form
get "/lists/new" do
    erb :new_list, layout: :layout
end

#return an error message if the name is invalid. Return nil if valid. 
def error_for_list_name(name)
    if !(1..100).cover? name.size
        "List name must be between 1 and 100 chars."
    elsif session[:lists].any? {|list| list[:name] == name }
        "This list name is already taken."
    end
end

#return an error message if the list item is invalid. Return nil if valid. 
def error_for_todo(name)
    if !(1..100).cover? name.size
        "Todo item must be between 1 and 100 chars."
    end
end

#create a new list
post "/lists" do
    list_name = params[:list_name].strip
    
    if  error = error_for_list_name(list_name)
        session[:error] = error
        erb :new_list, layout: :layout
    else
        session[:lists] << {name: list_name, todos: []}
        session[:success] = "The list has been created."
        redirect "/lists"
    end
    
end

get "/lists/:id" do
    @list_id = params[:id].to_i
    @list = session[:lists][@list_id]
    erb :list, layout: :layout
end

#edit an existing list
get "/lists/:id/edit" do
    id = params[:id].to_i
    @list = session[:lists][id]
    erb :edit_list, layout: :layout
end

#update an existing todo list
post "/lists/:id" do
    list_name = params[:list_name].strip
    id = params[:id].to_i
    @list = session[:lists][id]
    
    if  error = error_for_list_name(list_name)
        session[:error] = error
        erb :edit_list, layout: :layout
    else
        @list[:name] = list_name
        session[:success] = "The list has been updated."
        redirect "/lists/#{id}"
    end
end

#delete a list
post "/lists/:id/destroy" do
    id = params[:id].to_i
    session[:lists].delete_at(id)
    session[:success] = "The list has been deleted."
    redirect "/lists"
end

#add a new todo to a list
post "/lists/:list_id/todos" do
    @list_id = params[:list_id].to_i
    @list = session[:lists][@list_id]
    text = params[:todo].strip
    
    error = error_for_todo(text)
    if error
       session[:error] = error
       erb :list, layout: :layout
    else
        @list[:todos] << {name: text, completed: false}
        session[:success] = "The todo was added to the list."
        redirect "/lists/#{@list_id}"
    end
end

#delete a todo from a list
post "/lists/:list_id/todos/:id/destroy" do
    @list_id = params[:list_id].to_i
    @list = session[:lists][@list_id]
    
    todo_id = params[:id].to_i
    @list[:todos].delete_at todo_id
    session[:success] = "The todo has been deleted."
    redirect "/lists/#{:list_id}"
end

#update the status of a todo
post "/lists/:list_id/todos/:id" do
    @list_id = params[:list_id].to_i
    @list = session[:lists][@list_id]
    
    todo_id = params[:id].to_i
    is_completed = params[:completed] == "true"
    @list[:todos][todo_id][:completed] = is_completed
    session[:success] = "The todo has been updated."
    redirect "/lists/#{:list_id}"
end