var geocoder = new google.maps.Geocoder();
var exploreMarkerArr = [];
var exploreEventTypeTimer;
var exploreUpdateTimer;
var selectedResult;
var selectedMarkerArr = [];
var markerSlideShowInterval;

$(function(){
    //Cleanup function on leaving the page
    cleanUpSelf = function() {
        $('#notify_me_btn').addClass('hidden');
        for(var i = 0; i < selectedMarkerArr.length; i++)
            selectedMarkerArr[i].label_.setMap(null);
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
    if(exploreUpdateTimer){
        clearTimeout(exploreUpdateTimer);
        delete exploreUpdateTimer
    }

    exploreUpdateTimer = setTimeout(function(){
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
    }, 300);
}


function refreshExploreResults(){
    $('#explore_search_params').submit();
    if(history && history.pushState) {
        history.pushState(null, "", '?' + $('#explore_search_params').serialize());
    }
}

function addExploreMarkers(){
    var selectedResults = $('#selected_results').val();
    var selectedResultsArr = selectedResults.split(',');    

    var newSelectedMarkerArr = [];

    $.each($('#results_list .result'), function(index, result){
        var lat = $(result).children('#result_lat');
        var lng = $(result).children('#result_lng');
        var iconSrc = $(result).children('.result-image').children('img').attr('src');
        
        var marker = createExploreMarker(parseFloat(lat.val()), parseFloat(lng.val()), iconSrc, result.id);

        for(var i = 0; i < selectedResultsArr.length; i++){
            if(selectedResultsArr[i] == result.id){
                selectResult($(result));

                newSelectedMarkerArr.push(marker);
            }
        }
    });

    removeSelectedPinState();

    showExploreMarkers(function(){
        var startTimer = false;

        for(var i = 0; i < newSelectedMarkerArr.length; i++){
            var myMarker = newSelectedMarkerArr[i].ownerMarker_;
            
            if($.inArray(myMarker, selectedMarkerArr) < 0){
                selectedMarkerArr.push(myMarker);
                myMarker.setIcon("/images/marker-base.png");
                myMarker.label_.setIcon(newSelectedMarkerArr[i].iconSrc_);
                myMarker.label_.setMap(map);
                myMarker.setShadow(new google.maps.MarkerImage('/images/icon-shadow.png', null, null, new google.maps.Point(17,55)));
            }
            else{
                if(null == myMarker.clusteredIcons_){
                    myMarker.clusteredIcons_ = [];
                    myMarker.clusteredIcons_.push(myMarker.iconSrc_);
                    myMarker.slideShowCount_ = 0;
                }
                myMarker.clusteredIcons_.push(newSelectedMarkerArr[i].iconSrc_);

                startTimer = true;
            }
        }

        if(startTimer){
            markerSlideShowInterval = setInterval(function(){
                for(var i = 0; i < selectedMarkerArr.length; i++){
                    var myMarker = selectedMarkerArr[i];
                    if(null != myMarker.clusteredIcons_){
                        myMarker.label_.setIcon(myMarker.clusteredIcons_[myMarker.slideShowCount_]);
                        myMarker.slideShowCount_ += 1;
                        if(myMarker.slideShowCount_ >= myMarker.clusteredIcons_.length)
                            myMarker.slideShowCount_ = 0;
                    }
                }
            }, 1000);
        }
    });
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

        removeSelectedPinState();
        unselectResults();

        selectResult($(this));

        var myMarker = marker.ownerMarker_;
        selectedMarkerArr.push(myMarker);
        
        myMarker.setIcon("/images/marker-base.png");
        myMarker.label_.setIcon(marker.iconSrc_);
        myMarker.label_.setMap(map);
        myMarker.setShadow(new google.maps.MarkerImage('/images/icon-shadow.png', null, null, new google.maps.Point(17,55)));
    });

    $('#' + resultID).mouseleave(function() {
        if($(this).hasClass('selected-result'))
            return;

        removeSelectedPinState();
        unselectResults();
    });

    google.maps.event.addListener(marker, 'click', function() {
        removeSelectedPinState();
        unselectResults();
        selectMarker(this);
    });
    google.maps.event.addListener(map, 'click', function(){
        removeSelectedPinState();
        unselectResults();
    });

    return marker;
}

function removeSelectedPinState(){
    for(var i = 0; i < selectedMarkerArr.length; i++){
        selectedMarkerArr[i].setIcon("/images/grey-pin.png");
        selectedMarkerArr[i].setShadow(new google.maps.MarkerImage('/images/pin-shadow.png', null, null, new google.maps.Point(0,26)));
        selectedMarkerArr[i].label_.setMap(null);
        delete selectedMarkerArr[i].clusteredIcons_
    }
    delete selectedMarkerArr;
    selectedMarkerArr = [];

    if(markerSlideShowInterval != null){
        clearTimeout(markerSlideShowInterval);
    }
}
function selectMarker(marker){
    //Set icon of selected marker
    selectedMarkerArr.push(marker);
    marker.setIcon("/images/marker-base.png");
    marker.setShadow(new google.maps.MarkerImage('/images/icon-shadow.png', null, null, new google.maps.Point(17,55)));
    marker.label_.setMap(map);

    //Clear any existing timer
    if(markerSlideShowInterval != null){
        clearTimeout(markerSlideShowInterval);
    }
    //If marker is clustered, start timer to loop through icons
    if(marker.clusteredMarkers_.length > 1){
        var count = 0;
        markerSlideShowInterval = setInterval(function(){
            if($.inArray(marker, selectedMarkerArr) < 0){
                clearTimeout(markerSlideShowInterval);
                return;
            }
            marker.label_.setIcon(marker.clusteredMarkers_[count].iconSrc_);
            count += 1;
            if(count >= marker.clusteredMarkers_.length)
                count = 0;
        }, 1000);
    }

    //Select any results clustered in this pin, reorder to top, show invite/join btn, scroll to top of list
    for(var i = 0; i < marker.clusteredMarkers_.length; i++) {
        var myMarker = marker.clusteredMarkers_[i];
        var myResult = $('#' + myMarker.resultID_);

        selectResult(myResult);

        if(myResult.closest('#promoted_events').length < 1)
            $('#search_results').prepend(myResult);
    }

    var api = $('#results_container').data('jsp');
    if(api)
        api.scrollToY(0);
}

function selectResult(result){
    result.addClass('selected-result').addClass('container');
    result.find('.result-join-btn-holder').removeClass('hidden');

    var resultID = result[0].id;//.split('_')[1];
    var selected_results = $('#selected_results').val();

    if(selected_results.indexOf(resultID) < 0)
        $('#selected_results').val((selected_results.length > 0 ? (selected_results + ',') : '') + resultID);

    if(history && history.pushState) {
        history.pushState(null, "", '?' + $('#explore_search_params').serialize());
    }
}

function unselectResults(){
    //Remove highlight result and invite/join btn of previously selected result
    $('.selected-result').find('.result-join-btn-holder').addClass('hidden');
    $('.selected-result').removeClass('container').removeClass('selected-result');

    $('#selected_results').val('');

    if(history && history.pushState) {
        history.pushState(null, "", '?' + $('#explore_search_params').serialize());
    }
}

function clearExploreMarkers(){
    for(var i = 0; i < selectedMarkerArr.length; i++)
        selectedMarkerArr[i].label_.setMap(null);

    markerManager.deleteAllMarkers();

    if(markerSlideShowInterval != null){
        clearTimeout(markerSlideShowInterval);
    }
}
function showExploreMarkers(callbackFunction){
    markerManager.showAllMarkers(callbackFunction);
}