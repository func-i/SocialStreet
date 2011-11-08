
$(function() { 

    cleanUpSelf = function(){
    }

    resizeSelf = function() {
       
    }

    $.each($('#group_form textarea'), function(i, ele) {
        $(ele).attr('rows', countLines(ele) > 1 ? countLines(ele) + 1 : 1);
    });
    
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
        var $holder = $('#user_group_holder');        
        $holder.html('');
        $.each($(this).find('form'), function(i, ele) {            
            $holder.append($(ele).clone());
        });
    });

    $('#user_group_holder .delete-img').live('click', function() {
        if(confirm('Are you sure you want to remove this user from the group?')) {            
            $(this).closest('form').submit();

            var group_id = $(this).data('user-group');
            var $userGroupLi = $('*[data-li-user-group=' + group_id + ']').first();
            
            $userGroupLi.fadeOut(2500, function() {
                $(this).remove();
            });
        }
    });

    $('.update-event-img').live('click', function() {
        $(this).closest('form').submit();
    });

    $('#group_private_li').live('click', function(){
        $('#group_permission span').text('Private');
        $('#group_public_li').removeClass('selected');
        $('#group_private_li').addClass('selected');
        $('#join_code_description_holder').removeClass('hidden');
    });

    $('#group_public_li').live('click', function(){
        $('#group_permission span').text('Public');
        $('#group_public_li').addClass('selected');
        $('#group_private_li').removeClass('selected');
        $('#join_code_description_holder').addClass('hidden');
        $('#edit_group_join_code').val('');
        $('#edit_group_join_code').trigger('change');
    });

})

function countLines(area)
{
    // trim trailing return char if exists
    var text = area.value;
    var rows = Math.ceil(text.length /area.cols);
    return rows
}

