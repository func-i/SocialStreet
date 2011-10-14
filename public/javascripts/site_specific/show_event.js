var showMarker = null;
var refreshInviteListTimer = null;
var invitationView = false;
var invitationCounter = 0;
var invitationPageless = null;
var eventImageInterval = null;

$(function(){

    cleanUpSelf = function(){
        if(showMarker){
            showMarker.infoBubble_.close();
            delete showMarker.infoBubble_;
            showMarker = null;
        }

        if(eventImageInterval){
            clearTimeout(eventImageInterval);
        }
    }

    resizeSelf = function(){
        resizeCenterPaneContent();
        resizeDate(); // Resize the date to wrap when the title is too long
    }

    resizePageElements();
        
    setupShowEventPage();

    $('#event_wall_text_field').keyup(function(e){
        if (!e.shiftKey && e.keyCode == 13) {
            submit_event_wall_comment();
            e.stopPropagation();
            return false;
        }
    });
    $('#event_wall_text_field').autoResize({
        extraSpace: 5
    });

    $('.event-wall-comment').live('mouseenter', function(){
        $(this).find('.comment-delete').removeClass('hidden');
    });
    $('.event-wall-comment').live('mouseleave', function(){
        $(this).find('.comment-delete').addClass('hidden');
    });
    $('.comment-delete').live('click', function(){
        removeComment($(this).closest('.event-wall-comment'));
    });

    $('.invite-friends-btn').live('click', function(){
        showInvitationView();
    });
    $('#invite_user_text_field').keydown(function(e){
        if(e.keyCode == 13){
            addEmail(e.target.value);
            $(this).val('');
            refreshInviteUserList('');            
            
        }
        else if($('#user_search_value').val() != e.target.value){
            refreshInviteUserList(e.target.value);
            $('#user_search_value').val(e.target.value);           
        }

        var api = $('#user_holder_for_invitation').data('jsp');
        api.scrollTo(0,0);
    });
    $('.user-for-invitation').live('click', function(){
        add_invitation(this);
    });
    $('.already-invited-user').live('click', function(){
        remove_invitation(this);
    });
    $('.already-invited-email').live('click', function(){
        remove_invitation(this);
    });
    $('.submit-invitation-next-arrow').click(function(){
        $('#invite_form').submit();
        showEventView();

        initializeScrollPanes();
    });
    
    $('#edit_event_title_link').click(function(){
        $('#show_event_title_text').addClass('hidden');
        $('#edit_event_title_link').addClass('hidden');

        var $textField = $('#edit_event_title_field');

        $textField.removeClass('hidden');
        $textField.focus();
    });
    $('#edit_event_title_field').keydown(function(e){
        if(e.keyCode == 13){
            $('#edit_event_title_field').blur();//causes submit
        }
    });

    $('#edit_event_title_field').blur(function() {
        submitEventTitle();
    });
    
    function submitEventTitle() {
        if($('#edit_event_title_field').val().length > 0){
            $('#show_event_title_text').text($('#edit_event_title_field').val());
            $('#event_edit_form').submit();
            resizeDate();
        }
        $('#show_event_title_text').removeClass('hidden');
        $('#edit_event_title_link').removeClass('hidden');
        $('#edit_event_title_field').addClass('hidden');
        
    }

    $('#edit_event_description_link').click(function(){
        $('#show_event_description_text').addClass('hidden');
        $('#edit_event_description_link').addClass('hidden');
        $('#edit_event_description_field').removeClass('hidden');
        $('#edit_event_description_field').autoResize();
        if($('#show_event_description_holder').data('jsp'))
            $('#show_event_description_holder').data('jsp').destroy();
        $('#show_event_description_holder').height('auto');
        $('#show_event_description_holder').css('max-height', 'none');
    });

    $('#edit_event_description_field').keydown(function(e){
        if(!e.shiftKey && e.keyCode == 13){
            $('#show_event_description_text').text(e.target.value);
            $('#show_event_description_text').removeClass('hidden');
            $('#edit_event_description_link').removeClass('hidden');
            $('#edit_event_description_field').addClass('hidden');
            $('#event_edit_form').submit();

            if(e.target.value.length > 0){
                $('#edit_event_description_link').text('Edit description...');
            }
            else{
                $('#edit_event_description_link').text('Add description...');
            }
        }
    });
});

function resizeCenterPaneContent(){
    if($('#user_holder_for_invitation').length > 0){
        var centerPaneBottom = $('#center_pane').offset().top + $('#center_pane').height();

        var scrollerTop = $('#user_holder_for_invitation').offset().top;
        $('#user_holder_for_invitation').height(centerPaneBottom - scrollerTop);
    }
}

function removeComment(comment){
    comment.hide();
    if($('#event_wall').data('jsp'))
        $('#event_wall').data('jsp').destroy();
    $('#event_wall').height('auto');

    capHeightContainer();

    initScrollPane($('#event_wall'));
}

function setupShowEventPage(){
    
    var lat = $('#lat').val();
    var lng = $('#lng').val();
    var loc_text = $('#location_text').val();
    var address = $('#address').val();

    map.panTo(new google.maps.LatLng(lat, lng));
    map.setZoom(15);

    var xOffset = $('#location-map').width() / 5;
    var yOffset = $('#location-map').height() / 5;
    map.panBy(-xOffset, -yOffset);

    google.maps.event.addListenerOnce(map, 'idle', function() {
        createShowMarker(lat, lng, address, loc_text);
    });
    
    initializeScrollPanes();

    invitationView = $('#invite_view_bool').val();
    if(invitationView){
        showInvitationView();
    }
    else{
        showEventView();
    }

    getInvitationUsers();//Load invitation users on delay

    if($('.show-event-image').length > 1){
        eventImageInterval = setInterval(function(){
            $('.show-event-image').addClass('hidden');
            $('.show-event-image').eq(Math.floor(Math.random() * $('.show-event-image').length)).removeClass('hidden');
        }, 5000);
    }
}

