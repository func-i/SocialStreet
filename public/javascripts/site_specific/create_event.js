var createEventEventTypeTimer;
var createEventSelectedMarker;
var geocoder = new google.maps.Geocoder();

$(function(){
    cleanUpSelf = function(){
    }

    resizeSelf = function(){
        resizeCenterPaneContent();
        resizeWhatTags();
    }

    setupCreateWhat();
    
    resizePageElements();

    initCreateEvent();

/*    $(window).bind('resize', function() {
        resizeScrollPane($('#what_scroller'));
    });*/    
});

function resizeCenterPaneContent(){
    var centerPaneBottom = $('#center_pane').offset().top + $('#center_pane').height();
    var scrollerTop = $('#what_scroller').offset().top;
    $('#what_scroller').height(centerPaneBottom - scrollerTop);
}
function resizeWhatTags(){
    var whatTagTopOffset = $('#create_what_tag_list').offset().top;
    var continueButtonTopOffset = $('#create_what_next_arrow').offset().top;
    $('#create_what_tag_list').height(continueButtonTopOffset - whatTagTopOffset - 20);
}

/*
 * CREATE EVENT FUNCTIONS
 */
function initCreateEvent(){
    //Create What bindings
    $('#create_what_text_field').keyup(function(e){
        filter_what_icons(e.target.value);
        $('#what_scroller').data('jsp').scrollToY(0);
    });

    $('.create-what-event-type').live('click', function(){
        createEventTypeIsClicked(this);
        resizeLayout();
    });

    $('#create_what_next_arrow').click(function(){
        setupCreateWhere();

        $('#create_what').addClass('hidden');
        $('#create_where').removeClass('hidden');
    });   

    //Create Where bindings
    $('#create_where_text_field').keydown(function(e){
        if(e.keyCode == 13){//Enter pressed
            searchLocations(e);
        }
    });

    $('#create_where_name_location').click(function(){
        $('#create_where_name_location_text').addClass('hidden');
        $('#create_where_name_location_input').removeClass('hidden');
    });

    $('#create_where_name_location_input').keydown(function(e){
        if(e.keyCode == 13){//Enter pressed
            saveMarkerName(e.target.value);
        }
    });

    $('#create_where_next_arrow').click(function(){
        $('#create_where').addClass('hidden');
        $('#create_when').removeClass('hidden');

        markerManager.deleteAllMarkers();

        setupCreateWhen();
    });
   
    //Create When Bindings
    var alreadySubmitted = false;
    $('#create_when_next_arrow').click(function(){
        if(!alreadySubmitted){
            $('#event_create_form').submit();
            alreadySubmitted = true;
        }
    });

    $('.create-when-field').change(function(){
        updateCreateWhenDates();
    });
}

/*
 *WHAT FUNCTIONS
 **/
function setupCreateWhat(){
    $('#center_pane').removeClass('invisible');

    $('.create-where-view').addClass('hidden');
    $('.create-when-view').addClass('hidden');
}

function filter_what_icons(search_text){
    if (createEventEventTypeTimer) {
        clearInterval(createEventEventTypeTimer);
        delete createEventEventTypeTimer;
    }
    createEventEventTypeTimer = setTimeout(function() {
        var regEx = new RegExp(search_text, "i");
        var exact_match = false;

        //Filter the event_type list by the text entered
        $.each($('.create-what-event-type-name'), function(index, value){
            var myEventName = $(value);
            if($.trim(myEventName.text()).match(regEx) == null){
                myEventName.parent().addClass('hidden');
            }
            else{
                myEventName.parent().removeClass('hidden');

                exact_match = exact_match || $.trim(myEventName.text()) == search_text;
            }
        });

        if(!exact_match && search_text.length > 0){
            var customType = $('#create_what_event_types_holder #create-what-custom-event-type');
            if(customType.length > 0){
                customType.children('.create-what-event-type-name').text(search_text);
            }
            customType.removeClass('hidden');
        }
        else{
            $('#create_what_event_types_holder #create-what-custom-event-type').addClass('hidden');
        }

    }, 250);
}

