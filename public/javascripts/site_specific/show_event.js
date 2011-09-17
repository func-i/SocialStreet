var showMarker = null;

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

    var lat = $('#lat').val();
    var lng = $('#lng').val();
    createShowMarker(lat, lng);
    map.setCenter(new google.maps.LatLng(lat, lng));
    map.setZoom(15);
});

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