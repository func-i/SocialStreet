var cleanUpSelf = function(){};

$(function() {
    //Ajax call when clicking nav buttons
    $('.nav-link').live('click', function(e) {
        cleanup();

        var href;
        if($(this).data('ajax-href') != '') {
            href = $(this).data('ajax-href');
        }
        else if(this.href != undefined) {
            href = this.href;
        }

            
        if(href != undefined) {
            if(history && history.pushState) {

                $.getScript(href, function() {
                    resizePageElements();
                });
                history.pushState({}, "", href);
            }
            else{
                window.location = href;
            }
            e.preventDefault();
            e.stopPropagation();
        }       
    });

    //Signin link
    $('#signin_button').click(function() {
        window.location = $(this).data('href');
    });

    $('#header_signin_button').click(function() {
        window.location = $(this).data('href');
    });

    $('#how_it_works_find').click(function() {
        closeHowItWorks();
    });

    //Ajax Link
    $('.ajax-link').live('click', function(e){
        var href;
        if(this.href != undefined) {
            href = this.href;
        }
        else{
            href = $(this).data('ajax-href');
        }

        $.getScript(href);
    });


    //HISTORY. Pop state is called when pressing back button in the browser
    var popped = (window.history && null === window.history.state), initialURL = location.href;
    $(window).bind('popstate', function() {
        var initialPop = !popped && location.href == initialURL;
        popped = true;
        if ( initialPop ){
            return;
        }

        cleanup();
            
        $.getScript(location.href, function() {
            resizePageElements();
        });
    });


    //Get users current Location
    /*    if(-1 == document.cookie.indexOf('current_location_latitude') || -1 == document.cookie.indexOf('current_location_longitude'))
    {
        if(navigator.geolocation){
            navigator.geolocation.getCurrentPosition(function(e){
                updateUserLocation(e.coords.latitude, e.coords.longitude, null, true);
            }, function(e){
                },{
                    maximumAge: 600000,
                    timeout: 20000
                });
        }
    }*/

    //Initialize the size elements to match page size and initialize scrollbars
    resizePageElements();
    $(window).resize(function() {
        resizePageElements();
    });


    //Scrollbar behaviour on mouseover
    $('.show-scroll-on-hover').live('mouseenter', function(){
        $(this).find('.jspVerticalBar').removeClass('invisible');
    });
    $('.show-scroll-on-hover').live('mouseleave', function(){
        $(this).find('.jspVerticalBar').addClass('invisible');
    });

    $('#how_it_works_btn').click(function() {
        openHowItWorks();
    });

    $('#close_how_it_works').click(function() {
        closeHowItWorks();
    });

    $('#how_it_works_explore').click(function() {
        closeHowItWorks();
    });

    $('#feedback_btn').click(function(){
        openFeedback();
    });
    $('#close_feedback').click(function(){
       closeFeedback();
    });
    $('#submit_feedback').click(function(){
       $('#feedback_form').submit();
       closeFeedback();
    });

});

function cleanup(){
    if(typeof cleanUpSelf == 'function') {
        cleanUpSelf();
        cleanUpSelf = function(){};
    }
    markerManager.deleteAllMarkers();

    resizeSelf = function(){};

    $('.content-group').html(' ');
}

function updateUserLocation(latitude, longitude, zoomLevel, swLat, swLng, neLat, neLng, updateDB){
    $.getScript('/locations/update_user_location?' +
        'latitude=' + latitude +
        '&longitude=' + longitude +
        '&zoom_level=' + zoomLevel +
        '&sw_lat=' + swLat +
        '&sw_lng=' + swLng +
        '&ne_lat=' + neLat +
        '&ne_lng=' + neLng +
        '&update_db=' + updateDB, function(data, textStatus){});
}

function resizePageElements() {
    resizeLayout();
    resizeExpandHeightContainer();
    capHeightContainer();
    initializeScrollPanes();

    if(typeof resizeSelf == 'function'){
        resizeSelf();
    }
}

function resizeLayout(){

    var ver = getInternetExplorerVersion();

    //var docHeight = $(window).height();
    var docWidth = $(window).width();
    //var leftPaneTopOffset = $('#left_side_pane').offset().top;
    //var rightPaneTopOffset = $('#right_side_pane').offset().top;
    var rightPaneWidth = $('#right_side_pane').width();
    var leftPaneWidth = $('#left_side_pane').width();
    //var topPaneLeftOffset = $('#top_pane').offset().left;
    //var bottomPaneLeftOffset = $('#bottom_pane').offset().left;

    var centerPaneLeftOffset = $('#center_pane').offset().left;
    var topPaneTopOffset = $('#top_pane').offset().top;
    var topPaneTopPosition = $('#top_pane').position().top;
    var topPaneHeight = $('#top_pane').height();
    var bottomPaneTopOffset = $('#bottom_pane').offset().top;
    //    $('#left_side_pane').height(docHeight - leftPaneTopOffset); //Commented out because expanding prematurely causes the map to not be movable
    //    $('#right_side_pane').height(docHeight - rightPaneTopOffset); //Commented out because expanding prematurely causes the map to not be movable
    //    $('#top_pane').width(docWidth - topPaneLeftOffset - rightPaneWidth - 40);//20 is for 20px gutters
    //  $('#bottom_pane').width(docWidth - bottomPaneLeftOffset - rightPaneWidth - 40);//20 is for 20px gutters

    if ( ver == -1 )
        $('#right_side_pane').css('top', topPaneTopPosition + topPaneHeight + (topPaneHeight > 0 ? 20 : 0))
    
    if ( ver == -1 )
        $('#center_pane').css('top', topPaneTopPosition + topPaneHeight + (topPaneHeight > 0 ? 20 : 0));//20 is fo 20px gutters

    $('#center_pane').css('left', leftPaneWidth + 40);//40 is for 2x20px gutters
    $('#center_pane').width(docWidth - leftPaneWidth - 40 - rightPaneWidth - 40);//20 is for 20px gutters
    $('#center_pane').height(bottomPaneTopOffset - topPaneTopOffset - topPaneHeight - 40);//40 is for 2x20px gutters
}

