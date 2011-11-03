var isOpen = false;
var eventTypeTimer = null;

$(function(){

    //User clicks on doc away from event type or text field, hide
    $(document).bind("click", function(e){
        if(isOpen &&
            isOnSettings() &&
            $(e.target).closest('.group-type').length < 1 &&
            $(e.target).closest('#group_permission_holder').length < 1 &&
            $(e.target).closest('#add_group_button').length < 1)
            {
            hideGroups();
        }
        else if(isOpen &&
            isOnCreateSummary() &&
            $(e.target).closest('.group-type').length < 1 &&
            $(e.target).closest('#add_group_link').length < 1)
            {
            hideGroups();
        }
        else if(isOpen &&
            isOnShowEvent() &&
            $(e.target).closest('.group-type').length < 1 &&
            $(e.target).closest('#group_permission_holder').length < 1 &&
            $(e.target).closest('#join_btn_holder').length < 1)
            {
            hideGroups();
        }        

    });

    //  Close button on group permissions popup
    $('#close_group_permissions_btn').live('click', function() {
        hideGroupPermissionHolder();
    });


    //User clicked on an event type in the holder
    $('.group-type').live('click', function(){
        groupTypeClicked(this);

        reset();
    });

    //User clicks on a tag
    /*    $('.remove-keyword-tag').live('click', function(){
        removeKeyword(this);
    });*/

    //User submits group code
    $('#group_permission_next_arrow').live('click', function(){
        var $groupHolder = $(this).closest('#group_permission_holder');
        var groupID = $groupHolder.find('#group_permission_id').val();
        var groupCode = $groupHolder.find('#group_permission_text_field').val();

        addGroup(groupID, groupCode);
    });

    $('#group_permission_error').live('click', function(){
        $('#group_permission_error').addClass('hidden');
        $('#group_permission_applied').removeClass('hidden');

        var groupID = $groupHolder.find('#group_permission_id').val();
        var groupCode = $groupHolder.find('#group_permission_text_field').val();

        $.getScript('/groups/apply_for_membership?' +
            'group_id=' + groupID +
            '&group_code=' + groupCode
            );

    });
});

function addGroup(groupID, groupCode){
    $.getScript('/profiles/add_group?' +
        'group_id=' + groupID +
        '&group_code=' + groupCode
        );
}

function showGroupPermissionHolder(){
    $('#show_attendees_title').addClass('hidden');
    $('#show_attendees_holder').addClass('hidden');
    $('#group_permission_holder').removeClass('hidden');
    $('#center_pane').removeClass('invisible');
    resizePageElements();

    isOpen = true;
}
function hideGroupPermissionHolder(){
    $('#group_permission_holder').addClass('hidden');
    $('#center_pane').addClass('invisible');
    $('#group_permission_error').addClass('hidden');
    $('#group_permission_applied').addClass('hidden');

    $('#show_attendees_title').removeClass('hidden');
    $('#show_attendees_holder').removeClass('hidden');
    resizePageElements();

    isOpen = false;
}
function showGroups(){
    $('#groups_holder').removeClass('hidden');
    $('#center_pane').removeClass('invisible');
    resizePageElements();

    isOpen = true;
}
function hideGroups(){
    $('#groups_holder').addClass('hidden');
    $('#center_pane').addClass('invisible');
    hideGroupPermissionHolder();

    isOpen = false;
}

function reset(){
    resizePageElements();
}

function groupTypeClicked(groupType, refreshResults){
    var $groupType = $(groupType);
    var groupName = $.trim($groupType.find('.group-type-name').text());
    var groupIconClass = 'event-type-' + $groupType.find('.group-type-image').data('event-type') + (isOnExplore() ? '-small-sprite' : '-medium-sprite');

    if(!groupAlreadyExists(groupName)){
        if(isOnCreateSummary()){
            var groupID = $groupType.find('.group-id').val();
            addGroupToSummary(groupName, groupID);

            createGroupInputs(groupID, 2);

            hideGroups();
        }
        else if(isOnSettings()){
            if($groupType.find('#group_required').val() == 'false'){
                addGroup($groupType.find('#group_id').val(), null);
                hideGroups();
                addGroupToHolder(groupName, groupIconClass);
            }
            else{
                $('#group_permission_id').val($groupType.find('#group_id').val());
                $('.join-code-text').text($groupType.find('#join_code_description').val());
                $('#group_permission_name').val(groupName);
                $('#group_permission_icon_class').val(groupIconClass);
                $('#group_permission_icon').addClass(groupIconClass);

                hideGroups();
                showGroupPermissionHolder();
            }
        }
        else if(isOnShowEvent()){
            if($groupType.find('#group_required').val() == 'false'){
                addGroup($groupType.find('#group_id').val(), null);
                hideGroups();

                rsvpToEvent();
            }
            else{
                $('#group_permission_id').val($groupType.find('#group_id').val());
                $('.join-code-text').text($groupType.find('#join_code_description').val());
                $('#group_permission_name').val(groupName);
                $('#group_permission_icon_class').val(groupIconClass);
                $('#group_permission_icon').addClass(groupIconClass);

                hideGroups();
                showGroupPermissionHolder();
            }
        }
    }
}

function rsvpToEvent(){
    ajaxLink($('.join-event-btn')[0]);
}

function addGroupToSummary(groupName, groupID){
    var $newGroup = $($('#summary_who_group_stamp').clone());
    $newGroup[0].id = "";

    $newGroup.find('.group-permission-name').text(groupName);
    $newGroup.find('#group_id').val(groupID);
    $newGroup.removeClass('hidden');

    $('#summary_who_group_list').append($newGroup);

    var $addGroupLink = $('#add_group_link_li').remove();
    $('#summary_who_group_list').append($addGroupLink);

    return $newGroup;
}

function addGroupToHolder(groupName, groupIconClass){
    var $newGroup = $($('#group_tag_stamp').clone());
    $newGroup[0].id = "";
    $newGroup.find('.group-tag-name').text(groupName);
    $newGroup.find('.group-tag-icon').addClass(groupIconClass);
    $('#group_tag_list').append($newGroup);
    $newGroup.removeClass('hidden');
}

function groupAlreadyExists(groupName){
    var rtn = false;
    var trimmedGroupName = $.trim(groupName).toLowerCase();
    $.each($('.group-tag-name'), function(index, name){
        if($.trim($(name).text()).toLowerCase() == trimmedGroupName){
            rtn = true;
            return;
        }
    });

    return rtn;
}

function isOnCreateSummary(){
    return $('#on_create_summary').val() && $('#on_create_summary').val().length > 0;
}
function isOnSettings(){
    return $('#on_settings').length > 0;
}
function isOnShowEvent(){
    return $('#on_show_event').length > 0;
}


