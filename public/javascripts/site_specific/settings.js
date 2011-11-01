$(function(){
    cleanUpSelf = function(){
    }

    resizeSelf = function(){
        resizeCenterPaneContent();
    }

    $('#add_group_button').live('click', function(){
       showGroups();
    });
});

function resizeCenterPaneContent(){
    var centerPaneBottom = $('#center_pane').offset().top + $('#center_pane').height();
    var scrollerTop = $('#groups_scroller').offset().top;
    $('#groups_scroller').height(centerPaneBottom - scrollerTop);
}
