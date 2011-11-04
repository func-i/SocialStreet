
$(function() { 

    cleanUpSelf = function(){
    }

    resizeSelf = function() {        
    }

    $('#center_pane').removeClass('invisible');
    resizePageElements();

    $('#keyword').keydown(function(e){
        setTimeout(function() {
            $('#user_groups_search_form').submit();
        }, 250);
    });

    $('#edit_group_contact_address').autoResize();
    $('#edit_group_description').autoResize();
})

