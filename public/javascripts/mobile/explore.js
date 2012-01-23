var selectedMarkerArray = [];
var markerInterval;

var usersCurrentLocation;
var map_center;
var geocoder = new google.maps.Geocoder();
var exploreMap;
var markerManager;
var marker;
var iconClass;
var clustered_markers = [];

$('#explore_base').live("pageinit", function(){
    setupListeners();
});

$('#map-view-explore').live("pageinit", function() {

    usersCurrentLocation = $('#users-current-location').val().split(",");
    map_center = new google.maps.LatLng((parseFloat(usersCurrentLocation[0])), parseFloat(usersCurrentLocation[1]));

    map_zoom = 12;
    if($('#explore_map_zoom').val().length > 0)
        map_zoom = parseInt($('#explore_map_zoom').val(), 10);


    map_options = {
        center: map_center,
        zoom: map_zoom,
        disableDefaultUI: true
    };

    if(userAgent.match("BlackBerry") != null) {
        $.extend(map_options,
        {
            panControl: true,
            zoomControl: true,
            zoomControlOptions: {
                style: google.maps.ZoomControlStyle.SMALL,
                position: google.maps.ControlPosition.RIGHT_TOP
            }
        });
    }

    $('#explore_map_canvas').gmap(map_options);
      
    exploreMap = $('#explore_map_canvas').gmap('get', 'map');

    var bounds = $('#explore_map_bounds').val();
    bounds = bounds.split(',')
    neBounds = new google.maps.LatLng(parseFloat(bounds[0]), parseFloat(bounds[1]));
    swBounds = new google.maps.LatLng(parseFloat(bounds[2]), parseFloat(bounds[3]));
//    if(!exploreMap.getBounds().contains(neBounds) || !exploreMap.getBounds().contains(swBounds))
    exploreMap.fitBounds(new google.maps.LatLngBounds(swBounds, neBounds));

    markerManager = new MarkerManager({
        map: exploreMap
    });

    addExploreMarkers();

    $('#explore_event_details').hide();

    google.maps.event.addListener(exploreMap, 'zoom_changed', function(){
        changeExploreLocationParams();
    });
    google.maps.event.addListener(exploreMap, 'dragend', function(){
        changeExploreLocationParams();
    });
    google.maps.event.addListener(exploreMap, 'click', function(){
        deselectMarker();
    });
});

$('#explore_filter').live("pageshow",function() {
    var keyword = "";
    $('#filter_no_results').hide();
    $('.synonym').addClass('hidden');
    $('input[data-type="search"]').val("");

    $('.ui-input-text').live('keyup', function(){
        keyword = $.trim($(this).val());
        $('#filter_no_results a span').text(keyword);
        if(keyword.length == 0){
            //reset results
            $('#filter_no_results').hide();
            $('.synonym').hide();
        }
        else{
            var exactMatch = false;
            var trimmedText = unescape(keyword);
            var regEx = new RegExp(trimmedText, "i");
            var lowerCaseText = trimmedText.toLowerCase();

            $.each($('.result'), function(index, val){
                $et = $(val);
                if($.trim($et.text()).match(regEx) == null){
                    $et.hide();
                }
                else{
                    $et.show();

                    if($.trim($et.text()).toLowerCase() == lowerCaseText){
                        exactMatch = true;
                    }
                }
            });

            if(exactMatch){
                $('#filter_no_results').hide();
            }
            else{
                $('#filter_no_results').show();
            }
        }
    });
});

function setupListeners(){
    $('.list_view_link').live("click", function() {
        $('.list_view_results').listview();
    });

    $('#remove_filters').live('click', function(e){
        $('#keyword').val("");
        $('#list_view_filter_text').css('display', 'none');

        $('#explore_form').submit();
        refreshResults();
        //$('#list_view_results').listview();
        e.preventDefault();

    });

    $('#keyword_filter_list li').live('click', function(e){
        selKeyword = $.trim($(this).text());
        $('#keyword').val(selKeyword);

        $('#list_view_filter_text span').text(selKeyword);
        $('#list_view_filter_text').css('display', '');
        $('#explore_form').submit();
        refreshResults();

        e.preventDefault(); // Prevent link from following its href
    });

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
}


