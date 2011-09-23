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

    if($('.expand-height').length > 0) {

        $(window).load(resizeExpandHeightContainer()).resize(function() {
            resizeExpandHeightContainer();
        });

        initializeScrollPanes();
    }

    $('.scroll-pane').live('mouseenter', function(){
        $(this).find('.jspVerticalBar').removeClass('hidden');
    });

    $('.scroll-pane').live('mouseleave', function(){
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

function initializeScrollPanes()
{
    $('.scroll-pane').each(function() {
        $(this).jScrollPane();

        $(this).find('.jspVerticalBar').addClass('hidden');

        var that = this;
        $(window).bind('resize', function() {
            //resizeScrollPane(that);
        });
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
        var cHeight = docHeight - cPos;

        $(ele).height(cHeight);
    });
}

function updateUserLocation(latitude, longitude, updateDB){
    $.getScript('/locations/update_user_location?latitude=' + latitude + '&longitude=' + longitude + '&=update_db=' + updateDB, function(data, textStatus){});
}