function resizeExpandHeightContainer() {
    var docHeight = $(window).height();

    $.each($('.expand-height'), function(i, ele) {

        var cPos = $(ele).offset().top;

        var $par = $(ele).closest('.hidden');
        if($par.length > 0) {
            var zIndex = $par.css('z-index');
            $par.css('z-index', -1);
            $par.removeClass('hidden');

            cPos = $(ele).offset().top;

            $par.addClass('hidden');
            $par.css('z-index', zIndex);
        }

        var bottomOffset = $(ele).data('expandBottomOffset');
        bottomOffset = bottomOffset || 0;

        var cHeight = docHeight - cPos - bottomOffset;
        $(ele).height(cHeight);
    });
}

function capHeightContainer(){
    $.each($('.cap-height'), function(i, ele){
        var $myElem = $(ele);

        var height = $myElem.height()
        var maxHeight = $(window).height() - $myElem.offset().top;

        var $par = $myElem.closest('.hidden');
        if($par.length > 0) {
            var zIndex = $par.css('z-index');
            $par.css('z-index', -1);
            $par.removeClass('hidden');

            height = $myElem.height();
            maxHeight = $(window).height() - $myElem.offset().top;

            $par.addClass('hidden');
            $par.css('z-index', zIndex);
        }

        var bottomOffset = $(ele).data('expandBottomOffset');
        bottomOffset = bottomOffset || 0;


        if(height > (maxHeight - bottomOffset))
            height = maxHeight - bottomOffset;

        $myElem.height(height);
    });
}

function initScrollPane(scroll_pane) {
    var $myElem = $(scroll_pane);
    var height = $myElem.height();

    var $par = $myElem.closest('.hidden');
    if($par.length > 0) {
        var zIndex = $par.css('z-index');
        $par.css('z-index', -1);
        $par.removeClass('hidden');
        
        height = $myElem.height();

        $par.addClass('hidden');
        $par.css('z-index', zIndex);
    }

    $myElem.height(height);
    $myElem.bind('jsp-initialised', function(event, isScrollable){
        if($myElem.hasClass('show-scroll-on-hover')){
            $myElem.find('.jspVerticalBar').addClass('invisible');
        }
    });
    $myElem.jScrollPane();

    var that = $myElem;
    $(window).bind('resize', function() {
        //resizeScrollPane(that);
        });
}

function initializeScrollPanes() {
    $('.scroll-pane').each(function() {
        initScrollPane($(this));
    });
}

var throttleTimeout;
function resizeScrollPane(scrollPane){    
    var api = $(scrollPane).data('jsp');

    if ($.browser.msie) {
        // IE fires multiple resize events while you are dragging the browser window which
        // causes it to crash if you try to update the scrollpane on every one. So we need
        // to throttle it to fire a maximum of once every 50 milliseconds...
        if (!throttleTimeout) {
            throttleTimeout = setTimeout(function() {
                api.reinitialise();
                throttleTimeout = null;
            }, 50);
        }
    } else {
        api.reinitialise();
    }
}

$.fn.serializeObject = function()
{
    var o = {};
    var a = this.serializeArray();
    $.each(a, function() {
        if (o[this.name] !== undefined) {
            if (!o[this.name].push) {
                o[this.name] = [o[this.name]];
            }
            o[this.name].push(this.value || '');
        } else {
            o[this.name] = this.value || '';
        }
    });
    return o;
};

function openHowItWorks() {
    $('.content-group').addClass('hidden');
    //markerManager.hideAllMarkers();
    
    $('#how_it_works').removeClass('hidden');
    $('.how-it-works').removeClass('hidden');
    $('.remove-how-it-works').addClass('hidden');
}

function closeHowItWorks() {
    $('#how_it_works').addClass('hidden');
    $('.how-it-works').addClass('hidden');
    $('.remove-how-it-works').removeClass('hidden');

    //markerManager.showAllMarkers();
    $('.content-group').removeClass('hidden');
}

function openFeedback() {
    $('.content-group').addClass('hidden');
    //markerManager.hideAllMarkers();

    $('#feedback').removeClass('hidden');
    $('.feedback').removeClass('hidden');
    $('.remove-how-it-works').addClass('hidden');
}

function closeFeedback() {
    $('#feedback').addClass('hidden');
    $('.feedback').addClass('hidden');
    $('.remove-how-it-works').removeClass('hidden');

    //markerManager.showAllMarkers();
    $('.content-group').removeClass('hidden');
}

function getInternetExplorerVersion()
// Returns the version of Windows Internet Explorer or a -1
// (indicating the use of another browser).
{
    var rv = -1; // Return value assumes failure.
    if (navigator.appName == 'Microsoft Internet Explorer')
    {
        var ua = navigator.userAgent;
        var re  = new RegExp("MSIE ([0-9]{1,}[\.0-9]{0,})");
        if (re.exec(ua) != null)
            rv = parseFloat( RegExp.$1 );
    }
    return rv;
}

