var geocoder;
var map;
var infoWindow;
var markers = [];
var dropPinState = false; // true if button to drop pins is selected
var selectedMarker = null;
var controlUI = null;
var mc;
var overlay;
var preservedMarkers = [];

// for testing only;
var toronto = new google.maps.LatLng(43.7427662, -79.3922001);


$(function() {
    var loc;
    if($('#users-current-location').length > 0)
    {
        var loc_arr = $('#users-current-location').val().split(',');
        loc = new google.maps.LatLng(loc_arr[0], loc_arr[1]);
    }
    else{
        loc = toronto;
    }
    
    //infoWindow = new google.maps.InfoWindow();
    geocoder = new google.maps.Geocoder();
    var myOptions = {
        zoom: 12,
        center: loc,
        mapTypeControl: false,
        mapTypeId: google.maps.MapTypeId.ROADMAP,
        streetViewControl: false
    };
    map = new google.maps.Map(document.getElementById("event-location-map"), myOptions);
   
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
   

    //var homeControlDiv = document.createElement('SPAN');
    var controlImg = document.createElement('IMG');
    controlImg.src = '/images/ico-pin.png';
    
    var controlText = document.createElement('DIV'); 
    var homeControl = new DropPinControl(controlImg, controlText, map);

    //homeControlDiv.index = 1;

    map.controls[google.maps.ControlPosition.TOP_RIGHT].push(controlImg);
    map.controls[google.maps.ControlPosition.RIGHT_TOP].push(controlText);

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

function placeMarker(location, title, dragged) {
    var marker = new google.maps.Marker({
        map: map,
        position: location,
        title: title,
        animation: google.maps.Animation.DROP,
        icon: 'images/ico-pin-selected.png'
    });

    var label = new Label({
        map: map
    });

    label.bindTo('position', marker);
    label.bindTo('text', marker, 'title');
    label.bindTo('visible', marker, 'labelVisible');
    label.bindTo('clickable', marker);
    label.bindTo('zIndex', marker);

    marker.label = label;
    marker.invisibleLabel = false;
    
    google.maps.event.addListener(marker, 'click', function() {       
        selectEventMarker(marker, true);
    });
    
    markers.push(marker);
    if(dragged == true)
        preservedMarkers.push(marker);
    
    google.maps.event.trigger(marker, 'click');

    map.setCenter(location);
}

function setTitle() {
    $('#marker-name-field').val($('.location-name-field').val());
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
            placeMarker(new google.maps.LatLng(pos.lat(), pos.lng()), '', true);

            //placeMarker(new google.maps.LatLng($('#current_map_pos_lat').val(), $('#current_map_pos_long').val()));
            dropPinState = false;            
        }
    });

//controlDiv.appendChild(controlImg);
    

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

// Define the overlay, derived from google.maps.OverlayView
function Label(opt_options) {
    // Initialization
    this.setValues(opt_options);


    // Label specific
    var span = this.span_ = document.createElement('span');
    span.style.cssText = 'position: relative; left: -50%; top: -8px; ' +
    'white-space: nowrap; ' +
    'padding: 5px; background-color: white';

    var div = this.div_ = document.createElement('div');
    div.appendChild(span);
    div.style.cssText = 'position: absolute; display: none';
}

Label.prototype = new google.maps.OverlayView;

// Implement onAdd
Label.prototype.onAdd = function() {
    var pane = this.getPanes().overlayImage;
    pane.appendChild(this.div_);


    // Ensures the label is redrawn if the text or position is changed.
    var me = this;
    this.listeners_ = [
    google.maps.event.addListener(this, 'position_changed', function() {
        me.draw();
    }),
    google.maps.event.addListener(this, 'visible_changed', function() {
        me.draw();
    }),
    google.maps.event.addListener(this, 'clickable_changed', function() {
        me.draw();
    }),
    google.maps.event.addListener(this, 'text_changed', function() {
        me.draw();
    }),
    google.maps.event.addListener(this, 'zindex_changed', function() {
        me.draw();
    }),
    google.maps.event.addDomListener(this.div_, 'click', function() {
        if (me.get('clickable')) {
            google.maps.event.trigger(me, 'click');
        }
    })
    ];
};


