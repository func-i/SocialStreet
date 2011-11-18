$(function() {
    $('#left_side_pane').addClass('hidden');
    $('#center_pane').removeClass('invisible');
    $('.remove-how-it-works').addClass('hidden');

    resizePageElements();

    $('a[data-popup]').live('click', function(e) {
        window.open($(this).attr('href'));
        e.preventDefault();
    }); 
});


