$(function(){
    openCenterPaneView();

    cleanUpSelf = function(){
        google.maps.event.removeListener(mapListener);
    }

    resizeSelf = function(){
        var centerPaneBottom = $('#center_pane').offset().top + $('#center_pane').height();
        var scrollerTop = $('#scroller').offset().top;
        $('#scroller').height(centerPaneBottom - scrollerTop);
        initializeScrollPanes();
    }

    resizePageElements();


    var mapListener = google.maps.event.addListener(map, 'click', function(){
        $('.logo').click();
    });

});
