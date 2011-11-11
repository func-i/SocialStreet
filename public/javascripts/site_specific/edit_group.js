
$(function() { 

    cleanUpSelf = function(){
    }

    resizeSelf = function() {
       
    }

    $.each($('#group_form textarea'), function(i, ele) {
        console.log(countLines(ele));
        $(ele).attr('rows', countLines(ele) > 1 ? countLines(ele) + 1 : 1);
    });
    
    $('#edit_group_contact_address').autoResize();
    $('#edit_group_contact_name').autoResize();
    $('#edit_group_contact_email').autoResize();
    $('#edit_group_description').autoResize();

    $('#center_pane').removeClass('invisible');
    resizePageElements();

    $('#keyword').keydown(function(e){
        setTimeout(function() {
            $('#user_groups_search_form').submit();
        }, 250);
    });

    $('.form-btn').live('click', function() {
        $(this).closest('form').submit();
    });

    $('#add_new_group_member').click(function() {

        // Show the holder and the new user form
        $('#user_group_details').removeClass('hidden');
        $('#new_user_group_holder').removeClass('hidden');

        // Hide the update form if visible
        $('#user_group_holder').addClass('hidden');

        $.each($('#new_user_group input[type="text"]'), function(i, ele) {
            $(ele).val('');
        });

        resizePageElements();
    });

    $('.user-group-item').live('click', function() {
        var $form = $('.edit_user_group');
        var applied = $(this).find('.user-group-applied-field').val();
        var formPath = $(this).find('.user-group-form-path-field').val();
        var administrator = $(this).find('.user-group-administrator-field').val();
        
        // Update the form partial with the values for the specific user_group
        $form.find('[name="user_group\\[external_name\\]"]').val($(this).find('.user-group-name-field').val());
        $form.find('[name="user_group\\[external_email\\]"]').val($(this).find('.user-group-email-field').val());
        $form.find('[name="user_group\\[join_code\\]"]').val($(this).find('.user-group-code-field').val());
        $form.find('[name="user_group\\[applied\\]"]').val(applied);       

        // update the form action to this users update path
        $form.attr('action', formPath);
        $('#destroy_user_group_link').attr('href', formPath);

        // Show the holder and the update form
        $('#user_group_holder').removeClass('hidden');
        $('#user_group_details').removeClass('hidden');

        // Hide the new user form if visible
        $('#new_user_group_holder').addClass('hidden');

        if(applied == 'true') {
            // if it's a new applicant for the group, show the add member button and hide the delete button
            $('#destroy_user_group_link').addClass('hidden');
            $form.find('.form-btn').removeClass('hidden');
        }
        else{
            // if it's and existing member, hide the add member button and show the delete button
            $('#destroy_user_group_link').removeClass('hidden');
            $form.find('.form-btn').addClass('hidden');
        }
        
        if(administrator == 'true' || administrator == '') {
            $form.find('.group-member-administrator-holder').addClass('hidden');
            $('#destroy_user_group_link').addClass('hidden');
            $form.find('[name="user_group\\[administrator\\]"][value="true"]').attr('checked', 'checked');
        }
        else{
            $form.find('[name="user_group\\[administrator\\]"][value="false"]').attr('checked', 'checked');
        }
        
        resizePageElements();        
    });

    $('.edit_user_group .form-btn').click(function() {
        var $form = $(this).closest('form');

        // when hitting the add member button for a applicant to the group, update their applied = false
        $form.find('[name="user_group\\[applied\\]"]').val('false');
    });

    $('#group_admin_false').live('click', function(){
        if($('#add_member_btn_link').hasClass('hidden'))
            $('#destroy_user_group_link').removeClass('hidden');
    });
    $('#group_admin_true').live('click', function(){
        $('#destroy_user_group_link').addClass('hidden');
    });    

    $('#add_member_btn_link').live('click', function(){
        $('#group_member_applied').val('false');
        $('#user_group_form').submit();        
    });

    $('#group_private_li').live('click', function(){
        $('#group_permission span').text('Private');
        $('#group_public_li').removeClass('selected');
        $('#group_private_li').addClass('selected');
        $('#join_code_description_holder').removeClass('hidden');
        $('.group-member-join-code-holder').removeClass('hidden');

        resizePageElements();
    });

    $('#group_public_li').live('click', function(){
        $('#group_permission span').text('Public');
        $('#group_public_li').addClass('selected');
        $('#group_private_li').removeClass('selected');
        $('#join_code_description_holder').addClass('hidden');
        $('.group-member-join-code-holder').addClass('hidden');

        $('#edit_group_join_code').val('');
        $('#edit_group_join_code').trigger('change');

        resizePageElements();
    });

});

function countLines(area)
{
    // trim trailing return char if exists
    var text = area.value;
    var rows = Math.ceil(text.length /area.cols);
    return rows
}

