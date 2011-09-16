if(history && history.pushState) {
    $(function() {
        $('a.nav-link').live('click', function(e) {
            
            if(typeof cleanUpSelf == 'function') {
                cleanUpSelf();
            }
             
            $.getScript(this.href);
            history.pushState(null, "", this.href);
            e.preventDefault();
        
        })

        $(window).bind('popstate', function() {
            $.getScript(location.href);
        });
       
    });
}