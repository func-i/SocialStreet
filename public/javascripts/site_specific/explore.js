var geocoder = new google.maps.Geocoder();
var exploreMarkerArr = [];
var exploreEventTypeTimer;
var exploreUpdateTimer;
var selectedResult;
var selectedMarker;
var markerSlideShowInterval;
var lockMouseOver = false;

$(function(){
    //Cleanup function on leaving the page
    cleanUpSelf = function() {
        $('#notify_me_btn').addClass('hidden');
        if(selectedMarker != null)
            selectedMarker.label_.setMap(null);
    }

    resizeSelf = function(){
        resizeCenterPaneContent();
        resizeResultButtons();
    }

    $('.result-attendees-image').live('mouseenter', function(){
        $(this).siblings('div').removeClass('hidden');
    }
    ).live('mouseleave', function(){
        $(this).siblings('div').addClass('hidden');
    });
    
    //Setup the explore page
    setupExplorePage();    
});

function resizeCenterPaneContent(){
    var centerPaneBottom = $('#center_pane').offset().top + $('#center_pane').height();
    var scrollerTop = $('#event_types_scroller').offset().top;
    $('#event_types_scroller').height(centerPaneBottom - scrollerTop);
}
function resizeResultButtons(){    
    if($('.jspVerticalBar').length > 0){
        $('.result-join-btn-holder').css('right', '5px');
    }
    else{
        $('.result-join-btn-holder').css('right', '20px');
    }
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

    resizePageElements();
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
    var zoom = map.getZoom();
    $('#map_zoom').val(zoom);
    var bounds = map.getBounds();

    var projection = markerManager.projectionHelper_.getProjection();

    var bl = bounds.getSouthWest();
    var blPix = projection.fromLatLngToDivPixel(bl);
    blPix.x += $('#left_side_pane').offset().left + $('#left_side_pane').width();

    var tr = bounds.getNorthEast();
    var trPix = projection.fromLatLngToDivPixel(tr);
    trPix.y += 76;//Selected Marker height

    var sw = projection.fromDivPixelToLatLng(blPix);
    var ne = projection.fromDivPixelToLatLng(trPix);

    $('#map_bounds').val(ne.lat() + ',' + ne.lng() + ',' + sw.lat() + ',' + sw.lng());
    $('#map_center').val(map.getCenter().lat() + "," + map.getCenter().lng());

    updateUserLocation(map.getCenter().lat(), map.getCenter().lng(), zoom, sw.lat(), sw.lng(), ne.lat(), ne.lng(), true);
    
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
        var iconSrc = $(result).children('.result-image').children('img').attr('src');
        createExploreMarker(parseFloat(lat.val()), parseFloat(lng.val()), iconSrc, result.id);
    });
    showExploreMarkers();
}

function createExploreMarker(lat, lng, iconSrc, resultID){
    var marker = markerManager.addMarker(lat, lng);

    marker.iconSrc_ = iconSrc;
    marker.label_ = new IconLabel();
    marker.label_.bindTo('position', marker, 'position');
    marker.label_.setIcon(iconSrc);

    marker.resultID_ = resultID;

    $('#' + resultID).mouseenter(function() {
        if($(this).hasClass('selected-result'))
            return;

        $(this).find('.result-join-btn-holder').removeClass('hidden');
        $('.selected-result').find('.result-join-btn-holder').addClass('hidden');
        
        $('.selected-result').removeClass('container').removeClass('selected-result');
        $(this).addClass('container').addClass('selected-result');

        if(selectedMarker != null && selectedMarker != marker.ownerMarker_){
            selectedMarker.setIcon("/images/grey-pin.png");
            selectedMarker.setShadow(new google.maps.MarkerImage('/images/pin-shadow.png', null, null, new google.maps.Point(0,26)));
            selectedMarker.label_.setMap(null);
        }

        selectedMarker = marker.ownerMarker_;
        
        selectedMarker.setIcon("/images/marker-base.png");
        selectedMarker.label_.setIcon(marker.iconSrc_);
        selectedMarker.label_.setMap(map);
        selectedMarker.setShadow(new google.maps.MarkerImage('/images/icon-shadow.png', null, null, new google.maps.Point(17,55)));

        if(markerSlideShowInterval != null){
            clearTimeout(markerSlideShowInterval);
        }
    });

    $('#' + resultID).mouseleave(function() {
        if($(this).hasClass('selected-result'))
            return;        

        if(selectedMarker != null){
            selectedMarker.setIcon("/images/grey-pin.png");
            selectedMarker.setShadow(new google.maps.MarkerImage('/images/pin-shadow.png', null, null, new google.maps.Point(0,26)));
            selectedMarker.label_.setMap(null);
        }
        selectedMarker = null;

        if(markerSlideShowInterval != null){
            clearTimeout(markerSlideShowInterval);
        }

    });

    google.maps.event.addListener(marker, 'click', function() {
        selectMarker(this);
        lockMouseOver = true;
    });
    /*    google.maps.event.addListener(marker, 'mouseover', function() {
        if(!lockMouseOver)
            selectMarker(this);
    });*/
    google.maps.event.addListener(map, 'click', function(){
        removeSelectedPinState();
        lockMouseOver = false;
    })
}

