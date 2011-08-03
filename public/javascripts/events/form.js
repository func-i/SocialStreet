$(function() {
    $( "#starts_at_calendar" ).datepicker({
        dateFormat: 'M. dd, yy'
    });

    $( "#ends_at_calendar" ).datepicker({
        dateFormat: 'M. dd, yy'
    });

    $('.starts_at_time').change(function() {
        $('.starts_at_value').val($('#starts_at_calendar').val() + ' ' + $($('.starts_at_time')[1]).val() + ':' + $($('.starts_at_time')[2]).val());
    })

    $('.ends_at_time').change(function() {
        $('.ends_at_value').val($('#ends_at_calendar').val() + ' ' + $($('.ends_at_time')[1]).val() + ':' + $($('.ends_at_time')[2]).val());
    })
});