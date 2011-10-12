var geocoder = new google.maps.Geocoder();
var exploreMarkerArr = [];
var exploreEventTypeTimer;
var exploreUpdateTimer;
var selectedResult;
var selectedMarker;

$(function(){
    //Cleanup function on leaving the page
    cleanUpSelf = function() {
        $('#notify_me_btn').addClass('hidden');
    }

    resizeSelf = function(){
        resizeCenterPaneContent();
    }
    
    //Setup the explore page
    setupExplorePage();    
});

function resizeCenterPaneContent(){
    var centerPaneBottom = $('#center_pane').offset().top + $('#center_pane').height();
    var scrollerTop = $('#event_types_scroller').offset().top;
    $('#event_types_scroller').height(centerPaneBottom - scrollerTop);
}

function setupExplorePage(){
    $('#notify_me_btn').removeClass('hidden');

    $('#explore_search_params').ajaxComplete(function() {
        resizePageElements();
    });

    var mapCenter = $('#map_center').val();
    var mapCenterArr = mapCenter.split(",");

    if(map.getZoom() != parseInt($('#map_zoom').val(), 10)){
        map.setZoom(parseInt($('#map_zoom').val(), 10));
    }
    if(map.getCenter().lat() != parseFloat(mapCenterArr[0]) || map.getCenter().lng() != parseFloat(mapCenterArr[1])){
        map.panTo(new google.maps.LatLng(parseFloat(mapCenterArr[0]), parseFloat(mapCenterArr[1])));
    }

    addExploreMarkers();
    toggle_suggested_actions();
}

function toggle_suggested_actions(){
    if(exploreMarkerArr.length < 5){
        $('#suggested_actions').removeClass('hidden');

        if($('#explore_search_params input[name="keywords[]"]').length > 0){
            $('suggested_actions_change_filter').removeClass('hidden');
        }
        else{
            $('suggested_actions_change_filter').addClass('hidden');
        }
    }
    else{
        $('#suggested_actions').addClass('hidden');
    }
}

function updateExploreLocationParams(){
    $('#map_zoom').val(map.getZoom());
    var bounds = map.getBounds();

    var projection = markerManager.projectionHelper_.getProjection();
    var bl = new google.maps.LatLng(bounds.getSouthWest().lat(),
        bounds.getSouthWest().lng());

    var blPix = projection.fromLatLngToDivPixel(bl);
    blPix.x += $('#left_side_pane').offset().left + $('#left_side_pane').width();

    var sw = projection.fromDivPixelToLatLng(blPix);
    var ne = bounds.getNorthEast();

    $('#map_bounds').val(ne.lat() + ',' + ne.lng() + ',' + sw.lat() + ',' + sw.lng());
    $('#map_center').val(map.getCenter().lat() + "," + map.getCenter().lng());

    updateUserLocation(map.getCenter().lat(), map.getCenter().lng(), true);
    
    refreshExploreResults();
}


function refreshExploreResults(){
    if(exploreUpdateTimer){
        clearTimeout(exploreUpdateTimer);
        delete exploreUpdateTimer
    }

    exploreUpdateTimer = setTimeout(function(){
        $('#explore_search_params').submit();
        if(history && history.pushState) {
            history.pushState(null, "", '?' + $('#explore_search_params').serialize());
        }
    }, 100);
}

function addExploreMarkers(){
    $.each($('#results_list .result'), function(index, result){
        var lat = $(result).children('#result_lat');
        var lng = $(result).children('#result_lng');
        createExploreMarker(parseFloat(lat.val()), parseFloat(lng.val()), result.id);
    });
    showExploreMarkers();
}

function createExploreMarker(lat, lng, resultID){
    var marker = markerManager.addMarker(lat, lng);
    marker.resultID_ = resultID;

    $('#' + resultID).mouseenter(function() {
        if(selectedMarker != null && selectedMarker != marker){
            selectedMarker.setIcon("/images/map_pin.png");
        }
        selectedMarker = marker;
        marker.setIcon("/images/ico-pin-selected.png");
        
    });

    $('#' + resultID).mouseleave(function() {
        if(selectedMarker != null){
            selectedMarker.setIcon("/images/map_pin.png");
        }
        selectedMarker = null;
    });

    google.maps.event.addListener(marker, 'click', function() {

        if(selectedMarker != null && selectedMarker != this) {
            console.log(selectedMarker.clusterdMarkers_);
            $.each(selectedMarker.clusteredMarkers_, function(mkr, i) {
                selectedMarker.setIcon("/images/map_pin.png");
            });
        }
        
        selectedMarker = this;
        this.setIcon("/images/ico-pin-selected.png");

        $('.result').css('background-color', '');
        //$('.result-arrow').addClass('hidden');

        for(var i = 0; i < this.clusteredMarkers_.length; i++) {
            var myMarker = this.clusteredMarkers_[i];            
            var myResult = $('#' + myMarker.resultID_);
            myResult.css('background-color', '#4f4f4d');
            //  myResult.find('.result-arrow').removeClass('hidden');
            $('#results_list').prepend(myResult);
            $('#results_container').data('jsp').scrollToY(0);
        }
    });

}
function clearExploreMarkers(){
    markerManager.deleteAllMarkers();
}
function hideExploreMarkers(){
}
function showExploreMarkers(){
    markerManager.showAllMarkers();
}