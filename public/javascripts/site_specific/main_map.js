var map;
var toronto = new google.maps.LatLng(43.7427662, -79.3922001);
var markerManager;

$(function(){
    init_map();

    markerManager = new MarkerManager({
        map: map
    });
});

function init_map(){
    //GET LOCATION
    var loc, loc_params;

    var mapCenter = $('#map_center').val();
    if(undefined != mapCenter && mapCenter.length > 0){
        loc_params = mapCenter.split(',');
    }
    else{
        loc_params = $('#users_current_location').val().split(',');
    }

    if(loc_params.length == 2){
        loc = new google.maps.LatLng(loc_params[0], loc_params[1]);
    }
    else{
        loc = toronto;
    }

    //GET ZOOM
    var mapZoom = $('#map_zoom').val();
    var zoom;
    if(undefined != mapZoom && mapZoom.length > 0){
        zoom = parseInt(mapZoom, 10);
    }
    else{
        zoom = 14;
    }

    //CREATE MAP
    var myOptions = {
        zoom: zoom,
        center: loc,
        mapTypeControl: false,
        mapTypeId: google.maps.MapTypeId.ROADMAP,
        streetViewControl: false,
        panControl: false,
        rotateControl: false,
        scaleContol: false,
        zoomControl: true,
        zoomControlOptions: {
            position: google.maps.ControlPosition.RIGHT_CENTER,
            style: google.maps.ZoomControlStyle.SMALL

        }
    };
    map = new google.maps.Map(document.getElementById('location-map'), myOptions);

    //ADD LISTENERS
    google.maps.event.addListener(map, 'dragend', function(){
        if($('#on_explore').length > 0)
            updateExploreLocationParams();
    });
    google.maps.event.addListener(map, 'bounds_changed', function(){
        if($('#on_explore').length > 0) {
            updateExploreLocationParams();

        }
    });
}

