var map;
var toronto = new google.maps.LatLng(43.7427662, -79.3922001);
var markerManager;

$(function(){
    init_map();
});

function init_map(){
    var mapCenter = $('#map_center').val();
    var loc = toronto;
    if(undefined != mapCenter && mapCenter.length > 0){
        var loc_params = mapCenter.split(',');
        if(loc_params.length == 2)
            loc = new google.maps.LatLng(loc_params[0], loc_params[1]);
    }

    var mapZoom = $('#map_zoom').val();
    var zoom = 13;
    if(undefined != mapZoom && mapZoom.length > 0){
        zoom = parseInt(mapZoom, 10);
    }

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

    google.maps.event.addListener(map, 'dragend', function(){
        if($('#on_explore').length > 0)
            updateExploreLocationParams();
    });
    google.maps.event.addListener(map, 'bounds_changed', function(){
        if($('#on_explore').length > 0) {
            updateExploreLocationParams();

        }
    });

    markerManager = new MarkerManager({
        map: map
    });
}

