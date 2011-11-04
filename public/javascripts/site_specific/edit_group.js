
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
        $newForm = $form.clone();
        $('#user_group_holder').html($newForm);
        $newForm.removeClass('hidden');
    });

    $('.user-group-item img').live('click', function() {
        $(this).closest('li').remove();
        $(this).closest('form').submit();
    });
})

