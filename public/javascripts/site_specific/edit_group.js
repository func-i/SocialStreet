
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
        prepareMemberDetails(
            $(this).find('.user-group-name-field').val(),
            $(this).find('.user-group-email-field').val(),
            $(this).find('.user-group-code-field').val(),
            $(this).find('.user-group-administrator-field').val(),
            $(this).find('.user-group-applied-field').val(),
            false,
            $(this).find('.user-group-form-path-field').val()
            );
    });

    $('#group_admin_false').live('click', function(){
        $('#destroy_user_group_link').removeClass('hidden');
    });
    $('#group_admin_true').live('click', function(){
        $('#destroy_user_group_link').addClass('hidden');
    });

    $('#add_new_group_member').live('click', function(){
        prepareMemberDetails(
            '',
            '',
            '',
            'false',
            'false',
            true,
            $('#new_member_form_action').val()
            );
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
        $('#group_member_join_code_holder').removeClass('hidden');
    });

    $('#group_public_li').live('click', function(){
        $('#group_permission span').text('Public');
        $('#group_public_li').addClass('selected');
        $('#group_private_li').removeClass('selected');
        $('#join_code_description_holder').addClass('hidden');
        $('#group_member_join_code_holder').addClass('hidden');

        $('#edit_group_join_code').val('');
        $('#edit_group_join_code').trigger('change');
    });

});

function prepareMemberDetails(name, email, joinCode, administrator, applied, newMember, formAction){
    $('#group_member_external_name').val(name);
    $('#group_member_external_email').val(email);
    $('#group_member_join_code').val(joinCode);

    if(administrator == 'false'){
        $('#group_admin_false').attr('checked', true);
        $('#destroy_user_group_link').removeClass('hidden');
    }
    else{
        $('#group_admin_true').attr('checked', true);
        $('#destroy_user_group_link').addClass('hidden');
    }

    if(null == administrator || 0 >= administrator.length){
        $('#group_member_administrator_holder').addClass('hidden');
    }
    else{
        $('#group_member_administrator_holder').removeClass('hidden');
    }

    if(applied == 'true'){
        $('#destroy_user_group_link').addClass('hidden');
        $('#add_member_btn_link').removeClass('hidden');
        $('#group_member_application_text').removeClass('hidden');
        $('#group_details_application_text').addClass('hidden');
        $('#group_member_applied').val('true');
    }
    else{
        $('#add_member_btn_link').addClass('hidden');
        $('#group_member_application_text').addClass('hidden');
        $('#group_details_application_text').removeClass('hidden');
        $('#group_member_applied').val('false');
    }

    if(newMember){
        $('#destroy_user_group_link').addClass('hidden');
        $('#add_member_btn_link').removeClass('hidden');
        $('#user_group_form').attr('method', 'post');
        $('#user_group_form').find('[name=_method]').remove();
    }
    else{
        $('#destroy_user_group_link').removeClass('hidden');
        $('#add_member_btn_link').addClass('hidden');
        $('#user_group_form').append('<input name=​"_method" type=​"hidden" value=​"put">​');
    }

    $('#user_group_form').attr('action', formAction);
    $('#destroy_user_group_link').attr('href', formAction);

    $("#user_group_details").removeClass('hidden');
}

function countLines(area)
{
    // trim trailing return char if exists
    var text = area.value;
    var rows = Math.ceil(text.length /area.cols);
    return rows
}