function showInvitationView(){
    $('.event-invitation-view').removeClass('hidden');
    $('#center_pane').removeClass('invisible');
    $('.event-details-view').addClass('hidden');

    hideMarkers();

    resizeLayout();
}

function showEventView(){
    $('.event-invitation-view').addClass('hidden');
    $('#center_pane').addClass('invisible');
    $('.event-details-view').removeClass('hidden');

    showMarkers();

    resizeLayout();

}

function getInvitationUsers(){
    setTimeout(function() {
        $.getScript('/invitations/load_connections');
    }, 500);
}

function getInvitationPageless(){
    return invitationPageless;
}

function makeInvitationPageless(totalPages){
    invitationPageless = new Pageless({
        container: '#user_holder_for_invitation',
        totalPages: totalPages,
        currentPage: 1,
        parameterFunction: invitationPagelessFunction,
        url: '/invitations/load_connections'
    });
    invitationPageless.start();
}
function invitationPagelessFunction(){
    return $('#invite_user_form').serializeObject();
}


function add_invitation(that){
    if(!does_invitation_already_exist(that.id)){
        //Check if user already added to list
        //Add to list
        var userClone = $('#invited_user_clone').clone();
        userClone[0].id = invitationCounter;
        userClone.children('.already-invited-user-image').html($(that).find('img').clone());
        userClone.removeClass('hidden');
        $('#invited_user_list').append(userClone);

        $('#invite_form').append(
            '<input type="hidden" name="invited_users[]" value="' + that.id + '" id="' + invitationCounter + '"/>'
            );

        invitationCounter++;
        $('#invitation_list').removeClass('invisible');
        $('#invite_friend_pretext').addClass('hidden');

        $('#invite_friends_btn').removeClass('hidden');
        $('#continue_invitation_btn').addClass('hidden');
    }
}
function remove_invitation(that){
    $('#invite_form input[id="' + that.id + '"]').remove();
    $('#invited_user_list').find('#' + that.id).remove();

    if($('#invite_form input[name="invited_users[]"]').length <= 0){
        $('#invitation_list').addClass('invisible');
        $('#invite_friend_pretext').removeClass('hidden');

        $('#invite_friends_btn').addClass('hidden');
        $('#continue_invitation_btn').removeClass('hidden');
    }
}

function does_invitation_already_exist(user_id){
    return $('#invite_form input[value=' + user_id + ']').length > 0;
}
function refreshInviteUserList() {
    if (refreshInviteListTimer) {
        clearTimeout(refreshInviteListTimer);
        delete refreshInviteListTimer;
    }
    refreshInviteListTimer = setTimeout(function() {
        $('#invite_user_form').submit();
    }, 250);
}

function addEmail(email_address){
    // make sure it's a valid email that was not already included in the list
    if (isEmail(email_address))  {
        //email_address = email_address.replace("@", "_at_").replace(".","_");
        email_address = email_address.replace(".","\.");
        $('#invite_form').append(
            '<input type="hidden" name="invited_emails[]" value="' + email_address + '" id="' + invitationCounter + '"/>'
            );

        var emailElem = $(document.createElement('li'));
        emailElem.addClass('already-invited-email');
        emailElem[0].id = invitationCounter;
        emailElem.text(email_address.replace("@", " '@' "));
        $('#invited_user_list').append(emailElem);

        invitationCounter++;

        $('#invitation_list').removeClass('invisible');
    }
}

function isEmail(string) {
    var reg = /^([A-Za-z0-9_\-\.])+\@([A-Za-z0-9_\-\.])+\.([A-Za-z]{2,4})$/;
    return reg.test(string);
}


function submit_event_wall_comment(){
    if($('#event_wall_text_field').val().length > 0){
        $('#event_wall_form').submit();
        $('#event_wall_text_field').val('');
        $('#event_wall_text_field').blur();
        $('#event_leave_message').addClass('hidden');
    }
    return false;
}

function createShowMarker(lat, lng, address, location_text) {
    if(undefined === address)
        address = "";
    
    showMarker = markerManager.addMarker(lat, lng);

    var content;
    if(location_text == undefined || location_text.length <= 0)
        content = '<div class="marker-label">' + address + '</div>'
    else
        content = '<div class="marker-label">' + location_text + '<br/>' + address + '</div>'

    showMarker.infoBubble_ = new InfoBubble({
        hideCloseButton: true,
        disableAutoPan: true,
        content: content,
        padding: 0,
        arrowSize: 0,
        borderWidth: 0
    });    
    markerManager.showAllMarkers();
    
    if(!invitationView)
        showMarkers();
    else
        hideMarkers();
}

function hideMarkers(){
    markerManager.hideAllMarkers();
    if(showMarker){
        showMarker.infoBubble_.close();
    }
}

function showMarkers(){
    markerManager.showAllMarkers();

    if(showMarker){
        showMarker.infoBubble_.open(map, showMarker);
    }
}

function resizeDate() {
    if($('#show_event_title_text').height() > 30)
        $('#show_event_date').width(150);
    else
        $('#show_event_date').css('width', '');
}