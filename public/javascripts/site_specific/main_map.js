var map;
var mapInit = false;
var toronto = new google.maps.LatLng(43.7427662, -79.3922001);
var markerManager;
var zoomControl;

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
        mapTypeControl: false,
        mapTypeId: google.maps.MapTypeId.ROADMAP,
        streetViewControl: false,
        panControl: false,
        rotateControl: false,
        scaleContol: false,
        zoomControl: false/*,
        zoomControlOptions: {
            position: google.maps.ControlPosition.RIGHT_CENTER,
            style: google.maps.ZoomControlStyle.SMALL

        }*/
    };
    map = new google.maps.Map(document.getElementById('location-map'), myOptions);
    google.maps.event.addListenerOnce(map, 'idle', function(){
        mapInit = true;
    });
    map.setOptions({
        zoom: zoom,
        center: loc
    });

    //ADD ZOOM CONTROL
    zoomControl = document.createElement("div");
    zoomControl.id = "zoom_btns"

    var plusBtn = document.createElement('div');
    plusBtn.title = "Zoom in";
    plusBtn.id = "zoom_in_btn";
    zoomControl.appendChild(plusBtn);

    var minusBtn = document.createElement('div');
    minusBtn.title = "Zoom out";
    minusBtn.id = "zoom_out_btn";
    zoomControl.appendChild(minusBtn);
    
    map.controls[google.maps.ControlPosition.TOP_LEFT].push(zoomControl);

    google.maps.event.addDomListener(plusBtn, 'click', function() {
        map.setZoom(map.getZoom() + 1);
    });
    google.maps.event.addDomListener(minusBtn, 'click', function() {
        map.setZoom(map.getZoom() - 1);
    });
}

