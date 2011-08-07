$(function() {
    $( "#starts_at_calendar" ).datepicker({
        dateFormat: 'yy-mm-dd',
        showOn: "both",
        buttonImage: '/images/calendar_grey.png',
        buttonImageOnly: true
    });

    $( "#ends_at_calendar" ).datepicker({
        dateFormat: 'yy-mm-dd',
        showOn: "both",
        buttonImage: '/images/calendar_grey.png',
        buttonImageOnly: true
    });

    $('.starts_at_time').change(function() {
        $('.starts_at_value').val($('#starts_at_calendar').val() + ' ' + $($('.starts_at_time')[1]).val() + ':' + $($('.starts_at_time')[2]).val());

        var stTime = $('#starts_at_calendar').datepicker('getDate');
        stTime.setHours($($('.starts_at_time')[1]).val());
        stTime.setMinutes($($('.starts_at_time')[2]).val());

        var diff = $('.ends_at_time').data("diff_milli")
        if(!diff)
            diff = 10800000 //3 hours

        var endTime = new Date(stTime.getTime());
        endTime.setMilliseconds(stTime.getMilliseconds() + diff);
        
        $('#ends_at_calendar').val(endTime.format('yyyy-mm-dd'));
        $($('.ends_at_time')[1]).val(endTime.format('HH'));
        $($('.ends_at_time')[2]).val(endTime.format('MM'));
        $('.ends_at_time').trigger('change');
    });

    $('.ends_at_time').change(function() {
        $('.ends_at_value').val($('#ends_at_calendar').val() + ' ' + $($('.ends_at_time')[1]).val() + ':' + $($('.ends_at_time')[2]).val());

        var stTime = $('#starts_at_calendar').datepicker('getDate');
        stTime.setHours($($('.starts_at_time')[1]).val());
        stTime.setMinutes($($('.starts_at_time')[2]).val());

        var endTime = $('#ends_at_calendar').datepicker('getDate');
        endTime.setHours($($('.ends_at_time')[1]).val());
        endTime.setMinutes($($('.ends_at_time')[2]).val());

        var diff = endTime - stTime;

        $('.ends_at_time').data("diff_milli", diff);
    });
});