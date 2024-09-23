$(function() {

    $("form.delete").submit(function(event) {
        event.preventDefault();
        event.stopPropagation();
        
        var ok = confirm("Are you sure homie? Dis be forever")
        if (ok) {
            this.submit();
        }
    
    });
    
});