function createEventTypeIsClicked(record) {
    var eventType_record = $(record);
    var eventType_name = $.trim(eventType_record.children('.create-what-event-type-name').text());

    if(eventType_record.closest('#create_what_tag_list').length > 0)
    {
        if(eventType_record.siblings().length == 0)
        {
            $('#create_what_tag_list_holder').addClass('invisible');
            $('#create_what_next_arrow').addClass('invisible');
        }

        eventType_record.remove();
        initScrollPane($('#create_what_tag_list'));

        $.each(
            $('#event_create_form input[name="event[event_keywords_attributes][][name]"]'),
            function(index, value){
                if($.trim($(value).val()) == eventType_name)
                    $(value).remove();
            });

    }
    else
    {
        if($('#create_what_tag_list .create-what-event-type-name').length == 0){
            $('#create_what_tag_list_holder').removeClass('invisible');
            $('#create_what_next_arrow').removeClass('invisible');
        }

        if(!doesKeywordAlreadyExist(eventType_name))
        {
            var api = $('#create_what_tag_list').data('jsp');
            api.getContentPane().append(eventType_record.clone().css('position', 'relative').append($('#bg_close').clone().removeClass('hidden').addClass('event-type-selected')));
            api.reinitialise();

            $('#event_create_form').append(
                '<input type="hidden" name="event[event_keywords_attributes][][name]" value="' + eventType_name + '" />'
                );

        //resizeScrollPane($('#create-what-tag-list-holder'));
        }
    }
}

function doesKeywordAlreadyExist(eventType_name){
    var rtn = false;
    $.each(
        $('#create_what_tag_list .create-what-event-type-name'),
        function(index, value){
            if($.trim($(value).text()) == eventType_name)
                rtn = true;
        }
        );
    return rtn;
}


/*
 *WHERE FUNCTIONS
 **/
function setupCreateWhere(){
    $('.create-what-view').addClass('hidden');
    $('#center_pane').addClass('invisible');
    $('.create-where-view').removeClass('hidden');

    $('#top_pane').width($(window).width() - $('#left_side_pane').width() - 40);//20 is for 20px gutters

    var lat = $('#location-lat-field').val();
    var lng = $('#location-lng-field').val();

    if(lat && lng){
        $('#create_where_next_arrow').removeClass('invisible');
        $('#create_where_marker_info').removeClass('invisible');

        var marker = createCreateMarker(new google.maps.LatLng(lat, lng));
        map.panTo(marker.getPosition());
    }else{
        $('#create_where_next_arrow').addClass('invisible');
        $('#create_where_marker_info').addClass('invisible');
        $('#create_where_name_location-text').text('');
        $('#create_where_address').text('');
        $('#create_where_text_field').val('');
        $('#create_where_name_location_input').val('');

        createCreateMarker(map.getCenter());
    }

    var xOffset = $('#location-map').width() / 5;
    var yOffset = $('#location-map').height() / 5;
    map.panBy(-xOffset, -yOffset);

    markerManager.showAllMarkers();
}

function selectMarker_createWhere(marker){
    createEventSelectedMarker = marker;
    
    $('#create_where_marker_info').removeClass('invisible');
    $('#create_where_address').text(marker.address_);

    $('#create_where_name_location_text').text(marker.text_ ? marker.text_ : "Click here to name this pin...");
    $('#create_where_name_location_text').removeClass('hidden');
    $('#create_where_name_location_input').addClass('hidden');
    $('#create_where_name_location_input').val('');

    map.panTo(marker.getPosition());//TODO: Shouldnt center, but center in lower right quadrant

    $('#create_where_next_arrow').removeClass('invisible');

    $('#event_create_form #location-lat-field').val(marker.getPosition().lat());
    $('#event_create_form #location-lng-field').val(marker.getPosition().lng());
    $('#event_create_form #location-geocodedaddress-field').val(marker.address_);
    $('#event_create_form #location-name-field').val(marker.text_);
}

function saveMarkerName(marker_name){
    $('#create_where_name_location_text').text(marker_name);
    createEventSelectedMarker.text_ = marker_name;
    $('#create_where_name_location_text').removeClass('hidden');
    $('#create_where_name_location_input').addClass('hidden');
    $('#event_create_form #location-name-field').val(marker_name);
}

function searchLocations(e) {
    var loc = e.target.value;
    geocoder.geocode( {
        'address': loc,
        'bounds' : map.getBounds()
    }, function(results, status) {
        if (status == google.maps.GeocoderStatus.OK) {
            var selectedMarker = null;
            var distance = 40000;

            markerManager.deleteAllMarkers();
            $.each(results, function(index, result)
            {
                var marker = createCreateMarker(result.geometry.location, loc);

                var d = distanceBetweenMapPoints(map.getCenter(), result.geometry.location);
                if(d < distance){
                    distance = d;
                    selectedMarker = marker;
                }

                selectMarker_createWhere(selectedMarker);
            });
            markerManager.showAllMarkers();
        }
        else {
            alert("Geocode was not successful for the following reason: " + status);
        }
    });
    return false;
}

