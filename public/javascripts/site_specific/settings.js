$(function(){
    cleanUpSelf = function(){
    }

    resizeSelf = function(){
        resizeCenterPaneContent();
    }

    $('.edit-inline').live('mouseenter', function(){
        $(this).addClass('edit-inline-mouseover');
    });
    $('.edit-inline').live('mouseleave', function(){
        $(this).removeClass('edit-inline-mouseover');
    });
    $('.edit-inline').live('click', function(){
        $(this).removeClass('edit-inline-mouseover');
    });


    $('.submit-on-change').live('keyup', function(e){
        if(e.keyCode == 13){
            $(this).blur();
        }
    });
    $('.submit-on-change').live('change', function(){
        $('#settings_form').submit();
    });

    $('#add_group_button').live('click', function(){
       showGroups();
    });
});

function resizeCenterPaneContent(){
    var centerPaneBottom = $('#center_pane').offset().top + $('#center_pane').height();
    var scrollerTop = $('#groups_scroller').offset().top;
    $('#groups_scroller').height(centerPaneBottom - scrollerTop);
}
