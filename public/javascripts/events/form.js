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

    $('.starts-at-time').change(function() {
        var stHour = $($('.starts-at-time')[1]).val();
        var stMeridian = $($('.starts-at-time')[3]).val();
        if(stMeridian == 'PM')
            stHour = parseInt(stHour, 10) + 12;

        $('.starts-at-value').val($('#starts_at_calendar').val() + ' ' + stHour + ':' + $($('.starts-at-time')[2]).val());

        var stTime = $('#starts_at_calendar').datepicker('getDate');
        stTime.setHours(stHour);
        stTime.setMinutes($($('.starts-at-time')[2]).val());

        var diff = $('.ends-at-time').data("diff_milli")
        if(!diff)
            diff = 10800000 //3 hours

        var endTime = new Date(stTime.getTime());
        endTime.setMilliseconds(stTime.getMilliseconds() + diff);
        
        $('#ends_at_calendar').val(endTime.format('yyyy-mm-dd'));
        $($('.ends-at-time')[1]).val(endTime.format('hh'));
        $($('.ends-at-time')[2]).val(endTime.format('MM'));
        $($('.ends-at-time')[3]).val(endTime.format('TT'));
        $('.ends-at-time').trigger('change');
    });

    $('.ends-at-time').change(function() {
        var endHour = $($('.ends-at-time')[1]).val();
        var endMeridian = $($('.ends-at-time')[3]).val();
        if(endMeridian == 'PM')
            endHour = parseInt(endHour, 10) + 12;

        $('.ends_at_value').val($('#ends_at_calendar').val() + ' ' + endHour + ':' + $($('.ends-at-time')[2]).val());

        var stHour = $($('.starts-at-time')[1]).val();
        var stMeridian = $($('.starts-at-time')[3]).val();
        if(stMeridian == 'PM')
            stHour = parseInt(stHour, 10) + 12;

        var stTime = $('#starts_at_calendar').datepicker('getDate');
        stTime.setHours(stHour);
        stTime.setMinutes($($('.starts-at-time')[2]).val());

        var endTime = $('#ends_at_calendar').datepicker('getDate');
        endTime.setHours(endHour);
        endTime.setMinutes($($('.ends-at-time')[2]).val());
        
        var diff = endTime - stTime;

        $('.ends-at-time').data("diff_milli", diff);
    });
});