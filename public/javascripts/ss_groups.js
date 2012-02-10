var isGroupOpen = false;
var eventTypeTimer = null;

$(function(){

    //User clicks on doc away from event type or text field, hide
    $(document).bind("click", function(e){
        if(isGroupOpen &&
            isOnSettings() &&
            $(e.target).closest('.group-type').length < 1 &&
            $(e.target).closest('.group-permission-holder').length < 1 &&
            $(e.target).closest('#add_group_button').length < 1)
            {
            hideGroups();
        }
        else if(isGroupOpen &&
            isOnCreateSummary() &&
            $(e.target).closest('.group-type').length < 1 &&
            $(e.target).closest('#add_group_link').length < 1)
            {
            hideGroups();
        }
        else if(isGroupOpen &&
            isOnShowEvent() &&
            $(e.target).closest('.group-type').length < 1 &&
            $(e.target).closest('.group-permission-holder').length < 1 &&
            $(e.target).closest('#join_btn_holder').length < 1)
            {
            hideGroups();
        }
        else if(isGroupOpen &&
            isOnShowGroup() &&
            $(e.target).closest('.group-permission-holder').length < 1 &&
            $(e.target).closest('#join_group_btn').length < 1)
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

        resetGroups();
    });

    //User clicks on a tag
    /*    $('.remove-keyword-tag').live('click', function(){
        removeKeyword(this);
    });*/

    //User submits group code
    $('.group-permission-holder .next-arrow').live('click', function(){
        var $groupHolder = $(this).closest('.group-permission-holder');
        var groupID = $groupHolder.find('#group_permission_id').val();
        var groupCode = $groupHolder.find('.permission-code-field').val();

        addGroup(groupID, groupCode);
    });

    $('.permission-error').live('click', function(){
        $('.permission-error').addClass('hidden');
        $('.permission-applied').removeClass('hidden');

        var $groupHolder = $(this).closest('.group-permission-holder');
        var groupID = $groupHolder.find('#group_permission_id').val();
        var groupCode = $groupHolder.find('.permission-code-field').val();

        $.getScript('/groups/apply_for_membership?' +
            'group_id=' + groupID +
            '&group_code=' + groupCode
            );

    });

    $('#join_group_btn').live('click', function(){
        $this = $(this);
        if(true == $this.data('permission-required')){
            setValuesOnPermissionCodeOverlay(
                $this.siblings('#group_btn_id').val(),
                $this.siblings('#group_btn_join_code_description').val(),
                $this.siblings('#group_btn_name').val(),
                $this.siblings('#group_btn_icon_class').val()
                )

            showGroupPermissionHolder();
        }
        else{
            addGroup($this.data('group-id'), null);
        }
    });
});

function addGroup(groupID, groupCode){
    $.getScript('/profiles/add_group?' +
        'group_id=' + groupID +
        '&group_code=' + groupCode
        );
}

function showGroupPermissionHolder(){
    $('.group-permission-holder').removeClass('hidden');
    openCenterPane();
    resizePageElements();

    isGroupOpen = true;
}
function hideGroupPermissionHolder(show_permission){
    $('.group-permission-holder').addClass('hidden');
    $('.permission-error').addClass('hidden');
    $('.permission-applied').addClass('hidden');
    closeCenterPane();

    resizePageElements();

    isGroupOpen = false;
}
function showGroups(){
    $('#groups_holder').removeClass('hidden');
    openCenterPane();
    resizePageElements();

    isGroupOpen = true;
}
function hideGroups(show_permission){
    if(undefined == show_permission)
        show_permission = false;
    
    if(isOnSettings() && false == show_permission){
        $('#center_profile').removeClass('hidden');
    }

    $('#groups_holder').addClass('hidden');
    closeCenterPane();
    hideGroupPermissionHolder(show_permission);

    isGroupOpen = false;
}

function resetGroups(){
    resizePageElements();
}

function groupTypeClicked(groupType, refreshResults){
    var $groupType = $(groupType);
    var groupName = $.trim($groupType.find('.group-type-name').text());
    var groupIconClass = 'event-type-' + $groupType.find('.group-type-image').data('event-type') + '-medium-sprite';

    if(!groupAlreadyExists(groupName)){
        if(isOnCreateSummary()){
            var groupID = $groupType.find('.group-id').val();
            addGroupToSummary(groupName, groupID);

            createGroupInputs(groupID, 2);

            hideGroups();
        }
        else if(isOnSettings()){
            if($groupType.find('#group_required').val() == 'false'){
                var $groupID = $groupType.find('#group_id').val();
                addGroup($groupID, null);
                hideGroups();
                addGroupToHolder(groupName, groupIconClass, "/groups/" + $groupID);
            }
            else{
                setValuesOnPermissionCodeOverlay($groupType.find('#group_id').val(), $groupType.find('#join_code_description').val(), groupName, groupIconClass)
                
                hideGroups(true);
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
                setValuesOnPermissionCodeOverlay($groupType.find('#group_id').val(), $groupType.find('#join_code_description').val(), groupName, groupIconClass)

                hideGroups();
                showGroupPermissionHolder();
            }
        }
    }
}

function setValuesOnPermissionCodeOverlay(groupID, joinCodeDescription, groupName, groupIconClass){
    $('#group_permission_id').val(groupID);
    $('.join-code-text').text(joinCodeDescription);
    $('#group_permission_name').val(groupName);
    $('#group_permission_icon_class').val(groupIconClass);
    $('.group-permission-holder .group-type-image').addClass(groupIconClass);
}

function rsvpToEvent(){
    $('.join-event-btn').trigger('click');
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

function addGroupToHolder(groupName, groupIconClass, groupHref){
    if($('.group-tag').length == 1){//Stamp always exists
        $('#no_groups_text').addClass('hidden');
    }

    var $scrollpane = $('#group_tag_list').closest('.scroll-pane');
    $scrollpane.data('jsp').destroy();
    $scrollpane.css('height','auto');

    var $newGroup = $($('#group_tag_stamp').clone());
    $newGroup[0].id = "";
    $newGroup.find('.group-tag-name').text(groupName);
    $newGroup.find('.group-tag-icon').addClass(groupIconClass);

    if($newGroup.hasClass('nav-link')){
        $newGroup.data('ajax-href', groupHref);
    }

    $('#group_tag_list').append($newGroup);
    $newGroup.removeClass('hidden');

    initScrollPane($scrollpane);
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
function isOnShowGroup(){
    return $('#on_show_group').length > 0;
}


