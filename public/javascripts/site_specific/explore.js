var geocoder = new google.maps.Geocoder();
var exploreMarkerArr = [];
var exploreEventTypeTimer;
var exploreUpdateTimer;
var selectedResult;

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
    
    //Keyword field gets focus, setup
    $('#explore_keyword_text_field').focus(function() {
        $(this).val('');
        $('#explore_keyword_event_types_holder').removeClass('hidden');
        $('#center_pane').removeClass('invisible');
        initScrollPane($('#event_types_scroller'));
    });

    //User clicks somewhere that isn't the event types, hide
    $(document).bind("click", function(e){
        if($('#on_explore').length > 0 && $(e.target).closest('#explore_keyword_text_field_holder').length < 1 && $(e.target).closest('#explore_keyword_event_types_holder').length < 1 )
        {
            $('#explore_keyword_event_types_holder').addClass('hidden');
            $('#center_pane').addClass('invisible');
            $('#explore_keyword_text_field').blur();
        }
    });

    //User clicks the event type
    $('.explore-keyword-event-type').live('click', function() {
        exploreEventTypeIsClicked(this);
    });

    //User filter event type
    $('#explore_keyword_text_field').keyup(function(e){
        explore_keywords_textfield_keywdown(e);
    });

    //User removes filter
    $('.explore-keyword-tag-remove').live('click', function(){
        removeExploreTag($(this).parent());        
        
        if($('[name="keywords[]"]').length==3) {
            $('#explore_keyword_tag_list_holder').data('jsp').destroy();
            $('#explore_keyword_tag_list_holder').height('auto');
        }
    });
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
    map.panTo(new google.maps.LatLng(parseFloat(mapCenterArr[0]), parseFloat(mapCenterArr[1])));
    map.setZoom(parseInt($('#map_zoom').val()));

    createTagsFromInputFields();

    addExploreMarkers();
    toggle_suggested_actions();
}

function createTagsFromInputFields(){
    $.each($('#explore_search_params input[name="keywords[]"]'), function(index, elem){
        filter_explore_keyword_icons($(elem).val(), true, false);
    });
}

function removeExploreTag(tag_dom){
    var tag_name = $.trim(tag_dom.children('.explore-keyword-tag-name').text());

    $.each($('#explore_search_params input[name="keywords[]"]'), function(index, elem){
        if($(elem).val() == tag_name){
            $(elem).remove();
        }
    });

    tag_dom.remove();

    refresh_explore_results();

    if($('#explore_search_params input[name="keywords[]"]').length < 1){
        $('#explore_keyword_header').addClass('invisible');
    }
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

            if(create && exact_match){
                exploreEventTypeIsClicked(myEventName.parent(), submit);
            }
        }
    });

    if(!exact_match && search_text.length > 0){
        var customType = setCustomEventType(search_text)
        
        if(create){
            exploreEventTypeIsClicked(customType, submit);
        }
    }
    else{
        $('#explore_keyword_event_types_holder #explore_keyword_custom_event_type').addClass('hidden');
    }
}

function setCustomEventType(text){
    var customType = $('#explore_keyword_event_types_holder #explore_keyword_custom_event_type');
    if(customType.length > 0){
        customType.children('.explore-keyword-event-type-name').text(text);
    }
    customType.removeClass('hidden');

    return customType;
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
    if(keyword.length < 1)
        return;

    if(!doesExploreKeywordAlreadyExist(keyword)){
        var eventType_record;
        $('.explore-keyword-event-type').each(function(i, ele) {
            if($.trim($(ele).children('.explore-keyword-event-type-name').text()) == keyword){
                eventType_record = $(ele);
            }
        });

        if(eventType_record == undefined){
            eventType_record = setCustomEventType(keyword);
        }

        var new_tag_record = $($('#explore_keyword_tag_stamp').clone());
        var eventType_name = $.trim(eventType_record.children('.explore-keyword-event-type-name').text());

        new_tag_record.id = "";
        new_tag_record.find('.explore-tag-icon').attr('src', eventType_record.find('img').attr('src'));
        new_tag_record.find('.explore-keyword-tag-name').text(eventType_name);
        $('#explore_keyword_tag_list').append(new_tag_record);
        new_tag_record.removeClass('hidden');

        $('#explore_search_params').append(
            '<input type="hidden" name="keywords[]" value="' + keyword + '" />'
            );

        $('#explore_keyword_header').removeClass('invisible');

        var $tagHolder = $('#explore_keyword_tag_list_holder');

        if($tagHolder.height() > 150)
            initScrollPane($tagHolder);
    }  
}

function exploreEventTypeIsClicked(record, submit){
    if(submit == undefined) {
        submit = true;
    }

    var eventType_record = $(record);
    var eventType_name = $.trim(eventType_record.children('.explore-keyword-event-type-name').text());

    addKeyword(eventType_name);

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

function doesExploreKeywordAlreadyExist(eventType_name){
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

    var projection = markerManager.projectionHelper_.getProjection();
    var trPix
    trPix.y = $('#left_side_pane').offset().top;
    trPix.x = $('#left_side_pane').offset().left + $('#left_side_pane').width();

    var ne = projection.fromDivPixelToLatLng(trPix);



    $('#map_bounds').val(bounds.getNorthEast().lat() + ',' + bounds.getNorthEast().lng() + ',' + bounds.getSouthWest().lat() + ',' + bounds.getSouthWest().lng());
    $('#map_center').val(map.getCenter().lat() + ',' + map.getCenter().lng());

    updateUserLocation(map.getCenter().lat(), map.getCenter().lng(), true);

    
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
        $('.result').css('background-color', '');
        //$('.result-arrow').addClass('hidden');

        for(var i = 0; i < this.clusteredMarkers_.length; i++) {
            var myMarker = this.clusteredMarkers_[i];            
            var myResult = $('#' + myMarker.resultID_);
            myResult.css('background-color', '#333');
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