var createEventEventTypeTimer;
var createEventSelectedMarker;
var geocoder = new google.maps.Geocoder();
var eventImageSummaryInterval;

$(function(){
    cleanUpSelf = function(){
    }

    resizeSelf = function(){
        resizeCenterPaneContent();
        resizeWhatTags();
        resizeCalendar();
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
    var scrollerTop = $('#event_types_scroller').offset().top;
    $('#event_types_scroller').height(centerPaneBottom - scrollerTop);

    var groupScrollerTop = $('#groups_scroller').offset().top;
    $('#groups_scroller').height(centerPaneBottom - groupScrollerTop);
}
function resizeWhatTags(){
    var docHeight = $(window).height();
    var keywordTopOffset = $('#keyword_tag_list').offset().top;
    var keywordHeight = $('.keyword-tag-holder').height() + 5;
    var continueHeight = $('#create_what_next_arrow').height() + 35;//30 for padding
    if(keywordHeight > docHeight - keywordTopOffset - continueHeight){
        $('.keyword-tag-holder').height(docHeight - keywordTopOffset - continueHeight);
        initScrollPane($('.keyword-tag-holder'));
    }
}
function resizeCalendar(){
    if($('#create_when_calendar_holder').hasClass('hidden'))
        return;
    
    $('#create_when_calendar_holder').height('100%');
    $('#create_when_calendar_holder').width('100%');

    var maxWidth = $('#center_pane').width();
    var calWidth = $('#create_when_calendar_holder').height() * 1.35;
    if(calWidth > maxWidth)
        calWidth = maxWidth;

    $('#create_when_calendar_holder').width(calWidth);//1.35 default aspect ratio
    $('#create_when_calendar_holder').height(calWidth / 1.35);

    $('#create_when_calendar').fullCalendar('option', 'height', calWidth/1.35);
}

/*
 * CREATE EVENT FUNCTIONS
 */
function initCreateEvent(){
    //Create What bindings
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
        $('#create_where_name_location_input').focus();
    });

    $('#create_where_name_location_input').keydown(function(e){
        if(e.keyCode == 13){//Enter pressed
            saveMarkerName(e.target.value);
        }
    });

    $('#create_where_name_location_input').blur(function(e) {
        saveMarkerName(e.target.value);
    });

    $('#create_where_next_arrow').click(function(){
        $('#create_where').addClass('hidden');
        $('#create_when').removeClass('hidden');

        //markerManager.deleteAllMarkers();

        setupCreateWhen();
    });
   
    //Create When Bindings
    $('#create_when_next_arrow').click(function(){
        $('#create_when').addClass('hidden');

        setupCreateSummary();

        $('#create_summary').removeClass('hidden');
    });

    $('.create-when-field').change(function(){
        updateCreateWhenDates();
    });

    //Summary
    var alreadySubmitted = false;
    $('#create_summary_create_button').click(function(){
        if(!alreadySubmitted){
            $('#event_create_form').submit();
            alreadySubmitted = true;
        }
    });
}

/*
 *WHAT FUNCTIONS
 **/
function setupCreateWhat(){
    $('#on_create_what').val('true');

    showEventTypeHolder();

    $('.create-where-view').addClass('hidden');
    $('.create-when-view').addClass('hidden');
}

/*
 *WHERE FUNCTIONS
 **/
function setupCreateWhere(){
    $('.create-what-view').addClass('hidden');
    $('#on_create_what').val('');
    $('#center_pane').addClass('invisible');
    $('.create-where-view').removeClass('hidden');

    $('#top_pane').width($(window).width() - $('#left_side_pane').width() - 40);//20 is for 20px gutters

    var lat = $('#location-lat-field').val();
    var lng = $('#location-lng-field').val();

    if(lat && lng){
        var marker = createCreateMarker(new google.maps.LatLng(lat, lng));

        var name = $('#location-name-field').val();
        selectMarker_createWhere(marker);
        if(name){
            saveMarkerName(name);
            selectMarker_createWhere(marker);
        }
    }else{
        $('#create_where_next_arrow').addClass('invisible');
        $('#create_where_marker_info').addClass('invisible');
        $('#create_where_name_location-text').text('');
        $('#create_where_address').text('');

        createCreateMarker(map.getCenter());
    }

    map.setZoom(15);
    var xOffset = $('#location-map').width() / 5;
    var yOffset = $('#location-map').height() / 5;
    map.panBy(-xOffset, -yOffset);


    markerManager.showAllMarkers();
}

