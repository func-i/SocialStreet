
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

    $('.user-group-item').live('click', function() {
        var $form = $(this).find('form').first();
        $('#user_group_holder').html($form.clone());

    });
})

