var geocoder;
var map;
var infoWindow;
var markers = [];
var dropPinState = false; // true if button to drop pins is selected
var selectedMarker = null;
var controlUI = null;
var mc;
var overlay;

// for testing only;
var toronto = new google.maps.LatLng(43.7427662, -79.3922001);

$(function() {
    infoWindow = new google.maps.InfoWindow();
    geocoder = new google.maps.Geocoder();
    var myOptions = {
        zoom: 12,
        center: toronto,
        mapTypeControl: false,
        mapTypeId: google.maps.MapTypeId.ROADMAP,
        streetViewControl: false
    };
    map = new google.maps.Map(document.getElementById("event-location-map"), myOptions);
    google.maps.event.addListener(map, 'mousemove', function(event) {
        $('#current_map_pos_lat').val(event.latLng.lat());
         $('#current_map_pos_long').val(event.latLng.lng());
   });
   
    overlay = new google.maps.OverlayView();
    overlay.draw = function() {};
    overlay.setMap(map);


    // Set the MarkerClusterer here
    var mcOptions = {
        gridSize: 50,
        maxZoom: 12,
        zoomOnClick: false
    };
    mc = new MarkerClusterer(map, markers, mcOptions)
    google.maps.event.addListener(mc, 'clusterclick', function(cluster) {
        mkr = cluster.getMarkers()[0];
        selectMarker(mkr);
    });

    // Create the DIV to hold the control and call the DropPinControl() constructor
    // passing in this DIV.
    var homeControlImg = document.createElement('IMG');
    homeControlImg.src = '/images/ico-pin.png';
    console.log(homeControlImg);

    var homeControl = new DropPinControl(homeControlImg, map);

    homeControlImg.index = 1;
    map.controls[google.maps.ControlPosition.TOP_RIGHT].push(homeControlImg);

//    google.maps.event.addListener(map, 'click', function(event) {
//            //disableDropPinState();
//            placeMarker(event.latLng, $('.location-name-field').val());
//        }
//    });
});

function disableDropPinState() {
    dropPinState = false;
    controlUI.style.backgroundColor = 'white';
}

function placeMarker(location, title, contents) {
    var marker = new google.maps.Marker({
        map: map,
        position: location,
        title: title,
        draggable:true,
        animation: google.maps.Animation.DROP,
        icon: 'images/ico-pin-selected.png'
    });
    
    google.maps.event.addListener(marker, 'click', function() {

        var html = "";
        var linkText = " <a href=\"#\" onclick=\"$('#marker-name').html($('#set-title').html()); setTitle(); $(this).hide(); return false;\">Set</a>"
        html +=  "<div id='hidden-link' style='display:none'> " + linkText + "</div>"
        html += "Name: <div id='marker-name'>" + marker.title + linkText + "</div><br />";
        html += "<div id='set-title' style='display:none'><input id='marker-name-field' type='text' value='" + marker.title + "'/></div>"
        
        if(contents != undefined) {            
            if(contents.street_address != undefined)
                html += contents.street_address + "<br />"

            if(contents.locality != undefined)
                html += contents.locality + "<br />"

            if(contents.administrative_area_level_1 != undefined)
                html += contents.administrative_area_level_1 + "<br />"
            
            if(contents.country != undefined)
                html += contents.country + "<br />"

            if(contents.postal_code != undefined)
                html += contents.postal_code + "<br />"
        }

        infoWindow.setContent(html);
        selectEventMarker(marker, true);
        infoWindow.open(map, marker);
        

    });
    markers.push(marker);
    google.maps.event.trigger(marker, 'click');

//map.setCenter(location);
}

function setTitle() {
    $('#marker-name-field').val($('.location-name-field').val());
}

