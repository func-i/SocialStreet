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
    var stored_loc = $('#users-current-location');
    if(stored_loc.length > 0 && stored_loc.val())
    {
        var loc_arr = $('#users-current-location').val().split(',');
        loc = new google.maps.LatLng(loc_arr[0], loc_arr[1]);
    }
    else{
        loc = toronto;
    }
    
    infoWindow = new InfoBubble();
    infoWindow.hideCloseButton();
    
    geocoder = new google.maps.Geocoder();
    var myOptions = {
        zoom: 13,
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
    var styles = [
    {
        url: '../images/map_pin.png',
        height: 41,
        width: 33,
        anchor: [12, 14],
        textSize: 8,
        textColor: 'red'
    },
    {
        url: '../images/map_pin.png',
        height: 41,
        width: 33,
        anchor: [12, 12.5],
        textSize: 8,
        textColor: 'red'
    },
    {
        url: '../images/ico-pin-selected.png',
        height: 45,
        width: 37,
        anchor: [14.5, 16.5],
        textSize: 8,
        textColor: 'black'
    },
    {
        url: '../images/ico-pin-selected.png',
        height: 45,
        width: 37,
        anchor: [14, 14.5],
        textSize: 8,
        textColor: 'black'
    }
    ];
    var mcOptions = {
        gridSize: 20,
        maxZoom: 20,
        averageCenter: false,
        zoomOnClick: false,
        styles: styles
    };
    mc = new MarkerClusterer(map, markers, mcOptions)

    mc.setCalculator(function(markers, numStyles, isSelected)
    {
        var index = 0;
        var count = markers.length;
        var dv = count;
        while (dv !== 0) {
            dv = parseInt(dv / 10, 10);
            index++;
        }

        index = Math.min(index, numStyles/2); //divide by two for selected state at end
        if(isSelected){
            index = index + numStyles/2
        }
        return {
            text: count,
            index: index
        };
    });


    google.maps.event.addListener(mc, 'clusterclick', function(cluster) {
        cluster.isSelected(true);
        cluster.updateIcon();

        selectEventMarker(cluster);
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

    google.maps.event.addListener(marker, 'click', function() {       
        selectEventMarker(marker);
    });
    
    markers.push(marker);
    if(dragged == true)
        preservedMarkers.push(marker);

    google.maps.event.trigger(marker, 'click');

    map.setCenter(location);
}

function setTitle(title) {
    console.log("SET TITLE")
//    $('#marker-name-field').val(title);
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

function clearMarkers() {
    $.each(arraySubtract(markers, preservedMarkers), function(index, marker) {
        marker.setMap(null);
    });

//markers = preservedMarkers.slice(0);
//marker = [];
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
    {
        if(selectedMarker instanceof Cluster){
            if(selectedMarker.isDeleted_){
                console.log("WAS DELETED..", selectedMarker);
            }
            else{
            //Set old selection back to normal pin
            selectedMarker.isSelected(false);
            selectedMarker.updateIcon();
            }
        }
        else{
            //Set old selection back to normal pin
            selectedMarker.setIcon("/images/map_pin.png");
            
            //Remove pins from preserved list
            $.each(preservedMarkers, function(index, ele)
            {
                if(ele == selectedMarker)
                {
                    preservedMarkers.splice(index, 1);
                    markers.push(ele);
                }

            });

            //Remove label
            if(selectedMarker.label != undefined)
                selectedMarker.label.setMap(null);
        }
    }

    //New pin
    if(selectedMarker != marker) {
        //Set Marker
        selectedMarker = marker;

        if(marker instanceof Cluster)
        {
            //Set icon
            marker.isSelected(true);
            marker.updateIcon();

            var cMarkers = marker.getMarkers();
            $.each(cMarkers, function(index, mkr)
            {
                //Add markers to preserved list
                preservedMarkers.push(mkr);

                if(index == 0){
                    //Set Infobox
                    var myTitle = marker.title_;
                    var linkText = "<div style='text-align:center;'><input id=\"marker-name-field\" type=\"text\" value=\"" + myTitle + "\" style='display:none; width: 200px; border:0; margin:0;'/>" +
                    "<a href=\"#\" onClick=\"labelClicked(this); return false;\">" +
                    ((myTitle != "" && $('#location-name-field').val() == myTitle) ?  myTitle : 'Add place name') +
                    "</a></div>";
                    //marker.htmlTitle = linkText;
                    infoWindow.setContent(linkText);

                    infoWindow.setMaxHeight(20);
                    infoWindow.setMinHeight(10);
                    infoWindow.setBorderWidth(5);
                    infoWindow.setPadding(5);
                    
                    //infoWindow.open(map, mkr);
                    //console.log(marker.getCenter());
                    console.log(marker);
                    var p = marker.clusterIcon_.getPosFromLatLng_(marker.clusterIcon_.center_);
                    var q = marker.clusterIcon_.getProjection().fromDivPixelToLatLng(p);
                    //console.log(p);
                    //console.log(q);                    
                    infoWindow.open(map, mkr);
                    infoWindow.setPosition(q);

                    var latlng = mkr.getPosition();
                    $('#location-lat-field').val(latlng.lat());
                    $('#location-lng-field').val(latlng.lng());
                }
            });
        }
        else{
            //Add marker to preserved list
            preservedMarkers.push(marker);

            //Set icon
            marker.setIcon("../images/ico-pin-selected.png");

            //Set Infobox
            linkTitle = (marker.title != "" && $('#location-name-field').val() == marker.title) ?  marker.title : 'Add place name';
            var linkText = "<div style='text-align:center;'><input id=\"marker-name-field\" type=\"text\" value=\"" + marker.title + "\" style='display:none; width: 200px; border:0; margin:0;'/>" +
            "<a href=\"#\" onClick=\"labelClicked(this); return false;\">" + linkTitle +
            "</a></div>";

            infoWindow.setContent(linkText);

            infoWindow.setMaxHeight(20);
            infoWindow.setMinHeight(10);
            infoWindow.setMinWidth(linkTitle.length*6.5);
            infoWindow.setBorderWidth(5);
            infoWindow.setPadding(5);
            infoWindow.open(map, marker);

            var latlng = marker.getPosition();
            $('#location-lat-field').val(latlng.lat());
            $('#location-lng-field').val(latlng.lng());
        }  
    }
}

// don't allow enter to submit form

$('.location-address-field').keydown(function(e) {
    if (e.keyCode == 13) {
        e.stopPropagation();

        $('#location-name-field').val("");
        
        searchLocations(e);
        return false;
    }
    return true;
});

$('#marker-name-field').live('click', function() {
    $(this).focus();
});

$('#marker-name-field').live('keyup', function(e) {
    $('#location-name-field').val(this.value);
    selectedMarker.setTitle(this.value);

    return true;
}).live('keydown', function(e) {
    if (e.keyCode == 13) {
        alert('enter pressed');
        e.stopPropagation();

        if(this.value.length > 0)
        {
            $(this).siblings('a').html(this.value);
        }
        else{
            $(this).siblings('a').html("Add place name");
        }


        infoWindow.setMinWidth($(this).siblings('a').html().length*6.5);//TODO - Horrible hack

        infoWindow.setMinHeight('auto');

        infoWindow.setPadding(5);
        infoWindow.setBorderWidth(5);

        $(this).siblings('a').show();
        $(this).hide();
        
        return false;
    }
});
$('.location-address-field').change(function(){
    searchLocations
});

function clearClusterMarkers() {
    var markersToClear = arraySubtract(markers, preservedMarkers);
//        console.log("Clear Cluster Markers");
  //    console.log('preservedMarkers: ', preservedMarkers);
    // console.log('markersToClear: ', markersToClear);

    mc.removeMarkers(markersToClear);

    markers = [];
}

function placeClusterMarkers(){
    //console.log("Place Cluster Markers");
    //console.log("Markers: ", markers);
    if(markers.length > 0)
        mc.addMarkers(markers);
//    console.log("DONE: ", mc.getMarkers());
}

function labelClicked(lnk) {  
    $(lnk).siblings('input').show().focus();

    infoWindow.setMinHeight(20);
    infoWindow.setMinWidth(200);

    infoWindow.setPadding(0);
    infoWindow.setBorderWidth(5);
    $(lnk).hide();
}