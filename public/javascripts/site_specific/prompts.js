$(function() {

    $('.next-prompt').live('click', function() {
        if($(this).attr('id') == 'send_prompt_button') {
            var href = $('#prompt_follow_href').val();

            var promptAnswer = $('#prompt_form').serialize();
            if(promptAnswer != '')
                href = href + '&prompt_answer=' + promptAnswer;

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
            $(this).parent('.event-prompt').addClass('hidden');
            console.log($(this).attr('data-next-prompt'));
            $('#' + $(this).attr('data-next-prompt')).removeClass('hidden');
        }
    });

    $('#close_prompt_btn').live('click', function(){
        hidePrompt();
    });
});


function customPrompt(promptPath, href) {
    $.ajax({
        url: promptPath,
        success: function(data) {
            $('#prompt_holder').html(data);
            $('#prompt_holder .event-prompt').first().removeClass('hidden')
        }
    });
    
    showPrompt();
    $('#prompt_follow_href').val(href);
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