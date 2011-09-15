var map;
var toronto = new google.maps.LatLng(43.7427662, -79.3922001);
var geocoder = new google.maps.Geocoder();
var exploreMarkerArr = [];
var exploreEventTypeTimer;
var exploreUpdateTimer;
var showMarker = null;

//ALL Change of pages bindings
$(function(){
    $('.logo').click(function(){
        changePage('explore');
    });

    $('.result-event-link').live('click',function(){
        changePage('show_event', [$(this).parent().parent()]);
    });

    $('#add_streetmeet_btn').click(function(){
        changePage('create_event_what');
    });

    $('#create_what_next_arrow').click(function(){
        changePage('create_event_where');
    });

    $('#create_where_next_arrow').click(function(){
        changePage('create_event_when');
    });
});

function changePage(page_name, option_arr){
    cleanupBeforeLeaving();

    $('#current_page_name').val(page_name);

    hide_all_overlays();

    if(page_name == "explore"){
        setup_explore_page();

        $('#results_list_overlay').removeClass('hidden');
    }
    else if(page_name == "show_event"){
        setup_show_event(option_arr[0]);

        $('#event_overlay').removeClass('hidden');
    }
    else if(page_name == "create_event_what"){
        setup_create_event();
        
        $('#create_overlay').removeClass('hidden');
        $('#create_what').removeClass('hidden');
    }
    else if(page_name == "create_event_where"){
        setup_create_where();
        
        $('#create_overlay').removeClass('hidden');
        $('#create_where').removeClass('hidden');
    }
    else if(page_name == "create_event_when"){
        $('#create_overlay').removeClass('hidden');
        $('#create_when').removeClass('hidden');
    }
}

function cleanupBeforeLeaving(){
    var page_name = $('#current_page_name').val();
    if(page_name == "explore"){
        hideExploreMarkers();
    }
    else if(page_name == "show_event"){
        showMarker.setMap(null);
    }
    else if(page_name == "create_event_where"){
        $.each(createEventMarkerArr, function(index, marker){
            marker.setMap(null);
            delete marker;
        });
        delete createEventMarkerArr
    }
}


function hide_all_overlays(){
    $.each($('.overlay-group'), function(index, value){
        $(value).addClass('hidden');
    });
}


//All startup functions
$(function(){
    init_map();
    init_explore();
});

function init_map(){
    var mapCenter = $('#map_center').val();
    var loc = toronto;
    if(undefined != mapCenter && mapCenter.length > 0){
        var loc_params = mapCenter.split(',');
        if(loc_params.length == 2)
            loc = new google.maps.LatLng(loc_params[0], loc_params[1]);
    }

    console.log(mapCenter);

    var mapZoom = $('#map_zoom').val();
    var zoom = 13;
    if(undefined != mapZoom && mapZoom.length > 0){
        zoom = parseInt(mapZoom, 10);
    }

    var myOptions = {
        zoom: zoom,
        center: loc,
        mapTypeControl: false,
        mapTypeId: google.maps.MapTypeId.ROADMAP,
        streetViewControl: false,
        panControl: false,
        rotateControl: false,
        scaleContol: false,
        zoomControl: true,
        zoomControlOptions: {
            position: google.maps.ControlPosition.RIGHT_TOP,
            style: google.maps.ZoomControlStyle.DEFAULT
        }
    };
    map = new google.maps.Map(document.getElementById('location-map'), myOptions);

    google.maps.event.addListener(map, 'dragend', function(){
        updateExploreLocationParams();
    });
    google.maps.event.addListener(map, 'bounds_changed', function(){
        updateExploreLocationParams();
    });
}



function init_explore(){
    add_explore_markers();

    $('#explore_keyword_text_field').focus(function(){
        $('#explore_keyword_event_types_holder').removeClass('hidden');
    });
    
    $(document).bind("click", function(e){
        if($(e.target).closest('#explore_keyword_text_field_holder').length < 1 && $(e.target).closest('#explore_keyword_event_types_holder').length < 1 )
        {
            $('#explore_keyword_event_types_holder').addClass('hidden');
            $('#explore_keyword_text_field').blur();
        }
    });

    $('.explore-keyword-event-type').live('click', function(){
        explore_eventType_is_clicked(this);
    });

    $('#explore_keyword_text_field').keyup(function(e){
        filter_explore_keyword_icons(e.target.value);
    });

}

function filter_explore_keyword_icons(search_text){
    if (exploreEventTypeTimer) {
        clearInterval(exploreEventTypeTimer);
        delete exploreEventTypeTimer;
    }
    exploreEventTypeTimer = setTimeout(function() {
        var regEx = new RegExp(search_text);
        var exact_match = false;

        //Filter the event_type list by the text entered
        $.each($('.explore-keyword-event-type-name'), function(index, value){
            var myEventName = $(value);
            if(myEventName.text().trim().match(regEx) == null){
                myEventName.parent().addClass('hidden');
            }
            else{
                myEventName.parent().removeClass('hidden');

                exact_match = exact_match || myEventName.text().trim() == search_text;
            }
        });

        if(!exact_match && search_text.length > 0){
            var customType = $('#explore_keyword_event_types_holder #explore_keyword_custom_event_type');
            if(customType.length > 0){
                customType.children('.explore-keyword-event-type-name').text(search_text);
            }
            customType.removeClass('hidden');
        }
        else{
            $('#explore_keyword_event_types_holder #explore_keyword_custom_event_type').addClass('hidden');
        }

    }, 250);
}