function removeSelectedPinState(){
    if(selectedMarker != null){
        selectedMarker.setIcon("/images/grey-pin.png");
        selectedMarker.setShadow(new google.maps.MarkerImage('/images/pin-shadow.png', null, null, new google.maps.Point(0,26)));
        selectedMarker.label_.setMap(null);
    }
    selectedMarker = null;

    if(markerSlideShowInterval != null){
        clearTimeout(markerSlideShowInterval);
    }

    $('.selected-result').find('.result-join-btn-holder').addClass('hidden');
    $('.selected-result').removeClass('container').removeClass('selected-result');
}
function selectMarker(marker){
    if(selectedMarker != null && selectedMarker != marker) {
        selectedMarker.setIcon("/images/grey-pin.png");
        selectedMarker.setShadow(new google.maps.MarkerImage('/images/pin-shadow.png', null, null, new google.maps.Point(0,26)));
        selectedMarker.label_.setMap(null);
    }

    selectedMarker = marker;
    selectedMarker.setIcon("/images/marker-base.png");
    selectedMarker.setShadow(new google.maps.MarkerImage('/images/icon-shadow.png', null, null, new google.maps.Point(17,55)));
    selectedMarker.label_.setMap(map);

    if(markerSlideShowInterval != null){
        clearTimeout(markerSlideShowInterval);
    }
    if(selectedMarker.clusteredMarkers_ != null){
        var count = 0;
        markerSlideShowInterval = setInterval(function(){
            if(!selectedMarker){
                clearTimeout(markerSlideShowInterval);
                return;
            }
            selectedMarker.label_.setIcon(selectedMarker.clusteredMarkers_[count].iconSrc_);
            count += 1;
            if(count >= selectedMarker.clusteredMarkers_.length)
                count = 0;
        }, 1000);
    }

    $('.selected-result').find('.result-join-btn-holder').addClass('hidden');
    $('.selected-result').removeClass('container').removeClass('selected-result');

    for(var i = 0; i < selectedMarker.clusteredMarkers_.length; i++) {
        var myMarker = selectedMarker.clusteredMarkers_[i];
        var myResult = $('#' + myMarker.resultID_);
        myResult.addClass('selected-result').addClass('container');
        $('.selected-result').find('.result-join-btn-holder').removeClass('hidden');

        if(myResult.closest('#promoted_events').length < 1)
            $('#search_results').prepend(myResult);

        var api = $('#results_container').data('jsp');
        if(api)
            api.scrollToY(0);
    }
}
function clearExploreMarkers(){
    if(selectedMarker != null)
        selectedMarker.label_.setMap(null);

    markerManager.deleteAllMarkers();

    if(markerSlideShowInterval != null){
        clearTimeout(markerSlideShowInterval);
    }
}
function showExploreMarkers(){
    markerManager.showAllMarkers();
}