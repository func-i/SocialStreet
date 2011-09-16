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
});

function submit_event_wall_comment(){
    if($('#event_wall_text_field').val().length > 0){
        $('#event_wall_form').submit();
        $('#event_wall_text_field').val('');
        $('#event_wall_text_field').blur();
    }
    return false;
}

function setup_show_event(result_dom){
    //Fill in the event details
    var target_dom = $('#show_event_details');
    target_dom.find('.result-image').html(result_dom.find('.result-image').html());
    target_dom.find('.result-title').html(result_dom.find('.result-title').html());
    var start_date = result_dom.find('#start_date').val();
    var end_date = result_dom.find('#end_date').val()
    target_dom.find('.result-date').html("When: " + start_date + " - " + end_date);
    target_dom.find('.result-tags').html("Tags: " + result_dom.find('#tags').val());
    target_dom.find('.result-description').html(result_dom.find('#description').val());

    //TODO retrieve wall and invites from server

    //Place marker
    var lat = result_dom.find('#result_lat');
    var lng = result_dom.find('#result_lng');
    var marker = createShowMarker(lat.val(), lng.val());
    map.setCenter(marker.getPosition());
    map.setZoom(15);
}

function join_event_btn_clicked(){
//TODO
}

function createShowMarker(lat, lng){
    var marker = new google.maps.Marker(
    {
        position: new google.maps.LatLng(lat, lng)
    });
    marker.setMap(map);

    showMarker = marker;

    google.maps.event.addListener(marker, 'click', function(latlng){
        //TODO
        });

    return marker;
}