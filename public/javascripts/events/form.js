$(function() {
  $('#main ul.wat-cf > li > a').click(function(e){
    $('.tab-content').hide();
    $('.secondary-navigation li').removeClass('active');
    $(this).closest('li').addClass('active');
    $($(this).data('tab')).show();
    return false;
  });
});