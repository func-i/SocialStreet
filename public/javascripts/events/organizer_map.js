var geocoder;
var map;
var infoWindow;
var markers = [];
var dropPinState = false; // true if button to drop pins is selected
var selectedMarker = null;
// for testing only;
var chicago = new google.maps.LatLng(41.850033, -87.6500523);
$(function() {
  infoWindow = new google.maps.InfoWindow();
  geocoder = new google.maps.Geocoder();
  var myOptions = {
    zoom: 12,
    center: chicago,
    mapTypeId: google.maps.MapTypeId.ROADMAP
  };
  map = new google.maps.Map(document.getElementById("event-location-map"), myOptions);
  // Create the DIV to hold the control and call the DropPinControl() constructor
  // passing in this DIV.
  var homeControlDiv = document.createElement('DIV');
  var homeControl = new DropPinControl(homeControlDiv, map);

  homeControlDiv.index = 1;
  map.controls[google.maps.ControlPosition.TOP_RIGHT].push(homeControlDiv);

  google.maps.event.addListener(map, 'click', function(event) {
    if (dropPinState) {
      placeMarker(event.latLng, $('#location-name-field').val());
    }
  });
});

function placeMarker(location, title) {

  var marker = new google.maps.Marker({
    map: map,
    position: location,
    title: title,
    draggable:true,
    animation: google.maps.Animation.DROP
  });

  google.maps.event.addListener(marker, 'click', function() {
    selectMarker(marker, true);
  });
  markers.push(marker);

  selectMarker(marker);

//map.setCenter(location);
}

function DropPinControl(controlDiv, map) {

  // Set CSS styles for the DIV containing the control
  // Setting padding to 5 px will offset the control
  // from the edge of the map
  controlDiv.style.padding = '5px';

  // Set CSS for the control border
  var controlUI = document.createElement('DIV');
  controlUI.style.backgroundColor = 'white';
  controlUI.style.borderStyle = 'solid';
  controlUI.style.borderWidth = '2px';
  controlUI.style.cursor = 'pointer';
  controlUI.style.textAlign = 'center';
  controlUI.title = 'Click to specify the location manually';
  controlDiv.appendChild(controlUI);

  // Set CSS for the control interior
  var controlText = document.createElement('DIV');
  controlText.style.fontFamily = 'Arial,sans-serif';
  controlText.style.fontSize = '12px';
  controlText.style.paddingLeft = '4px';
  controlText.style.paddingRight = '4px';
  controlText.innerHTML = 'Drop Pin';
  controlUI.appendChild(controlText);

  // Setup the click event listeners: simply set the map to Chicago
  google.maps.event.addDomListener(controlUI, 'click', function() {
    if (dropPinState) {
      dropPinState = false;
      controlUI.style.backgroundColor = 'white';
    } else {
      dropPinState = true;
      controlUI.style.backgroundColor = '#9999DD';
    }

  });
}

function searchLocations(e) {
  console.log(e);
  var loc = e.target.value;
  geocoder.geocode( {
    'address': loc
  }, function(results, status) {
    if (status == google.maps.GeocoderStatus.OK) {
      $.each(markers, function(index, marker) {
        marker.setMap(null);
      });
      markers = [];
      $.each(results, function(index, result) {
        placeMarker(result.geometry.location, result.formatted_address);
      });
      selectMarker(markers[0], false);
    } else if (status == google.maps.GeocoderStatus.ZERO_RESULTS) {
      alert("No results found, please drop a pin to tell us where this is");
    } else {
      alert("Geocode was not successful for the following reason: " + status);
    }
  });
  return false;
}

function updateMarkerTitle() {

}

function selectMarker(marker, changeInputField) {
  selectedMarker = marker;

  if (marker.getAnimation() == null) {
    marker.setAnimation(google.maps.Animation.BOUNCE);
    setTimeout(function() {
      if (marker.getAnimation() == google.maps.Animation.BOUNCE) marker.setAnimation(null);
    }, 200);
  }

  var html = "<table>" +
  "Name: <input type='text' id='marker-name-field' value='"+marker.title+"'/>";

  infoWindow.setContent(html);
  infoWindow.open(map, marker);

  var latlng = marker.getPosition();
  $('#location-lat-field').val(latlng.lat());
  $('#location-lng-field').val(latlng.lng());
  if (changeInputField) $('#location-name-field').val(marker.title);
}

// don't allow enter to submit form

$('#location-name-field').keydown(function(e) {
  if (e.keyCode == 13) {
    e.stopPropagation();
    searchLocations(e);
    return false;
  }
  return true;
});

$('#marker-name-field').live('keyup', function(e) {
  $('#location-name-field').val(this.value);
  selectedMarker.setTitle(this.value);
});
$('#location-name-field').change(searchLocations);