function explore_eventType_is_clicked(record){
    var eventType_record = $(record);
    var eventType_name = eventType_record.children('.explore-keyword-event-type-name').text().trim();

    if(eventType_record.parent().attr('id') == 'explore_keyword_tag_list')
    {
        eventType_record.remove();
    }
    else
    {
        if(!does_explore_keyword_already_exist(eventType_name))
        {
            var new_tag_record = $($('#explore_keyword_tag_stamp').clone());
            new_tag_record.id = "";
            new_tag_record.find('img').attr('src', eventType_record.find('img').attr('src'));
            new_tag_record.find('.explore-keyword-tag-name').text(eventType_name);
            $('#explore_keyword_tag_list').append(new_tag_record);
            new_tag_record.removeClass('hidden');

            $('#explore_search_params').append(
                '<input type="hidden" name="keywords[]" value="' + eventType_name + '" />'
                );
                    
            refresh_explore_results();
        }

        $('#explore_keyword_event_types_holder').addClass('hidden');
        $.each($('.explore-keyword-event-type-name'), function(index, value){
            $(value).parent().removeClass('hidden');
        });
        $('#explore_keyword_text_field').val('');
    }
}

function does_explore_keyword_already_exist(eventType_name){
    var rtn = false;
    $.each(
        $('#explore_keyword_tag_list .explore-keyword-tag-name'),
        function(index, value){
            if($(value).text().trim() == eventType_name)
                rtn = true;
        }
        );
    return rtn;
}

function setup_explore_page(){
    var mapCenter = $('#map_center').val();
    var mapCenterArr = mapCenter.split(",");
    map.setCenter(new google.maps.LatLng(parseFloat(mapCenterArr[0]), parseFloat(mapCenterArr[1])));
    map.setZoom(parseInt($('#map_zoom').val()));

    if(exploreMarkerArr.length < 1){
        console.log("Refreshing in setup")
        refresh_explore_results();
    }
    else{
        showExploreMarkers();
    }

    toggle_suggested_actions();
}

function toggle_suggested_actions(){
    if(exploreMarkerArr.length < 5){
        $('#suggested_actions').removeClass('hidden');
    }
    else{
        $('#suggested_actions').addClass('hidden');
    }
}
function setup_show_event(result_dom){
    //Fill in the event details
    var target_dom = $('#show_event_details');
    target_dom.find('.result-image').html(result_dom.find('.result-image').html());
    target_dom.find('.result-title').html(result_dom.find('.result-title').html());
    var start_date = result_dom.find('#start_date').val();
    var end_date = result_dom.find('#end_date').val()
    target_dom.find('.result-date').html("When: " + start_date + " - " + end_date);
    target_dom.find('.result-tags').html("Tags: " + result_dom.find('#tags').val());
    target_dom.find('.result-description').html(result_dom.find('#description').val());

    //TODO retrieve wall and invites from server

    //Place marker
    var lat = result_dom.find('#result_lat');
    var lng = result_dom.find('#result_lng');
    var marker = createShowMarker(lat.val(), lng.val());
    map.setCenter(marker.getPosition());
    map.setZoom(15);
}

function createShowMarker(lat, lng){
    var marker = new google.maps.Marker(
    {
        position: new google.maps.LatLng(lat, lng)
    });
    marker.setMap(map);

    showMarker = marker;

    google.maps.event.addListener(marker, 'click', function(latlng){
        //TODO
        });

    return marker;
}

function start_explore(){
    showExploreMarkers();
}

function updateExploreLocationParams(){
    var page_name = $('#current_page_name').val();
    if(page_name == "explore"){
        $('#map_zoom').val(map.getZoom());
        var bounds = map.getBounds();
        $('#map_bounds').val(bounds.getNorthEast().lat() + ',' + bounds.getNorthEast().lng() + ',' + bounds.getSouthWest().lat() + ',' + bounds.getSouthWest().lng());
        $('#map_center').val(map.getCenter().lat() + ',' + map.getCenter().lng());

        refresh_explore_results();
    }
}

function add_explore_markers(){
    $.each($('#results_list_overlay .result'), function(index, result){
        var lat = $(result).children('#result_lat')
        var lng = $(result).children('#result_lng')
        createExploreMarker(parseFloat(lat.val()), parseFloat(lng.val()));
    });
}
function refresh_explore_results(){
    $('#explore_search_params').submit();
}

function createExploreMarker(lat, lng){
    var marker = new google.maps.Marker(
    {
        position: new google.maps.LatLng(lat, lng)
    });
    marker.setMap(map);

    exploreMarkerArr.push(marker);

    google.maps.event.addListener(marker, 'click', function(latlng){
        //TODO
        });

    return marker;
}

function clearExploreMarkers(){
    $.each(exploreMarkerArr, function(index, marker){
        marker.setMap(null);
    });
    delete exploreMarkerArr;
    exploreMarkerArr = [];
}

function hideExploreMarkers(){
    $.each(exploreMarkerArr, function(index, marker){
        marker.setMap(null);
    });
}

function showExploreMarkers(){
    $.each(exploreMarkerArr, function(index, marker){
        marker.setMap(map);
    });
}

