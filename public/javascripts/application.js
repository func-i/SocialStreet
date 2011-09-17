cleanUpSelf = function(){};

if(history && history.pushState) {
    $(function() {
        $('.nav-link').live('click', function(e) {
            
            if(typeof cleanUpSelf == 'function') {
                cleanUpSelf();
                cleanUpSelf = function(){}
            }
            markerManager.deleteAllMarkers();

            var href;
            if(this.href != undefined) {
                href = this.href;
            }
            else if($(this).data('ajax-href') != '') {
                href = $(this).data('ajax-href');
            }
            
            if(href != undefined) {
                $.getScript(href);
                history.pushState(null, "", href);
                e.preventDefault();
            }
        })

        $(window).bind('popstate', function() {
            $.getScript(location.href);
        });
       
    });
}