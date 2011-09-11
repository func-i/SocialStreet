var geocoder;
var map;
var infoWindow;
var dropPinState = false; // true if button to drop pins is selected
var controlUI = null;
var overlay;
var createMarkerManager;

// for testing only;
var toronto = new google.maps.LatLng(43.7427662, -79.3922001);

function getCreateMarkerManager(){
    return createMarkerManager;
}

$(function() {
    var loc;
    var stored_loc = $('#users-current-location');
    var exploreMapCenter = $('#map_center').val();
    var foundLoc;

    if(exploreMapCenter != '')
        foundLoc = exploreMapCenter;
    
    else if(stored_loc.length > 0 && stored_loc.val()) 
        foundLoc = stored_loc.val();
   
    if(foundLoc != null){
        var loc_arr = foundLoc.split(',');
        loc = new google.maps.LatLng(loc_arr[0], loc_arr[1]);
    }
    else
        loc = toronto;
    

    var myOptions = {
        zoom: 13,
        center: loc,
        mapTypeControl: false,
        mapTypeId: google.maps.MapTypeId.ROADMAP,
        streetViewControl: false
    };
    map = new google.maps.Map(document.getElementById("event-location-map"), myOptions);

    var controlImg = document.createElement('IMG');
    controlImg.src = '/images/ico-pin.png';

    var controlText = document.createElement('DIV');
    var homeControl = new DropPinControl(controlImg, controlText, map);

    map.controls[google.maps.ControlPosition.TOP_RIGHT].push(controlImg);
    map.controls[google.maps.ControlPosition.RIGHT_TOP].push(controlText);

    var crosshairShape = {
        coords:[0,0,0,0],
        type:'rect'
    };
    var crosshair_marker = new google.maps.Marker({
        map: map,
        icon: 'http://www.daftlogic.com/images/cross-hairs.gif',
        shape: crosshairShape
    });
    crosshair_marker.bindTo('position', map, 'center');

    createMarkerManager = new MarkerManager({
        map: map,
        gridSize: 15,
        createEvent: true
    });
    
    geocoder = new google.maps.Geocoder();

    overlay = new google.maps.OverlayView();
    overlay.draw = function() {};
    overlay.setMap(map);
});

function disableDropPinState() {
    dropPinState = false;
    controlUI.style.backgroundColor = 'white';
}

function DropPinControl(controlImg, controlText, map) {
    controlImg.style.paddingTop = '5px';
    controlImg.style.marginRight = '48px';
    controlImg.style.cursor = 'pointer';
    controlImg.onmouseover = function() {
        this.src='/images/ico-pin-hover.png';
    }

    controlImg.onmouseout = function() {
        this.src='/images/ico-pin.png';
    }    

    controlText.style.marginRight = '10px';
    controlText.style.padding = '5px';
    controlText.style.backgroundColor = 'white';
    controlText.style.color = '#0981BE';    
    controlText.style.fontFamily = 'Arial,sans-serif';
    controlText.style.fontSize = '14px';
    controlText.innerHTML = 'Drag & Drop Pin';    

    // Set CSS styles for the DIV containing the control
    // Setting padding to 5 px will offset the control
    // from the edge of the map
    
    $(controlImg).draggable({
        helper: 'clone',
        drag: function(event, ui){
            dropPinState = true;
        },
        stop: function(event, ui){
            //The additions to ui.position are to correct for the padding and image size (so we drop it at the point and not top left corner
            var proj = new ProjectionHelperOverlay(map);
            var pos = proj.getProjection().fromContainerPixelToLatLng(new google.maps.Point(ui.position.left+20, ui.position.top+48));
            var location = new google.maps.LatLng(pos.lat(), pos.lng());
            var geocoded_address = '';
            geocoder.geocode({
                'location':location
            }, function(results,status) {
                if (status == google.maps.GeocoderStatus.OK) {
                    geocoded_address = results[0].formatted_address;
                }
                createMarkerManager.createMarker(location, null, null, geocoded_address, true);
                map.setCenter(location);
            });
           

            dropPinState = false;            
        }
    });
}

/**@private
 * In V3 it is quite hard to gain access to Projection and Panes.
 * This is a helper class
 * @param {google.maps.Map} map
 */
function ProjectionHelperOverlay(map) {
    google.maps.OverlayView.call(this);
    this.setMap(map);
}

ProjectionHelperOverlay.prototype = new google.maps.OverlayView();
ProjectionHelperOverlay.prototype.draw = function () {
    if (!this.ready) {
        this.ready = true;
        google.maps.event.trigger(this, 'ready');
    }
};

function searchLocations(e) {
    var loc = e.target.value;
    geocoder.geocode( {
        'address': loc,
        'bounds' : map.getBounds()
    }, function(results, status) {
        if (status == google.maps.GeocoderStatus.OK) {
            $.each(results, function(index, result) {

                var infoContents = {};

                // Isolate the various address components
                $.each(result.address_components, function(ci, component) {
                    infoContents[component.types["0"]] = component.short_name;
                });
                createMarkerManager.createMarker(result.geometry.location, null, null, e.target.value, true);
                map.setCenter(result.geometry.location);
            });
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
                        //placeMarker(new google.maps.LatLng(result.latitude, result.longitude), result.text);
                        var location = new google.maps.LatLng(result.latitude, result.longitude)
                        createMarkerManager.createMarker(location, null, null, result.text, true);
                        map.setCenter(location);
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

// don't allow enter to submit form

$('.location-address-field').keydown(function(e) {
    if (e.keyCode == 13) {

        $('#location-name-field').val("");
        
        searchLocations(e);

        e.stopPropagation();
        $(this).blur();

        return false;
    }
    return true;
});

$('.location-address-field').change(function(e){
    $('#location-name-field').val("");

    searchLocations(e);

    e.stopPropagation();
    $(this).blur();

    return false;

});