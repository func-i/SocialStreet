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
        zoomControl: false/*,
        zoomControlOptions: {
            position: google.maps.ControlPosition.RIGHT_CENTER,
            style: google.maps.ZoomControlStyle.SMALL

        }*/
    };
    map = new google.maps.Map(document.getElementById('location-map'), myOptions);

    //ADD ZOOM CONTROL
    var controlDiv = document.createElement("div");
    controlDiv.style.padding = '10px 0 0 420px';
    controlDiv.style.position = 'relative';
    controlDiv.index = 1;

    var zoomBtn = document.createElement('img');
    zoomBtn.style.cursor = "pointer"
    zoomBtn.src = '/images/zoom_btns.png';
    controlDiv.appendChild(zoomBtn);

    var plusBtn = document.createElement('div');
    plusBtn.style.cssText = 'position: absolute; top: 10px; left: 420px; width: 19px; height: 21px;cursor: pointer;'
    plusBtn.title = "Zoom in";
    plusBtn.id = "zoom_in_btn";
    controlDiv.appendChild(plusBtn);

    var minusBtn = document.createElement('div');
    minusBtn.style.cssText = 'position: absolute; top: 31px; left: 420px; width: 19px; height: 21px;cursor: pointer;'
    minusBtn.title = "Zoom out";
    minusBtn.id = "zoom_out_btn";
    controlDiv.appendChild(minusBtn);

    map.controls[google.maps.ControlPosition.TOP_LEFT].push(controlDiv);

    google.maps.event.addDomListener(plusBtn, 'click', function() {
        map.setZoom(map.getZoom() + 1);
    });
    google.maps.event.addDomListener(minusBtn, 'click', function() {
        map.setZoom(map.getZoom() - 1);
    });
}

