$(function() {
    $('.textarea-resize').autoResize();
    $('#send_message_button').click(function() {
       $('#send_message_form').submit();
    });
});

