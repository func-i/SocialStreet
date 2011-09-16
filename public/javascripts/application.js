$(function() {
    $('a.nav-link').live('click', function() {
        if(history && history.pushState) {
            history.pushState(null, "", this.href);
            if(typeof cleanUpSelf == 'function') {
                cleanUpSelf();
                delete cleanUpSelf
            }
        }
        $.getScript(this.href);
        return false;
    })

    if(history && history.pushState) {   
        $(window).bind("popstate", function() {
            $.getScript(location.href);
            return false;
        });
    }
});