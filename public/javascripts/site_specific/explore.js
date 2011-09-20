var geocoder = new google.maps.Geocoder();
var exploreMarkerArr = [];
var exploreEventTypeTimer;
var exploreUpdateTimer;
var selectedResult;

$(function(){
    
    setup_explore_page();
    
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

    cleanUpSelf = function(){
        $('#explore_btn').removeClass('hidden');
        $('#notify_me_btn').addClass('hidden');
    }

});

function setup_explore_page(){
    $('#explore_btn').addClass('hidden');
    $('#notify_me_btn').removeClass('hidden');

    var mapCenter = $('#map_center').val();
    var mapCenterArr = mapCenter.split(",");
    map.panTo(new google.maps.LatLng(parseFloat(mapCenterArr[0]), parseFloat(mapCenterArr[1])));
    map.setZoom(parseInt($('#map_zoom').val()));

    create_tags_from_input_fields();

    addExploreMarkers();
    toggle_suggested_actions();
    
}

function create_tags_from_input_fields(){
    $.each($('#explore_search_params input[name="keywords[]"]'), function(index, elem){
        filter_explore_keyword_icons($(elem).val(), true, false);
    });
}

function remove_explore_tag(tag_dom){
    var tag_name = $.trim(tag_dom.children('.explore-keyword-tag-name').text());

    $.each($('#explore_search_params input[name="keywords[]"]'), function(index, elem){
        if($(elem).val() == tag_name){
            $(elem).remove();
        }
    });

    tag_dom.remove();

    refresh_explore_results();
}

function filter_explore_keyword_icons(search_text, create, submit){
    if(submit == undefined){
        submit = false;
    }
    if(create == undefined){
        create = false;
    }


    var regEx = new RegExp(search_text, "i");
    var exact_match = false;

    //Filter the event_type list by the text entered
    $.each($('.explore-keyword-event-type-name'), function(index, value){
        var myEventName = $(value);

        if(myEventName.parent('#explore_keyword_custom_event_type').length > 0){
            return true;
        }

        if($.trim(myEventName.text()).match(regEx) == null){
            myEventName.parent().addClass('hidden');
        }
        else{
            myEventName.parent().removeClass('hidden');

            exact_match = exact_match || $.trim(myEventName.text()).toLowerCase() == search_text.toLowerCase();

            if(exact_match){
                var i = 0;
            }
            if(create && exact_match){
                explore_eventType_is_clicked(myEventName.parent(), submit);
            }
        }
    });

    if(!exact_match && search_text.length > 0){
        var customType = $('#explore_keyword_event_types_holder #explore_keyword_custom_event_type');
        if(customType.length > 0){
            customType.children('.explore-keyword-event-type-name').text(search_text);
        }
        customType.removeClass('hidden');

        if(create){
            explore_eventType_is_clicked(customType, submit);
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
        filter_explore_keyword_icons(e.target.value, true, true);
    }
    else{
        exploreEventTypeTimer = setTimeout(function() {
            filter_explore_keyword_icons(e.target.value, false);
        }, 250);
    }
}

function addKeyword(keyword) {

    var eventType_record;
    $('.explore-keyword-event-type').each(function(i, ele) {
        if($(ele).children('.explore-keyword-event-type-name').text().trim() == keyword){
            eventType_record = $(ele);
        }
    });

    if(eventType_record != undefined){
        var new_tag_record = $($('#explore_keyword_tag_stamp').clone());
        var eventType_name = eventType_record.children('.explore-keyword-event-type-name').text().trim();

        new_tag_record.id = "";
        new_tag_record.find('.explore-tag-icon').attr('src', eventType_record.find('img').attr('src'));
        new_tag_record.find('.explore-keyword-tag-name').text(eventType_name);
        $('#explore_keyword_tag_list').append(new_tag_record);
        new_tag_record.removeClass('hidden');
    }
}

function explore_eventType_is_clicked(record, submit){
    if(submit == undefined) {
        submit = true;
    }

    var eventType_record = $(record);
    var eventType_name = eventType_record.children('.explore-keyword-event-type-name').text().trim();

    if(!does_explore_keyword_already_exist(eventType_name))
    {
        addKeyword(eventType_name);
        
        $('#explore_search_params').append(
            '<input type="hidden" name="keywords[]" value="' + eventType_name + '" />'
            );
    }

    $('#explore_keyword_event_types_holder').addClass('hidden');
    $.each($('.explore-keyword-event-type-name'), function(index, value){
        $(value).parent().removeClass('hidden');
    });
    $('#explore_keyword_custom_event_type').addClass('hidden');
    $('#explore_keyword_custom_event_type .explore-keyword-event-type-name').text('');
    $('#explore_keyword_text_field').val('');
    $('#explore_keyword_text_field').blur();

    if(submit){
        refresh_explore_results();
    }
}

function does_explore_keyword_already_exist(eventType_name){
    var rtn = false;
    $.each(
        $('#explore_keyword_tag_list .explore-keyword-tag-name'),
        function(index, value){
            if($.trim($(value).text()) == eventType_name)
                rtn = true;
        }
        );
    return rtn;
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
    $('#map_bounds').val(bounds.getNorthEast().lat() + ',' + bounds.getNorthEast().lng() + ',' + bounds.getSouthWest().lat() + ',' + bounds.getSouthWest().lng());
    $('#map_center').val(map.getCenter().lat() + ',' + map.getCenter().lng());

    refresh_explore_results();
}


function refresh_explore_results(){
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
    marker = markerManager.addMarker(lat, lng);
    marker.resultID_ = resultID;

    google.maps.event.addListener(marker, 'click', function() {
        for(var i = 0; i < this.clusteredMarkers_.length; i++) {
            var myMarker = this.clusteredMarkers_[i];
            if(selectedResult != undefined)
                selectedResult.css('backgroundColor', '');
            
            selectedResult = $('#' + myMarker.resultID_);
            $('#' + myMarker.resultID_).css('background-color', '#333');
            $('#results_list').prepend($('#' + myMarker.resultID_));
            $('#results_container').scrollTop(0);
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