function distanceBetweenMapPoints(pos1, pos2){
    if(!pos1 || !pos2){
        return 0
    }

    var R = 6371; //Radius of Earth in km
    var dLat = (pos2.lat() - pos1.lat()) * Math.PI / 180;
    var dLon = (pos2.lng() - pos1.lng()) * Math.PI / 180;
    var a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
    (Math.cos(pos1.lat() * Math.PI / 180) * Math.cos(pos2.lat() * Math.PI / 180) *
        Math.sin(dLon / 2) * Math.sin(dLon / 2));
    var c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    var d = R * c;
    return d;
}

function createCreateMarker(latlng, address){
    var marker = markerManager.addMarker(latlng.lat(), latlng.lng());
    marker.setDraggable(true);
    marker.text_ = null;

    if(undefined == address){
        address = "";
        reverse_geocode(marker);
    }
    marker.address_ = address

    google.maps.event.addListener(marker, 'click', function(latlng){
        selectMarker_createWhere(this);
    });

    google.maps.event.addListener(marker, 'dragend', function(latlng)
    {
        selectMarker_createWhere(this);
        reverse_geocode(this);
    });

    return marker;
}

function reverse_geocode(marker){
    geocoder.geocode(
    {
        'location': marker.getPosition()
    },
    function(results, status){
        if (status == google.maps.GeocoderStatus.OK) {
            marker.address_ = results[0].formatted_address;
            if(createEventSelectedMarker == marker){
                selectMarker_createWhere(marker);
            }
        }
    });
}


/*
 *WHEN FUNCTIONS
 **/
function formatDateStringForDisplay(myDate){
    //Create date
    var monthNames = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
    var dayNames = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];

    //turn date into string
    return monthNames[myDate.getMonth()] + " " + myDate.getDate() + ", " + myDate.getFullYear();
}
function formatDateStringForInput(myDate){
    return myDate.getFullYear() + "-" + (myDate.getMonth() + 1) + "-" + myDate.getDate() + " " + myDate.getHours() + ":" + myDate.getMinutes();
}

function updateCreateWhenDates(){
    var start_date = $('#create_when_date').text();
    start_date = new Date(start_date);

    var start_hour = $($('.create-when-time')[0]).val();
    var start_meridian = $($('.create-when-time')[2]).val();
    if(start_meridian == "PM"){
        var hour = parseInt(start_hour, 10);
        start_hour = hour + (hour == 12 ? 0 : 12);
    }
    start_date.setHours(start_hour);

    var start_minute = $($('.create-when-time')[1]).val();
    start_date.setMinutes(start_minute);

    var duration = $('#duration').val();
    var duration_size = $('#duration_size').val();
    if(duration_size == "Minutes"){
        duration = duration*60000;
    }
    else if(duration_size == "Hours"){
        duration = duration*3600000;
    }
    else if(duration_size == "Days"){
        duration = duration*86400000;
    }

    var end_date = new Date(start_date.getTime());
    end_date.setMilliseconds(start_date.getMilliseconds() + duration);

    $('#start_date').val(formatDateStringForInput(start_date));
    $('#end_date').val(formatDateStringForInput(end_date));
}

function setupCreateWhen(){
    $('.create-where-view').addClass('hidden');
    $('.create-when-view').removeClass('hidden');
    $('#center_pane').removeClass('invisible');

    $('#create_when_calendar_holder').width($('#create_when_calendar_holder').height() * 1.35);//1.35 default aspect ratio

    $('#create_when_calendar').fullCalendar({
        defaultView: 'month',
        height: $('#create_when_calendar_holder').height(),
        dayClick: function(date, allDay, jsEvent, view) {
            setWhenDate(date);
        }
    });

    var myStartDate = $('#start_date').val();
    var myDate = new Date(myStartDate);
    setWhenDate(myDate);

}

function highlightDate(date){
    $.each($('.fc-day-number'), function(index, elem){
        if(! $(elem).parent().parent().hasClass('fc-other-month')){
            if($(elem).text() == date.getDate()){
                $(elem).parent().parent().addClass('fc-state-highlight');
            }
        }
    });
}
function setWhenDate(date){
    $('#create_when_calendar').fullCalendar('gotoDate', date);
    $('.fc-state-highlight').removeClass('fc-state-highlight');
    highlightDate(date);

    $('#create_when_date').text(formatDateStringForDisplay(date));

    updateCreateWhenDates();
}

