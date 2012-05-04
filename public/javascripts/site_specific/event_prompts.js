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

    $('.toggle-fields').click(function() {        
        $(this).closest('table').find('.prompt-field').each(function(i, element) {
            console.log(element);
            $(element).toggleDisabled();
        });
    });

});

(function($) {
    $.fn.toggleDisabled = function() {
        return this.each(function() {
            var $this = $(this);
            if ($this.attr('disabled')) $this.removeAttr('disabled');
            else $this.attr('disabled', 'disabled');
        });
    };
})(jQuery);
