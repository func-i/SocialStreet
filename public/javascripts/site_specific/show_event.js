var showMarker = null;
var refreshInviteListTimer = null;

$(function(){
    $('#event_wall_text_field').keyup(function(e){
        if (e.keyCode == 13) {
            if(e.shiftKey != true){
                submit_event_wall_comment();
                e.stopPropagation();
                return false;
            }
        }
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
        console.log(this.id);
        remove_invitation(this);
    });


    var lat = $('#lat').val();
    var lng = $('#lng').val();
    createShowMarker(lat, lng);
    map.panTo(new google.maps.LatLng(lat, lng));
    map.setZoom(15);

    var xOffset = $('#location-map').width() / 10;
    var yOffset = $('#location-map').height() / 10;
    map.panBy(-xOffset, -yOffset);
});

function add_invitation(that){
    if(!does_invitation_already_exist(that.id)){
        //Check if user already added to list
        //Add to list
        var userClone = $('#invited_user_clone').clone();
        userClone[0].id = that.id;
        userClone.children('.already-invited-user-image').html($(that).find('img').clone());
        userClone.removeClass('hidden');
        $('#invited_user_list').append(userClone);

        $('#invite_form').append(
            '<input type="hidden" name="invited_users[]" value="' + that.id + '" />'
            );

        $('#invitation_list_title').removeClass('hidden');
    }
}
function remove_invitation(that){
    $('#invite_form input[value="' + that.id + '"]').remove();
    $('#invited_user_list').find('#' + that.id).remove();
    console.log(that.id);
    console.log($('#invited_user_list').find('#' + that.id));

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
        email_address = email_address.replace("@", "_at_").replace(".","_");
        if($('#invite_form input[name="invited_emails[]" value="' + email_address + '"]').length <= 0){
            $('#invite_form').append(
                '<input type="hidden" name="invited_emails[]" value="' + email_address + '" />'
                );

            var emailElem = $(document.createElement('li'));
            emailElem.addClass('already-invited-email');
            emailElem[0].id = email_address;
            emailElem.text(email_address.replace("_at_", " '@' "));
            $('#invited_user_list').append(emailElem);
        }

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

function createShowMarker(lat, lng) {
    markerManager.addMarker(lat, lng);
    markerManager.showAllMarkers();
}