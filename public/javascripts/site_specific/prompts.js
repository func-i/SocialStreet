$(function() {

    $('.next-prompt').live('click', function() {
        if($(this).hasClass('send-prompt-button')) {
            var href = $('#prompt_follow_href').val();
            var promptAnswer = $('#prompt_form .prompt-answer').serialize();            

            if(promptAnswer != '')
                if(href.indexOf("?") != -1)
                    href = href + '&' + promptAnswer;
                else
                    href = href + '?' + promptAnswer;
            hidePrompt();
            cleanup();
            if(history && history.pushState)
                $.getScript(href, function() {
                    resizePageElements();
                    setPlaceholdersInInternetExplorer();
                });
            else
                window.location = href;
        }
        else {
            
            if($(this).hasClass('no-prompt')) {
                $(this).closest('.event-prompt').find('input[type=hidden]').val('no')
            }
            else if($(this).hasClass('yes-prompt')) {
                $(this).closest('.event-prompt').find('input[type=hidden]').val('yes')
            }

            $(this).parent('.event-prompt').addClass('hidden');
            $('#' + $(this).attr('data-next-prompt')).removeClass('hidden');
        }
    });

    $('#close_prompt_btn').live('click', function(){
        hidePrompt();
    });

    $('#close_full_event_btn').live('click', function(){
        hideFullEvent();
    });
});


function customPrompt(promptPath, href) {
    $('#prompt_holder').html('');
    $.ajax({
        url: promptPath,
        success: function(data) {
            $('#prompt_holder').html(data);
            $('#prompt_holder .event-prompt').first().removeClass('hidden');
            $('#prompt_follow_href').val(href);
        }
    });    
    showPrompt();
}

function showPrompt(){
    $('#prompt_container').removeClass('invisible');
    $('#prompt_holder').removeClass('hidden');
    resizePageElements();
}
function hidePrompt(){
    $('#prompt_container').addClass('invisible');
    $('#prompt_holder').addClass('hidden');
    resizePageElements();
}

function hideFullEvent(){
    $('#alert_container').addClass('invisible');
}