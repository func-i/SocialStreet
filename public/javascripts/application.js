cleanUpSelf = function(){};

$(function() {
    $('.nav-link').live('click', function(e) {
        cleanup();

        var href;
        if(this.href != undefined) {
            href = this.href;
        }
        else if($(this).data('ajax-href') != '') {
            href = $(this).data('ajax-href');
        }
            
        if(href != undefined) {
            if(history && history.pushState) {
                $.getScript(href);
                history.pushState({}, "", href);
            }
            else{
                window.location = href;
            }
            e.preventDefault();
        }
    });

    var popped = (window.history && null === window.history.state), initialURL = location.href;

    $(window).bind('popstate', function() {
        var initialPop = !popped && location.href == initialURL;
        popped = true;
        if ( initialPop ){
            return;
        }

        cleanup();
            
        $.getScript(location.href);
    });

    $('#log_button').click(function() {
        window.location = $(this).data('href');
    });

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

    if(-1 == document.cookie.indexOf('current_location_latitude') || -1 == document.cookie.indexOf('current_location_longitude'))
    {
        if(navigator.geolocation){
            navigator.geolocation.getCurrentPosition(function(e){
                updateUserLocation(e.coords.latitude, e.coords.longitude, true);
            }, function(e){
                },{
                    maximumAge: 600000,
                    timeout: 20000
                });
        }
    }

    resizeExpandHeightContainer();
    capHeightContainer();

    $(window).resize(function() {
        resizeExpandHeightContainer();
        capHeightContainer();
    });

    initializeScrollPanes();

    $('.show-scroll-on-hover').live('mouseenter', function(){
        $(this).find('.jspVerticalBar').removeClass('hidden');
    });

    $('.show-scroll-on-hover').live('mouseleave', function(){
        $(this).find('.jspVerticalBar').addClass('hidden');
    });

});

function cleanup(){
    if(typeof cleanUpSelf == 'function') {
        cleanUpSelf();
        cleanUpSelf = function(){}
    }
    markerManager.deleteAllMarkers();
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
    $myElem.jScrollPane();

    if($(this).hasClass('show-scroll-on-hover')){
        $(this).find('.jspVerticalBar').addClass('hidden');
    }

    var that = $myElem;
    $(window).bind('resize', function() {
        resizeScrollPane(that);
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

function updateUserLocation(latitude, longitude, updateDB){
    $.getScript('/locations/update_user_location?latitude=' + latitude + '&longitude=' + longitude + '&=update_db=' + updateDB, function(data, textStatus){});
}

