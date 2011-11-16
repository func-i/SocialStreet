var selectedMarkerArray = [];
var markerInterval;

$('#remove_filters').live('click', function(){
    $('#keyword').val("");
    $('#keyword').submit();
    event.preventDefault();
});

$('#keyword_filter_list li').live('click', function(li){
    selKeyword = $.trim($(this).text());
    $('#keyword').val(selKeyword);
    $('#keyword').submit();
    event.preventDefault(); // Prevent link from following its href
});

$('#explore_filter').live("pageshow",function() {
    var keyword = "";
    $('#filter_no_results').hide();
    $('input[data-type="search"]').val("");

    $('.ui-input-text').live('keyup', function(){
        keyword = $(this).val();
        $('#filter_no_results a span').text(keyword);
        if($('.result:visible').length == 1) {
            if($('.result:visible a').text() == keyword || $('.result:visible a').text().toLowerCase() == keyword){
                $('#filter_no_results').hide();
            }

        }
        else if ($(this).val().length == 0){
            $('#filter_no_results').hide();
        }
        else
        {
            $('#filter_no_results').show();
        }
    });
});

function changeMapLocation(e, latLng) {
    if(latLng == null) {
        var loc = e.target.value;
        geocoder.geocode({
            address: loc
        }, function(results, status) {
            if (status == google.maps.GeocoderStatus.OK) {
                exploreMap.setCenter(results[0].geometry.location);
                changeExploreLocationParams();

            }
            else if (status == google.maps.GeocoderStatus.ZERO_RESULTS) {
                alert('No Locations Found!');
            }
        });
    }
    else if(latLng != null) {
        exploreMap.setCenter(latLng);
        changeExploreLocationParams();
    }
}

function changeExploreLocationParams(event) {
    setTimeout(function() {
        var zoom = 15;
        $('#explore_map_zoom').val(zoom);

        deselectMarker();

        bounds = exploreMap.getBounds();
        ne = bounds.getNorthEast();
        sw = bounds.getSouthWest();
        c = bounds.getCenter();

        $('#explore_map_bounds').val(ne.lat() + ',' + ne.lng() + ',' + sw.lat() + ',' + sw.lng());
        $('#explore_map_center').val(c.lat() + ',' + c.lng());
        $('#explore_view_params').val("map");
        updateUserLocation(c.lat(), c.lng(), false);
        $('#explore_form').submit();

    }, 20);
}


function selectedMarker(marker) {
    $('#display_results').empty();
    if(marker.clusteredMarkers_.length > 0) {
        clustered_markers = marker.clusteredMarkers_;
        for (i=0; i < clustered_markers.length; i++){
            event_id = clustered_markers[i].eventID_;
            $('#event_'+event_id).clone().removeAttr('id').appendTo('#display_results');
        }
    }
    $('#display_results').listview('refresh');
    refresh_iScrollers();

    deselectMarker();
    $('#explore_event_details').show();

    selectedMarkerArray.push(marker);
    marker.setIcon("/images/marker-base.png");
    marker.setShadow(new google.maps.MarkerImage('/images/icon-shadow.png', null, null, new google.maps.Point(17,55)));
    marker.label_.setMap(exploreMap);

    if(markerInterval != null){
        clearTimeout(markerInterval);
    }

    if(marker.clusteredMarkers_.length > 1){
        var count = 0;
        markerInterval = setInterval(function(){
            if($.inArray(marker, selectedMarkerArray) < 0){
                clearTimeout(markerInterval);
                return;
            }
            marker.label_.setIconClass(marker.clusteredMarkers_[count].iconClass_);
            count += 1;
            if(count >= marker.clusteredMarkers_.length)
                count = 0;
        }, 1000);
    }
}

function deselectMarker() {
    $('#explore_event_details').hide();
    
    for(var i = 0; i < selectedMarkerArray.length; i++){
        if(selectedMarkerArray[i] != undefined) {
            selectedMarkerArray[i].setIcon("/images/grey-pin.png");
            selectedMarkerArray[i].setShadow(new google.maps.MarkerImage('/images/pin-shadow.png', null, null, new google.maps.Point(0,26)));
            selectedMarkerArray[i].label_.setMap(null);
            delete selectedMarkerArray[i].clusteredIcons_
        }
    }
    delete selectedMarkerArray;
    selectedMarkerArray = [];
    
    if(markerInterval != null){
        clearTimeout(markerInterval);
    }

}


$('#explore_change_map_address').live("keydown", function(e) {
    if (e.keyCode == 13) {
        e.stopPropagation();
        $(this).blur();
        $('#explore_event_details').hide();
        changeMapLocation(e);
        return false;
    }
    return true;
});
  