// Implement onRemove
Label.prototype.onRemove = function() {
    this.div_.parentNode.removeChild(this.div_);


    // Label is removed from the map, stop updating its position/text.
    for (var i = 0, I = this.listeners_.length; i < I; ++i) {
        google.maps.event.removeListener(this.listeners_[i]);
    }
};


// Implement draw
Label.prototype.draw = function() {
    var projection = this.getProjection();
    var position = projection.fromLatLngToDivPixel(this.get('position'));

    var div = this.div_;
    div.style.left = position.x + 'px';
    div.style.top = position.y + 15 + 'px';

    var visible = this.get('visible');
    div.style.display = visible ? 'block' : 'none';


    var clickable = this.get('clickable');
    this.span_.style.cursor = clickable ? 'pointer' : '';


    var zIndex = this.get('zIndex');
    div.style.zIndex = zIndex;


    this.span_.innerHTML = this.get('text').toString();
};

function clearMarkers() {
    $.each(arraySubtract(markers, preservedMarkers), function(index, marker) {
        marker.setMap(null);
    });

    //markers = preservedMarkers.slice(0);
    marker = [];
}

function searchLocations(e) {
    var loc = e.target.value;
    geocoder.geocode( {
        'address': loc,
        'bounds' : map.getBounds()
    }, function(results, status) {
        if (status == google.maps.GeocoderStatus.OK) {
            clearMarkers();
            $.each(results, function(index, result) {

                var infoContents = {};

                // Isolate the various address components
                $.each(result.address_components, function(ci, component) {
                    infoContents[component.types["0"]] = component.short_name;
                });
            //placeMarker(result.geometry.location, e.target.value, infoContents);
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
                        //placeMarker(new google.maps.LatLng(result.latitude, result.longitude), result.text);
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
    if(selectedMarker != null && selectedMarker != marker) {
        selectedMarker.setIcon("/images/map_pin.png");
        $.each(preservedMarkers, function(index, ele) {
            if(ele == selectedMarker)
            {
                preservedMarkers.splice(index, 1);
                markers.push(ele);
            }

        });

        if(selectedMarker.label != undefined)
            selectedMarker.label.setMap(null);
    }

    if(selectedMarker == null || (selectedMarker != null && selectedMarker != marker)) {
        selectedMarker = marker;
        preservedMarkers.push(marker);
    
        var label = new Label({
            map: map
        });

        label.bindTo('position', marker);

        var linkText = "<input id=\"marker-name-field\" type=\"text\" value=\"" + marker.title + "\" style='display:none; width: 200px;'/><a href=\"#\" onClick=\"labelClicked(this); return false;\">Add place name</a>";
        marker.htmlTitle = linkText;
        label.bindTo('text', marker, 'htmlTitle');

        label.bindTo('visible', marker);
        label.bindTo('clickable', marker);
        label.bindTo('zIndex', marker);

        marker.label = label;
    
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
            //$('#marker-name-field').focus();
            }, 100);
    }
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

$('#marker-name-field').live('click', function() {
    $(this).focus();
});

$('#marker-name-field').live('keyup', function(e) {
    $('.location-name-field').val(this.value);
    selectedMarker.setTitle(this.value);
    return true;
}).live('keydown', function(e) {
    if (e.keyCode == 13) {
        e.stopPropagation();        
        //$('#marker-name').html(this.value + $('#hidden-link').html());
        //$('#set-title').children('input')[0].value = this.value;
        $(this).siblings('a').show();
        $(this).hide();
        return false;
    }
});
$('.location-name-field').change(searchLocations);

function clearClusterMarkers() {
    var markersToClear = arraySubtract(markers, preservedMarkers);

    mc.removeMarkers(markersToClear);

    markers = [];
}

function placeClusterMarkers(){
    if(markers.length > 0)
        mc.addMarkers(markers);
}

function labelClicked(lnk) {  
    $(lnk).siblings('input').show();
    $(lnk).hide();
}