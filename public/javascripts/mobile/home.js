$('#sign-in').live('click', function() {
    window.location.href='/auth/facebook?redirect_uri=blah';
    return false;
  })

$('#explore_btn').live('click', function(e) {
    
    window.location.href = '/m/explore';
    console.log('explorer...');
    e.preventDefault();
});

$('#new_event_btn').live('click', function(e) {
    
    window.location.href = '/m/events/new';
    e.preventDefault();
});

$('#home_page').live('pageshow', function() {
    document.ontouchmove = function(e){ e.preventDefault(); }
})

$(window).bind('orientationchange', function(e) {
    if(e.orientation == 'portrait') {
        document.ontouchmove = function(e){ e.preventDefault(); }
        $(window).resize();
    }
    else
        document.ontouchmove = function(e){ }
});

  
  $('#home_page').live('pageinit', function() {
    window.setTimeout(function() {
      var bubble = new google.bookmarkbubble.Bubble();
  
      var parameter = 'bmb=1';
  
      bubble.hasHashParameter = function() {
        return window.location.hash.indexOf(parameter) != -1;
      };
  
      bubble.setHashParameter = function() {
        if (!this.hasHashParameter()) {
          window.localStorage += parameter;
        }
      };
  
      bubble.getViewportHeight = function() {
        window.console.log('Example of how to override getViewportHeight.');
        return window.innerHeight;
      };
  
      bubble.getViewportScrollY = function() {
        window.console.log('Example of how to override getViewportScrollY.');
        return window.pageYOffset;
      };
  
      bubble.registerScrollHandler = function(handler) {
        window.console.log('Example of how to override registerScrollHandler.');
        window.addEventListener('scroll', handler, false);
      };
  
      bubble.deregisterScrollHandler = function(handler) {
        window.console.log('Example of how to override deregisterScrollHandler.');
        window.removeEventListener('scroll', handler, false);
      };
  
      bubble.showIfAllowed();
    }, 1000);
  })