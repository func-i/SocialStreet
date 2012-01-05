$(function() {
    openCenterPaneView();
    $('.remove-how-it-works').addClass('hidden');

    resizePageElements();

    $('a[data-popup]').live('click', function(e) {
        window.open($(this).attr('href'));
        e.preventDefault();
    }); 
});


