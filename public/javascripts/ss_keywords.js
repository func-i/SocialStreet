var isOpen = false;
var eventTypeTimer = null;

$(function(){

    //Text field gets focus, show
    $('.keyword-text-field').live('focus', function(){
        //Clear any value in the text field
        $(this).val('');
        reset();

        //show event type holder
        showEventTypeHolder();
    });

    //User clicks on doc away from event type or text field, hide
    $(document).bind("click", function(e){
        if(isOpen &&
            isOnExplore() &&
            $(e.target).closest('.keyword-text-field-holder').length < 1 &&
            $(e.target).closest('.event-type').length < 1)
            {
            hideEventTypeHolder();
        }
    });


    //User clicked on an event type in the holder
    $('.event-type').live('click', function(){
        eventTypeClicked(this);

        $('.keyword-text-field').val('');

        if(isOnExplore()){
            hideEventTypeHolder();
        }

        reset();
        $('.keyword-text-field').blur();
    });

    //User types into the text field
    $('.keyword-text-field').live('keyup', function(e)
    {
        if(eventTypeTimer){
            clearTimeout(eventTypeTimer);
            delete eventTypeTimer;
        }

        if(e.target.value.length < 1){
            reset();
            return;
        }
        
        var keyword_arr = e.target.value.split(',');

        if(e.keyCode == 13){//Enter
            addKeyword(keyword_arr[keyword_arr.length - 1]);

            if(isOnExplore()){
                hideEventTypeHolder();
            }
            reset();
            $('.keyword-text-field').blur();

        }
        else if(e.keyCode == 188){//comma
            addKeyword(keyword_arr[keyword_arr.length - 2])
        }
        else{
            eventTypeTimer = setTimeout(function()
            {
                keywordTyped(keyword_arr[keyword_arr.length - 1]);
            }, 250);
        }
    });

    //User clicks on a tag
    $('.remove-keyword-tag').live('click', function(){
        removeKeyword(this);
    });

});

function showEventTypeHolder(){
    $('#event_types_holder').removeClass('hidden');
    $('#center_pane').removeClass('invisible');

    resizePageElements();
    initScrollPane($('#event_types_scroller'));

    isOpen = true;
}

function hideEventTypeHolder(){
    $('#event_types_holder').addClass('hidden');
    $('#center_pane').addClass('invisible');

    isOpen = false;
}

function reset(){
    $.each($('.event-type'), function(index, et){
        var $et = $(et);
        if($et.hasClass('synonym'))
            $et.addClass('hidden');
        else
            $et.removeClass('hidden');
    });

    $('.keyword-text-field').val('');

    $('#custom_event_type .event-type-name').text('');
    $('#custom_event_type').addClass('hidden');
    resizePageElements();
}

function eventTypeClicked(eventType, refreshResults){
    var $eventType = $(eventType);
    var keywordName = $.trim($eventType.find('.event-type-name').text());
    var keywordIconClass = 'event-type-' + $eventType.find('.event-type-image').data('event-type') + (isOnExplore() ? '-small-sprite' : '-medium-sprite');

    if(!keywordAlreadyExists(keywordName)){
        if(isOnExplore()){
            addKeywordToHolder(keywordName, keywordIconClass);

            $('#explore_search_params').append(
                '<input type="hidden" name="keywords[]" class="keyword-input" value="' + keywordName + '" />'
                );

            $('#explore_keyword_header').removeClass('hidden').removeClass('invisible');
            if($('.keyword-tag-holder').height() > 150)
                initScrollPane($('.keyword-tag-holder'));

            if(undefined == refreshResults || refreshResults){
                refreshExploreResults();
            }
        }
        else if(isOnCreateWhat()){
            addKeywordToHolder(keywordName, keywordIconClass);

            $('#event_create_form').append(
                '<input type="hidden" name="event[event_keywords_attributes][][name]" class="keyword-input" value="' + keywordName + '" />'
                );

            resizeWhatTags();

            $('#create_what_next_arrow').removeClass('invisible');
            $('#create_what_tags').removeClass('invisible');
        }
    }
}