function refreshResults() {
    $('.list_view_results').listview();
}

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
        var zoom = exploreMap.getZoom();

        bounds = exploreMap.getBounds();
        ne = bounds.getNorthEast();
        sw = bounds.getSouthWest();
        c = bounds.getCenter();

        $('#explore_map_bounds').val(ne.lat() + ',' + ne.lng() + ',' + sw.lat() + ',' + sw.lng());
        $('#explore_map_center').val(c.lat() + ',' + c.lng());
        $('#explore_map_zoom').val(zoom);
        $('#explore_view_params').val("map");
        updateUserLocation(c.lat(), c.lng(), false);
        $('#explore_form').submit();
        refreshResults();

    }, 20);
}

function addExploreMarkers(){
    var selectedResults = $('#selected_results').val();
    var selectedResultsArr = []
    if(selectedResults)
        selectedResultsArr = selectedResults.split(',');

    var mySelectedMarkersArray = [];
    $.each($('#list_view_explore_content li'), function(index, result){
        $result = $(result);
        var lat = parseFloat($result.find('.lat').val(),10);
        var lng = parseFloat($result.find('.lng').val(),10);
        var iconClass = $result.find('.icon-class').val();
        var id = result.id

        var marker = createExploreMarker(lat, lng, id, iconClass);

        for(var i = 0; i < selectedResultsArr.length; i++){
            if(selectedResultsArr[i] == result.id){
                mySelectedMarkersArray.push(marker);
            }
        }
    });

    markerManager.showAllMarkers();

    $.each(mySelectedMarkersArray, function(index, marker){
        selectMarker(marker);
    });
}

function getMarkerManager() {
    return markerManager;
}


function createExploreMarker(lat, lng, eventID, iconClass){
    marker = markerManager.addMarker(lat, lng);
    marker.eventID_ = eventID;
    marker.iconClass_ = 'event-type-'+iconClass+'-small-sprite';
    marker.label_ = new IconLabel(marker);
    marker.label_.bindTo('position', marker, 'position');
    marker.label_.setIconClass('event-type-'+iconClass+'-small-sprite');
    google.maps.event.addListener(marker, 'click', function(){
        deselectMarker();
        selectMarker(this);
    });

    return marker;
}  

function selectMarker(marker){
    //Show results clustered in this pin
    if(marker.clusteredMarkers_){
        for(var i = 0; i < marker.clusteredMarkers_.length; i++){
            var eventID = marker.clusteredMarkers_[i].eventID_;
            $('#' + eventID).clone().removeAttr('id').appendTo('#display_results');

            //Select result
            var selectedResults = $('#selected_results').val();
            if(selectedResults.indexOf(eventID) < 0){
                $('#selected_results').val((selectedResults.length > 0 ? (selectedResults + ',') : '') + eventID);
            }
        }
    }
    $('#display_results').listview('refresh');
    refresh_iScrollers();

    $('#explore_event_details').show();

    //Set marker icon
    selectedMarkerArray.push(marker);
    marker.ownerMarker_.setIcon("/images/marker-base.png");
    marker.ownerMarker_.setShadow(new google.maps.MarkerImage('/images/icon-shadow.png', null, null, new google.maps.Point(17,55)));
    marker.ownerMarker_.label_.setIconClass(marker.iconClass_);
    marker.ownerMarker_.label_.setMap(exploreMap);

    if(markerInterval != null){
        clearTimeout(markerInterval);
    }
    if(marker.clusteredMarkers_ && marker.clusteredMarkers_.length > 1){
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

function clearExploreMarkers(){
    for(var i = 0; i < selectedMarkerArray.length; i++)
        if(selectedMarkerArray[i] != undefined)
            selectedMarkerArray[i].label_.setMap(null);

    markerManager.deleteAllMarkers();
    delete selectedMarkerArray
    selectedMarkerArray = [];

    if(markerInterval != null)
        clearTimeout(markerInterval);

}

function deselectMarker() {
    $('#explore_event_details').hide();
    $('#display_results').empty();

    $('#selected_results').val('');

    for(var i = 0; i < selectedMarkerArray.length; i++){
        if(selectedMarkerArray[i] != undefined){
            selectedMarkerArray[i].label_.setMap(null);
            selectedMarkerArray[i].setIcon("/images/grey-pin.png");
            selectedMarkerArray[i].setShadow(new google.maps.MarkerImage('/images/pin-shadow.png', null, null, new google.maps.Point(0,26)));
        }
    }
}  