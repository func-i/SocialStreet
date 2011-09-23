var showMarker = null;
var refreshInviteListTimer = null;
var invitationCounter = 0;
var invitationPageless = null;

$(function(){

    setupShowEventPage();

    cleanUpSelf = function(){
        showMarker.infoBubble_.setMap(null);
        delete showMarker.infoBubble_;
        showMarker = null;
    }

    $('#event_wall_text_field').keyup(function(e){
        if (e.keyCode == 13) {
            if(e.shiftKey != true){
                submit_event_wall_comment();
                e.stopPropagation();
                return false;
            }
        }
    });
    $('.event-wall-comment').live('mouseenter', function(){
        $(this).find('.comment-delete').removeClass('hidden');
    });
    $('.event-wall-comment').live('mouseleave', function(){
        $(this).find('.comment-delete').addClass('hidden');
    });
    $('.comment-delete').live('click', function(){
        $(this).closest('.event-wall-comment').hide();
    });

    $('.invite-friends-btn').live('click', function(){
        $('#invitation_view').removeClass('hidden');
        $('#show_view').addClass('hidden');
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
    $('#submit_invitation_next_arrow').click(function(){
        $('#invite_form').submit();
        $('#invitation_view').addClass('hidden');
        $('#show_view').removeClass('hidden');
    });



    $('#edit_event_title_link').click(function(){
        $('#result_title_text').addClass('hidden');
        $('#edit_event_title_link').addClass('hidden');
        $('#edit_event_title_field').removeClass('hidden');
    });
    $('#edit_event_title_field').keydown(function(e){
        if(e.keyCode == 13){
            $('#result_title_text').text(e.target.value.substring(0, 36));
            $('#result_title_text').removeClass('hidden');
            $('#edit_event_title_link').removeClass('hidden');
            $('#edit_event_title_field').addClass('hidden');
            $('#event_edit_form').submit();
        }
    });
    $('#edit_event_description_link').click(function(){
        $('#result_description_text').addClass('hidden');
        $('#edit_event_description_link').addClass('hidden');
        $('#edit_event_description_field').removeClass('hidden');
    });
    $('#edit_event_description_field').keydown(function(e){
        if(e.keyCode == 13){
            $('#result_description_text').text(e.target.value);
            $('#result_description_text').removeClass('hidden');
            $('#edit_event_description_link').removeClass('hidden');
            $('#edit_event_description_field').addClass('hidden');
            $('#event_edit_form').submit();

            if(e.target.value > 0){
                $('#edit_event_description_link').text('Edit description...');
            }
            else{
                $('#edit_event_description_link').text('Add description...');
            }
        }
    });


});

function setupShowEventPage(){
    
    var lat = $('#lat').val();
    var lng = $('#lng').val();
    var loc_text = $('#location_text').val();
    var address = $('#address').val();

    createShowMarker(lat, lng, address, loc_text);

    map.panTo(new google.maps.LatLng(lat, lng));
    map.setZoom(15);

    var xOffset = $('#location-map').width() / 5;
    var yOffset = $('#location-map').height() / 5;
    map.panBy(-xOffset, -yOffset);

    initializeScrollPanes();

    //getInvitationUsers();//Load invitation users on delay
}

function getInvitationUsers(){
    setTimeout(function() {
        $.getScript('/invitations/load_connections');
        545
    }, 500);
}

function makeInvitationPageless(){
    invitationPageless = new Pageless({
        container: '#user_holder',
        totalPages: 100,
        currentPage: 1,
        url: '/invitations/load_connections'
    });
    invitationPageless.start();
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
        $('#invitation_list_title').removeClass('hidden');
    }
}
function remove_invitation(that){
    $('#invite_form input[id="' + that.id + '"]').remove();
    $('#invited_user_list').find('#' + that.id).remove();

    if($('#invite_form input[name="invited_users[]"]').length <= 0){
        $('#invitation_list_title').addClass('hidden');
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
    showMarker.infoBubble_.open(map, showMarker);
}