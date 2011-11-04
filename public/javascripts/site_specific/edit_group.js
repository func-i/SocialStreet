
$(function() { 

    cleanUpSelf = function(){
    }

    resizeSelf = function() {        
    }

    $('#edit_group_contact_address').autoResize();
    $('#edit_group_description').autoResize();

    $('#center_pane').removeClass('invisible');
    resizePageElements();

    $('#keyword').keydown(function(e){
        setTimeout(function() {
            $('#user_groups_search_form').submit();
        }, 250);
    });

    $('.user-group-item').live('click', function() {
        var $form = $(this).find('form').first();
        $newForm = $form.clone();
        $('#user_group_holder').html($newForm);
        $newForm.removeClass('hidden');
    });

    $('.user-group-item img').live('click', function() {
        $(this).closest('li').remove();
        $(this).closest('form').submit();
    });
})

