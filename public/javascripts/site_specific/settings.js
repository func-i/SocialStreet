$(function(){
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
});