function addKeywordToHolder(keywordName, keywordIconClass){
    var $newKeyword = $($('#keyword_tag_stamp').clone());
    $newKeyword[0].id = "";
    $newKeyword.find('.keyword-tag-name').text(keywordName);
    $newKeyword.find('.keyword-tag-icon').addClass(keywordIconClass);
    $('#keyword_tag_list').append($newKeyword);
    $newKeyword.removeClass('hidden');
}

function keywordAlreadyExists(keywordName){
    var rtn = false;
    var trimmedKeywordName = $.trim(keywordName).toLowerCase();
    $.each($('.keyword-tag-name'), function(index, name){
        if($.trim($(name).text()).toLowerCase() == trimmedKeywordName){
            rtn = true;
            return;
        }
    });

    return rtn;
}

function addKeyword(keyword, refreshResults){
    if(keyword.length < 1)
        return;

    if(undefined == refreshResults)
        refreshResults = true;

    keywordTyped(keyword);

    var addType = $('.exact-match').first();
    if(addType.length < 1)
        addType = $('.event-type').not('.hidden').first();

    eventTypeClicked(addType, refreshResults);
}

function keywordTyped(text){
    var trimmedText = $.trim(text);
    var regEx = new RegExp(trimmedText, "i");
    var exact_match = false;
    var lowerCaseText = trimmedText.toLowerCase();
        
    $.each($('.event-type').not('#custom_event_type').find('.event-type-name'), function(index, name){
        var $name = $(name);

        if($.trim($name.text()).match(regEx) == null){
            $name.closest('.event-type').removeClass('exact-match').addClass('hidden');//Hide event type if no match
        }
        else{
            $name.closest('.event-type').removeClass('hidden');//Show event type if match

            if($.trim($name.text()).toLowerCase() == lowerCaseText){
                $name.closest('.event-type').addClass('exact-match');
                exact_match = true;
            }
        }
    });

    if(trimmedText.length < 1 || exact_match){
        $('#custom_event_type').addClass('hidden');
    }
    else{
        $('#custom_event_type .event-type-name').text(trimmedText);
        $('#custom_event_type').removeClass('hidden');
    }

    resizePageElements();
}

function removeKeyword(keywordCloseDom){
    var $keywordTag = $(keywordCloseDom).closest('.keyword-tag');
    var keywordText = $.trim($keywordTag.find('.keyword-tag-name').text());

    $keywordTag.remove();

    var inputElem = null;
    $.each($('.keyword-input'), function(index, input){
        if($(input).val() == keywordText){
            inputElem = input;
            return;
        }
    });
    if(inputElem){
        $(inputElem).remove();
    }
    
    if(isOnExplore()){
        refreshExploreResults();

        if($('.keyword-tag').not('#keyword_tag_stamp').length < 1){
            $('#explore_keyword_header').addClass('hidden').addClass('invisible');
        }

        if($('.keyword-input').length==2) {
            if($('.keyword-tag-holder').data('jsp'))
                $('.keyword-tag-holder').data('jsp').destroy();
            $('.keyword-tag-holder').height('auto');
        }
    }
    else if(isOnCreateWhat()){
        if($('.keyword-tag').not('#keyword_tag_stamp').length < 1){
            $('#create_what_next_arrow').addClass('invisible');
            $('#create_what_tags').addClass('invisible');
        }

        if($('.keyword-tag-holder').data('jsp'))
            $('.keyword-tag-holder').data('jsp').destroy();
        $('.keyword-tag-holder').height('auto');

        resizeWhatTags();
    }
}

function isOnExplore(){
    return $('#on_explore').length > 0;
}
function isOnCreateWhat(){
    return $('#on_create_what').val() && $('#on_create_what').val().length > 0;
}

