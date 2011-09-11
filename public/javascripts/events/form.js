$(function() {
    $( "#starts_at_calendar" ).datepicker({
        dateFormat: 'yy-mm-dd',
        showOn: "both",
        buttonImage: '/images/calendar_grey.png',
        buttonImageOnly: true
    });

    $('.starts-at-time').change(function() {
        var stHour = $($('.starts-at-time')[1]).val();
        var stMeridian = $($('.starts-at-time')[3]).val();
        if(stMeridian == 'PM'){
            var hour = parseInt(stHour, 10);
            stHour = hour + (hour == 12 ? 0 : 12);
        }

        $('.starts-at-value').val($('#starts_at_calendar').val() + ' ' + stHour + ':' + $($('.starts-at-time')[2]).val());
    });
});