function DropPinControl(controlImg, map) {

    // Set CSS styles for the DIV containing the control
    // Setting padding to 5 px will offset the control
    // from the edge of the map
    //controlDiv.style.padding = '5px';
    $(controlImg).draggable({
        helper: 'clone',
        drag: function(event, ui){
            dropPinState = true;
            google.maps.events.trigger(map, 'mousemove');
        },
        stop: function(e, ui){            
            placeMarker(new google.maps.LatLng($('#current_map_pos_lat').val(), $('#current_map_pos_long').val()));
            dropPinState = false;            
        }
    });

    // Set CSS for the control border
    //    controlUI = document.createElement('DIV');
    //    controlUI.style.backgroundColor = 'white';
    //    controlUI.style.borderStyle = 'solid';
    //    controlUI.style.borderWidth = '2px';
    //    controlUI.style.cursor = 'pointer';
    //    controlUI.style.textAlign = 'center';
    //    controlUI.title = 'Click to specify the location manually';
    //    controlDiv.appendChild(controlUI);

    // Set CSS for the control interior
    //    var controlText = document.createElement('DIV');
    //    controlText.style.fontFamily = 'Arial,sans-serif';
    //    controlText.style.fontSize = '12px';
    //    controlText.style.paddingLeft = '4px';
    //    controlText.style.paddingRight = '4px';
    //    controlText.innerHTML = 'Drag Pin';
    //    controlUI.appendChild(controlText);

    // Setup the click event listeners: simply set the map to Chicago
//    google.maps.event.addDomListener(controlImg, 'mousedown', function() {
//        if (dropPinState) {
//            disableDropPinState();
//        } else {
//            dropPinState = true;
//        //controlUI.style.backgroundColor = '#9999DD';
//        }
//
//    });
}

function clearMarkers() {
    $.each(markers, function(index, marker) {
        marker.setMap(null);
    });
    markers = [];
}

function searchLocations(e) {
    var loc = e.target.value;
    geocoder.geocode( {
        'address': loc
    }, function(results, status) {
        if (status == google.maps.GeocoderStatus.OK) {
            clearMarkers()
            $.each(results, function(index, result) {

                var infoContents = {};

                // Isolate the various address components
                $.each(result.address_components, function(ci, component) {
                    infoContents[component.types["0"]] = component.short_name;
                });
                placeMarker(result.geometry.location, e.target.value, infoContents);
            });
            selectMarker(markers[0], false);
        } else if (status == google.maps.GeocoderStatus.ZERO_RESULTS) {
      
            var sw = map.getBounds().getSouthWest();
            var ne = map.getBounds().getNorthEast();
            var sw_lat = sw.lat(), sw_lng = sw.lng();
            var ne_lat = ne.lat(), ne_lng = ne.lng();
      
            $.getJSON(locationSearchURL, {
                query: loc,
                sw_lat: sw_lat,
                sw_lng: sw_lng,
                ne_lat: ne_lat,
                ne_lng: ne_lng
            }, function(data, textStatus, jqHXR) {
                if (data.length > 0) {
                    $.each(data, function(index, result) {
                        placeMarker(new google.maps.LatLng(result.latitude, result.longitude), result.text);
                    });
                } else {
                    alert("No results found, please drop a pin to tell us where this is");
                }
            });
        } else {
            alert("Geocode was not successful for the following reason: " + status);
        }
    });
    return false;
}

function updateMarkerTitle() {

}

function selectEventMarker(marker, changeInputField) {

    if(selectedMarker != null && selectedMarker != marker)
        selectedMarker.setIcon("/images/ico-pin.png");

    selectedMarker = marker;
    marker.setIcon("/images/ico-pin-selected.png");

    //    if (marker.getAnimation() == null) {
    //        marker.setAnimation(google.maps.Animation.BOUNCE);
    //        setTimeout(function() {
    //            if (marker.getAnimation() == google.maps.Animation.BOUNCE) marker.setAnimation(null);
    //        }, 740);
    //    }

    var latlng = marker.getPosition();
    $('#location-lat-field').val(latlng.lat());
    $('#location-lng-field').val(latlng.lng());
    if (changeInputField) $('.location-name-field').val(marker.title);
    setTimeout(function() {
        $('#marker-name-field').focus();
    }, 100);
}

// don't allow enter to submit form

$('.location-name-field').keydown(function(e) {
    if (e.keyCode == 13) {
        e.stopPropagation();
        searchLocations(e);
        return false;
    }
    return true;
});


$('#marker-name-field').live('keyup', function(e) {
    $('.location-name-field').val(this.value);
    selectedMarker.setTitle(this.value);
    return true;
}).live('keydown', function(e) {
    if (e.keyCode == 13) {
        e.stopPropagation();        
        $('#marker-name').html(this.value + $('#hidden-link').html());
        $('#set-title').children('input')[0].value = this.value;
        return false;
    }
});
$('.location-name-field').change(searchLocations);

function clearClusterMarkers() {
    mc.clearMarkers();
    markers = [];
}
function placeClusterMarkers(){
    if(markers.length > 0)
        mc.addMarkers(markers);
}