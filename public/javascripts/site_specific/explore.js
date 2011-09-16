var geocoder = new google.maps.Geocoder();
var exploreMarkerArr = [];
var exploreEventTypeTimer;
var exploreUpdateTimer;

$(function(){
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
        explore_keywords_textfield_keywdown(e);
    });

    $('.explore-keyword-tag-remove').live('click', function(){
        remove_explore_tag($(this).parent());
    });

});

function setup_explore_page(){
    $('#explore_btn').addClass('hidden');
    $('#notify_me_btn').removeClass('hidden');

    var mapCenter = $('#map_center').val();
    var mapCenterArr = mapCenter.split(",");
    map.setCenter(new google.maps.LatLng(parseFloat(mapCenterArr[0]), parseFloat(mapCenterArr[1])));
    map.setZoom(parseInt($('#map_zoom').val()));

    if(exploreMarkerArr.length < 1){
        refresh_explore_results();
    }
    else{
        showExploreMarkers();
    }

    toggle_suggested_actions();
}

function remove_explore_tag(tag_dom){
    var tag_name = tag_dom.children('.explore-keyword-tag-name').text().trim();

    $.each($('#explore_search_params input[name="keywords[]"]'), function(index, elem){
        if($(elem).val() == tag_name){
            $(elem).remove();
        }
    });

    tag_dom.remove();

    refresh_explore_results();
}

function filter_explore_keyword_icons(search_text, submit){
    if(submit == undefined){
        submit = false;
    }

    var regEx = new RegExp(search_text, "i");
    var exact_match = false;

    //Filter the event_type list by the text entered
    $.each($('.explore-keyword-event-type-name'), function(index, value){
        var myEventName = $(value);

        if(myEventName.parent('#explore_keyword_custom_event_type').length > 0){
            return true;
        }

        if(myEventName.text().trim().match(regEx) == null){
            myEventName.parent().addClass('hidden');
        }
        else{
            myEventName.parent().removeClass('hidden');

            exact_match = exact_match || myEventName.text().trim().toLowerCase() == search_text.toLowerCase();

            if(exact_match){
                var i = 0;
            }
            if(submit && exact_match){
                explore_eventType_is_clicked(myEventName.parent());
            }
        }
    });

    if(!exact_match && search_text.length > 0){
        var customType = $('#explore_keyword_event_types_holder #explore_keyword_custom_event_type');
        if(customType.length > 0){
            customType.children('.explore-keyword-event-type-name').text(search_text);
        }
        customType.removeClass('hidden');

        if(submit){
            explore_eventType_is_clicked(customType);
        }
    }
    else{
        $('#explore_keyword_event_types_holder #explore_keyword_custom_event_type').addClass('hidden');
    }
}

function explore_keywords_textfield_keywdown(e){
    if (exploreEventTypeTimer) {
        clearTimeout(exploreEventTypeTimer);
        delete exploreEventTypeTimer;
    }

    if(e.keyCode == 13){
        filter_explore_keyword_icons(e.target.value, true);
    }
    else{
        exploreEventTypeTimer = setTimeout(function() {
            filter_explore_keyword_icons(e.target.value, false);
        }, 100);
    }
}

function explore_eventType_is_clicked(record){
    var eventType_record = $(record);
    var eventType_name = eventType_record.children('.explore-keyword-event-type-name').text().trim();

    if(!does_explore_keyword_already_exist(eventType_name))
    {
        var new_tag_record = $($('#explore_keyword_tag_stamp').clone());
        new_tag_record.id = "";
        new_tag_record.find('.explore-tag-icon').attr('src', eventType_record.find('img').attr('src'));
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
    $('#explore_keyword_event_types_holder #explore_keyword_custom_event_type').addClass('hidden');
    $('#explore_keyword_text_field').val('');
    $('#explore_keyword_text_field').blur();
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

function toggle_suggested_actions(){
    if(exploreMarkerArr.length < 5){
        $('#suggested_actions').removeClass('hidden');

        if($('#explore_search_params input[name="keywords[]"]').length > 0){

    }

    }
    else{
        $('#suggested_actions').addClass('hidden');
    }
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

function refresh_explore_results(){
    $('#explore_search_params').submit();
}

function add_explore_markers(){
    $.each($('#results_list_overlay .result'), function(index, result){
        var lat = $(result).children('#result_lat')
        var lng = $(result).children('#result_lng')
        createExploreMarker(parseFloat(lat.val()), parseFloat(lng.val()));
    });
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