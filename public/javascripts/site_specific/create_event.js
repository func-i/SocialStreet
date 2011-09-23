var createEventEventTypeTimer;
var createEventSelectedMarker;
var geocoder = new google.maps.Geocoder();

function sizeFields() {
    var $contentSize = $(window).width() - $('.x-small-box').width();
    $('#keywords').width($contentSize - 200);
    $('.create-what-event-types-holder').width($contentSize - 125);
    $('#what_scroller').width($contentSize - 125);
}

$(function(){
    init_create_event();
    sizeFields();
    initializeScrollPanes();

    $(window).bind('resize', function() {
        sizeFields();
        initializeScrollPanes();
    });
    
    cleanUpSelf = function(){
    }
});

/*
 * CREATE EVENT FUNCTIONS
 */
function init_create_event(){
    //Create What bindings
    $('.create-what-text-field').keyup(function(e){
        filter_what_icons(e.target.value);
        $('#what_scroller').data('jsp').scrollToY(0);
    });

    $('.create-what-event-type').live('click', function(){
        create_eventType_is_clicked(this);
    });

    $('#create_what_next_arrow').click(function(){
        setupCreateWhere();

        $('#create_what').addClass('hidden');
        $('#create_where').removeClass('hidden');
    });   

    //Create Where bindings
    $('#create-where-text-field').keydown(function(e){
        if(e.keyCode == 13){//Enter pressed
            searchLocations(e);
        }
    });

    $('#create-where-name-location').click(function(){
        $('#create-where-name-location-text').addClass('hidden');
        $('#create-where-name-location-input').removeClass('hidden');
    });

    $('#create-where-name-location-input').keydown(function(e){
        if(e.keyCode == 13){//Enter pressed
            save_marker_name(e.target.value);
        }
    });

    $('#create_where_next_arrow').click(function(){
        $('#create_where').addClass('hidden');
        $('#create_when').removeClass('hidden');

        markerManager.deleteAllMarkers();

        setupCreateWhen();
    });
   
    //Create When Bindings
    $('#create_when_next_arrow').click(function(){
        $('#event_create_form').submit();
    });

    $('.create-when-field').change(function(){
        updateCreateWhenDates();
    });
}

/*
 *WHAT FUNCTIONS
 **/
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
            if(myEventName.text().trim().match(regEx) == null){
                myEventName.parent().addClass('hidden');
            }
            else{
                myEventName.parent().removeClass('hidden');

                exact_match = exact_match || myEventName.text().trim() == search_text;
            }
        });

        if(!exact_match && search_text.length > 0){
            var customType = $('.create-what-event-types-holder #create-what-custom-event-type');
            if(customType.length > 0){
                customType.children('.create-what-event-type-name').text(search_text);
            }
            customType.removeClass('hidden');
        }
        else{
            $('.create-what-event-types-holder #create-what-custom-event-type').addClass('hidden');
        }

    }, 250);
}

function create_eventType_is_clicked(record){
    var eventType_record = $(record);
    var eventType_name = eventType_record.children('.create-what-event-type-name').text().trim();

    if(eventType_record.parent().attr('id') == 'create_what_tag_list')
    {
        if(eventType_record.siblings().length == 0)
        {
            $('#create-what-tag-list-holder').addClass('hidden');
            $('#create_what_next_arrow').addClass('hidden');
        }

        eventType_record.remove();
        resizeScrollPane(record.parent().parent());

        $.each(
            $('#event_create_form input[name="event[event_keywords_attributes][][name]"]'),
            function(index, value){
                if($(value).val().trim() == eventType_name)
                    $(value).remove();
            }
            );

    }
    else
    {
        if($('#create_what_tag_list .create-what-event-type-name').length == 0){
            $('#create-what-tag-list-holder').removeClass('hidden');
            $('#create_what_next_arrow').removeClass('hidden');
        }

        if(!does_keyword_already_exist(eventType_name))
        {
            $('#create_what_tag_list').append(eventType_record.clone());

            $('#event_create_form').append(
                '<input type="hidden" name="event[event_keywords_attributes][][name]" value="' + eventType_name + '" />'
                );

            resizeScrollPane($('#tag_scroller'));
        }
    }
}

function does_keyword_already_exist(eventType_name){
    var rtn = false;
    $.each(
        $('#create_what_tag_list .create-what-event-type-name'),
        function(index, value){
            if($(value).text().trim() == eventType_name)
                rtn = true;
        }
        );
    return rtn;
}


/*
 *WHERE FUNCTIONS
 **/
function setupCreateWhere(){
    var lat = $('#location-lat-field').val();
    var lng = $('#location-lng-field').val();

    if(lat && lng){
        $('#create_where_next_arrow').removeClass('hidden');
        $('#create-where-marker-info').removeClass('hidden');


        var marker = createCreateMarker(new google.maps.LatLng(lat, lng));
        map.panTo(marker.getPosition());
    }else{
        $('#create_where_next_arrow').addClass('hidden');
        $('#create-where-marker-info').addClass('hidden');
        $('#create-where-name-location-text').text('');
        $('#create-where-address').text('');
        $('#create-where-text-field').val('');
        $('#create-where-name-location-input').val('');

        createCreateMarker(map.getCenter());
    }
    markerManager.showAllMarkers();
}

function selectMarker_createWhere(marker){
    createEventSelectedMarker = marker;
    
    $('#create-where-marker-info').removeClass('hidden');
    $('#create-where-address').text(marker.address_);

    $('#create-where-name-location-text').text(marker.text_ ? marker.text_ : "Click here to name this pin...");
    $('#create-where-name-location-text').removeClass('hidden');
    $('#create-where-name-location-input').addClass('hidden');
    $('#create-where-name-location-input').val('');

    map.panTo(marker.getPosition());//TODO: Shouldnt center, but center in lower right quadrant

    $('#create_where_next_arrow').removeClass('hidden');

    $('#event_create_form #location-lat-field').val(marker.getPosition().lat());
    $('#event_create_form #location-lng-field').val(marker.getPosition().lng());
    $('#event_create_form #location-geocodedaddress-field').val(marker.address_);
    $('#event_create_form #location-name-field').val(marker.text_);
}

function save_marker_name(marker_name){
    $('#create-where-name-location-text').text(marker_name);
    createEventSelectedMarker.text_ = marker_name;
    $('#create-where-name-location-text').removeClass('hidden');
    $('#create-where-name-location-input').addClass('hidden');
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
    $('#create_when_calendar').fullCalendar({
        defaultView: 'month',
        dayClick: function(date, allDay, jsEvent, view) {
            setWhenDate(date);
        },
        header: {
            left:   'title',
            center: '',
            right:  'today prev,next'
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