function selectMarker_createWhere(marker){
    createEventSelectedMarker = marker;
    
    $('#create_where_marker_info').removeClass('invisible');
    $('#create_where_address').text(marker.address_);

    $('#create_where_name_location_text').text((marker.text_ && marker.text_.length > 0) ? marker.text_ : "Click here to name this location...");
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
    marker.setIcon('/images/create-event-marker.png');
    marker.setShadow(new google.maps.MarkerImage('/images/icon-shadow.png', null, null, new google.maps.Point(17,55)));

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
            var street_number = "";
            var route = "";
            var street_address = null;
            var locality = null;
            var components = results[0].address_components;
            for(var i = 0; i < components.length; i++){
                if(components[i].types[0] == 'street_number')
                    street_number = components[i].long_name;
                if(components[i].types[0] == 'route')
                    route = components[i].long_name;
                if(components[i].types[0] == 'street_address')
                    street_address = components[i].long_name;
                if(components[i].types[0] == 'locality')
                    locality = components[i].long_name;
            }
            if(null == street_address)
                street_address = street_number + ' ' + route;
            if(null != locality)
                locality = ', ' + locality;
            else
                locality = '';
            marker.address_ = street_address + locality;

            //Store for summary
            if(route.length > 0){
                $('#event_street').val(route);
            }
            else{
                $('#event_street').val(street_address);
            }

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

    $('#create_when_calendar').fullCalendar({
        defaultView: 'month',
        dayClick: function(date, allDay, jsEvent, view) {
            setWhenDate(date);
        }
    });

    resizeCalendar();
    
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


function setupCreateSummary(){
    $('.create-when-view').addClass('hidden');
    $('#center_pane').addClass('invisible');
    $('#on_create_summary').val('true');

    $.each(markerManager.allMarkers_, function(index, marker){
        marker.setDraggable(false);
    });

    //KEYWORDS
    $.each($('.keyword-tag').not('#keyword_tag_stamp'), function(index, keyword){
        var $newKeyword = $($(keyword).clone());
        $newKeyword.find('.keyword-tag-remove').remove();
        $newKeyword.removeClass('remove-keyword-tag');
        $('#summary_keyword_list').append($newKeyword);
    });
    initScrollPane($('#summary_tag_holder'));


    //WHERE
    $('#summary_where_text').text($('#location-name-field').val());
    $('#summary_where_address').text($('#location-geocodedaddress-field').val());

    //WHEN
    var startDate = new Date($('#start_date').val());
    var endDate = new Date($('#end_date').val());
    $('#summary_when_start_date').text(formatDateStringForSummary(startDate));
    if(startDate.getDate() == endDate.getDate() && startDate.getMonth() == endDate.getMonth() && startDate.getYear() == endDate.getYear()){
        $('#summary_when_end_date').text(formatTimeForSummary(endDate));
    }
    else{
        $('#summary_when_end_date').text(formatDateStringForSummary(endDate));
    }

    //TITLE
    $('#summary_event_name_field').autoResize();
    if(null == $('#summary_event_name_field').val() || $('#summary_event_name_field').val().length < 1){
        $('#summary_event_name_field').val(formatTitleForSummary($('.keyword-input').first().val(), $('#location-name-field').val(), $('#event_street').val()));
    }
    $('#summary_event_name_field').live('change', function(){
        $('#event_name').val($.trim($(this).val()));
        resizePageElements();
    });

    //Description
    $('#summary_event_description_field').autoResize();
    $('#summary_event_description_field').live('change', function(){
        $('#event_description').val($.trim($(this).val()));
        resizePageElements();
    });

    //WHO
    $.each($('.event-group-input'), function(index, group){
        var groupID = $(group).val();
        if(groupID == 'public'){
            addGroupToSummary('Everyone');
        }
        else{
            var groupName = $('#group_id_' + groupID).closest('.group-type').find('.group-type-name').text();
            addGroupToSummary(groupName, groupID);
        }
    });
    $('.group-permission-view').live('click', function(){
        $('.group-permission .selected').removeClass('selected');
        $(this).addClass('selected');
        var $groupPermission = $(this).closest('.group-permission');
        $groupPermission.find('span').text('View');
        changeGroupPermission($groupPermission.closest('.summary-who-group'));
    });
    $('.group-permission-join').live('click', function(){
        $('.group-permission .selected').removeClass('selected');
        $(this).addClass('selected');
        var $groupPermission = $(this).closest('.group-permission');
        $groupPermission.find('span').text('View & Join');
        changeGroupPermission($groupPermission.closest('.summary-who-group'));
    });
    $('.group-permission-nothing').live('click', function(){
        $('.group-permission .selected').removeClass('selected');
        $(this).addClass('selected');
        var $groupPermission = $(this).closest('.group-permission');
        $groupPermission.find('span').text('do nothing');
        changeGroupPermission($groupPermission.closest('.summary-who-group'));
    });
    
    $('#add_group_link').live('click', function(){
        markerManager.hideAllMarkers();
        showGroups();
    });

    //Display page
    $('.create-summary-view').removeClass('hidden');
    resizePageElements();
}
function changeGroupPermission(summaryWhoGroup){
    var $summaryWhoGroup = $(summaryWhoGroup);
    var groupID = $summaryWhoGroup.find('#group_id').val();
    groupID = (groupID && groupID.length > 0) ? groupID : "public"

    $('#event_group_input_' + groupID).remove();

    if($summaryWhoGroup.find('.group-permission span').text() == 'Can'){
        $('#event_create_form').append(
            '<input type="hidden" name="event[event_groups_attributes][][pseudo_group_id]" class="event-group-input" value="' +
            groupID +
            '" id="event_group_input_' +
            groupID +
            '" />'
            );
    }
}
function formatDateStringForSummary(myDate){
    //Create date
    var monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    var dayNames = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];

    //turn date into string
    return dayNames[myDate.getDay()] + " " + monthNames[myDate.getMonth()] + " " + myDate.getDate() + " @ " + formatTimeForSummary(myDate);
}
function formatTimeForSummary(myDate){
    return (myDate.getHours() > 12 ? myDate.getHours()  - 12: myDate.getHours())  + ":" + (myDate.getMinutes() < 10 ? "0" + myDate.getMinutes() : myDate.getMinutes()) + (myDate.getHours() >= 12 ? ' PM' : ' AM')
}
function formatTitleForSummary(keyword, location_text, location_street){
    return keyword + ((null != location_text && location_text.length > 0) ? ' @ ' + location_text : ' on ' + location_street);
}
