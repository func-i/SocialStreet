var showMarker = null;
var refreshInviteListTimer = null;

$(function(){
    $('#show_join_event').click(function(){
        join_event_btn_clicked();
    });

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
        else{
            refreshInviteUserList(e.target.value);
        }
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


function refreshInviteUserList() {
    if (refreshInviteListTimer) {
        clearTimeout(refreshInviteListTimer);
        delete refreshInviteListTimer;
    }
    refreshInviteListTimer = setTimeout(function() {
        $('#invite_user_form').submit();
    }, 100);
}

function addEmail(email_address){
    // make sure it's a valid email that was not already included in the list
    if (isEmail(email_address))  {
        //TODO: make sure not already in list, then add to invitation list
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

function join_event_btn_clicked(){
//TODO
}

function createShowMarker(lat, lng) {
    markerManager.addMarker(lat, lng);
    markerManager.showAllMarkers();
}