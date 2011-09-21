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
                history.pushState({}, "", href);
                e.preventDefault();
            }
        });

        var popped = (null === window.history.state), initialURL = location.href;

        $(window).bind('popstate', function() {
            var initialPop = !popped && location.href == initialURL;
            popped = true;
            if ( initialPop ){
                return;
            } 

            $.getScript(location.href);
        });

        $('#log_button').click(function() {
            window.location = $(this).data('href');
        })
       
    });
}

$(function(){

    //setup scrollers
    $('.scroller').jScrollPane();
    
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

    function resizeResultsContainer() {
        var docHeight = $(window).height();

        $.each($('.expand-height'), function(i, ele) {
            var cPos = $(ele).offset().top;
            var cHeight = docHeight - cPos;

            $(ele).height(cHeight);
        });      
    }

    if($('.expand-height').length > 0) {
        $(window).load(resizeResultsContainer()).resize(function() {
            resizeResultsContainer();
        });
    }


});
