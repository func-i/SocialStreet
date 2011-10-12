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
        if(selectedMarker != null && selectedMarker != marker.ownerMarker_){
            selectedMarker.setIcon("/images/green-pin.png");
            selectedMarker.label_.setMap(null);
        }

        selectedMarker = marker.ownerMarker_;
        
        selectedMarker.setIcon("/images/marker-base.png");
        selectedMarker.label_.setIcon(marker.iconSrc_);
        selectedMarker.label_.setMap(map);
    });

    $('#' + resultID).mouseleave(function() {
        if(selectedMarker != null){
            selectedMarker.setIcon("/images/green-pin.png");
            selectedMarker.label_.setMap(null);
        }
        selectedMarker = null;
    });

    google.maps.event.addListener(marker, 'click', function() {
        if(selectedMarker != null && selectedMarker.clusteredMarkers_ != null && selectedMarker != this) {
            $.each(selectedMarker.clusteredMarkers_, function(mkr, i) {
                selectedMarker.setIcon("/images/green-pin.png");
                selectedMarker.label_.setMap(null);
            });
        }
        
        selectedMarker = this;
        this.setIcon("/images/marker-base.png");
        this.label_.setMap(map);

        $('.result').css('background-color', '');

        for(var i = 0; i < this.clusteredMarkers_.length; i++) {
            var myMarker = this.clusteredMarkers_[i];            
            var myResult = $('#' + myMarker.resultID_);
            myResult.css('background-color', '#4f4f4d');
            $('#results_list').prepend(myResult);
            $('#results_container').data('jsp').scrollToY(0);
        }
    });

}
function clearExploreMarkers(){
    if(selectedMarker != null)
        selectedMarker.label_.setMap(null);

    markerManager.deleteAllMarkers();
}
function showExploreMarkers(){
    markerManager.showAllMarkers();
}


// Define the overlay, derived from google.maps.OverlayView
function IconLabel(opt_options) {
    // Initialization
    this.setValues(opt_options);

    // Here go the label styles
    this.div_ = document.createElement('div');
    this.div_.style.cssText = 'position: absolute;';

    this.image_ = document.createElement('img');
    this.image_.src = '/images/event_types/streetmeet5.png';
    this.image_.style.cssText = "width:50px;height:50px";
    this.div_.appendChild(this.image_);
};

IconLabel.prototype = new google.maps.OverlayView;

IconLabel.prototype.onAdd = function() {
    var pane = this.getPanes().overlayImage;
    pane.appendChild(this.div_);

    // Ensures the label is redrawn if the text or position is changed.
    var me = this;
    this.listeners_ = [
    google.maps.event.addListener(this, 'position_changed',
        function() {
            me.draw();
        }),
    google.maps.event.addListener(this, 'text_changed',
        function() {
            me.draw();
        }),
    google.maps.event.addListener(this, 'zindex_changed',
        function() {
            me.draw();
        })
    ];
};

IconLabel.prototype.onRemove = function() {
    this.div_.parentNode.removeChild(this.div_);

    // Label is removed from the map, stop updating its position/text.
    for (var i = 0, I = this.listeners_.length; i < I; ++i) {
        google.maps.event.removeListener(this.listeners_[i]);
    }
};

// Implement draw
IconLabel.prototype.draw = function() {
    var projection = this.getProjection();

    var position = projection.fromLatLngToDivPixel(this.get('position'));
    var div = this.div_;
    div.style.display = 'block';

    div.style.left = (position.x - 25) + 'px';//25 for half the width of the icon
    div.style.top = (position.y - 78) + 'px';//50 for height of icon, 34 for height of base, -6 to get it to sit on base
};

IconLabel.prototype.setIcon = function(iconSrc){
    this.image_.src = iconSrc;
};