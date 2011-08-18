function addKeyword(keyword, selector) {
    if ($(selector + ' .keyword-pill input[type="hidden"][value="'+keyword.replace("+", " ")+'"]').size() > 0 || keyword == '')
        return false;

    var $inputName;
    if(selector == "#event-keywords")
    {
        //On the event create modal
        $inputName = "event[searchable_attributes][keywords][]";
    }
    else{
        //On the explore page
        $inputName = "keywords[]";
    }


    $('<li class="keyword-pill" container-selector = "' + selector + '">' +
        keyword.replace("+", " ") +
        '<a href="#" class="close remove-parent" data-parent-selector = ".keyword-pill">close</a>' +
        '<input type="hidden" name="' + $inputName  + '" value="' +keyword.replace("+", " ") + '" />' +
        '</li>'
        ).hide().appendTo($(selector)).fadeIn('slow');

    if(selector == "#explore-keywords"){
    //Update comment-box text
    //updateCommentBox();
    }

    if(typeof checkMapPageSize == 'function')
        checkMapPageSize();

    return true;
}

function removeKeyword(keyword) {
    
    var liLink = $(".keyword-pill:contains('" + keyword + "')").children("a");

    if(liLink.length != 0) {
        var $this = $(liLink);
        var parentSelector = $this.data('parent-selector');
        if (parentSelector) {
            $this.closest(parentSelector).remove();
        }

        if(parentSelector == "#explore-keywords"){
    //Update comment-box text
    //updateCommentBox();
    }
    }
}

function existingKeywords(selector) {
    var keywordListItems = $(selector).children();
    var keywords = new Array();

    $.each(keywordListItems, function(liIndex, listItem) {
        $.each($(listItem).children(), function(inputIndex, input){
            if(input.tagName == "INPUT")
                keywords.push($(input).val());
        });
    });

    return keywords;
}

function arraySubtract(ara1,ara2) {
    var aRes = new Array();
    $.each(ara1, function(index, element) {
        if($.inArray(element, ara2) == -1)
            aRes.push(element);
    });
    return aRes ;
}

$(function() {
    //updateCommentBox();

    function keywordHandler(keyword, keywordContentSelector) {
        if(addKeyword(keyword, keywordContentSelector))
            if (typeof refreshResults == "function") {
                if(caller == "explore" && history && history.pushState){
                    history.pushState(null, null, getSearchParams());
                }
                var caller;
                //  TODO: possibly look at cleaning this up later
                if(keywordContentSelector == '#explore-keywords')
                    caller = "explore";
                else
                    caller = "events";
                
                refreshResults(caller);
            }
    }
    

    $('.keyword-pill').live('ss:removed', function() {
        if (typeof refreshResults == "function") {
            var caller;

            if($(this).attr("container-selector") == '#explore-keywords'){
                caller = "explore";
            //updateCommentBox();
            }
            else
                caller = "events";

            if(caller == "explore" && history && history.pushState)
                history.pushState(null, null, getSearchParams());

            refreshResults(caller);
        }

        if(typeof checkMapPageSize == 'function')
            checkMapPageSize();

    });

    $('.q-textfield').keydown(function(e) {
        if (e.keyCode == 13) {
            keywordHandler(this.value, $(this).attr('keyword-content-selector'));
            this.value = '';
            $(this).autocomplete('close');
            //e.stopPropagation();
            return false;
        }
        return true;
    });

    $('.q-textfield').bind("autocompletechange", function(e) {
        keywordHandler(this.value, $(this).attr('keyword-content-selector'));
        this.value = '';
        //e.stopPropagation();
        return false;
    });


    // local key/val cache so if it does ajax json for "ba", it caches the result the first time.
    // So if user types "ba" again it uses the local cache instead of doing another AJAX request - KV
    var cache = {},
    lastXhr;
    $( ".q-textfield" ).autocomplete({
        minLength: 1,
        autofill: true,
        delay: 100,
        source: function( request, response ) {
            var term = request.term;
            //if ( term in cache ) {
            //   response( cache[ term ] );
            //    return;
            //}
            // TODO: Re-enable the code above!!
            lastXhr = $.getJSON( keywordsJsonURL, request, function( data, status, xhr ) {
                if(data.indexOf(term) < 0)
                    data.unshift(term.toString());

                cache[ term ] = data;

                if ( xhr === lastXhr ) {
                    response( data );
                }
            });
        },
        select: function( event, ui ) {
            keywordHandler(ui.item.value, $(this).attr('keyword-content-selector'));
            this.value = '';
            $('.q-textfield').val('');
            return false;
        },
        html: true
    });
});
