function addKeyword(keyword, selector) {
    
    if ($(selector + ' .keyword-pill input[type="hidden"][value="'+keyword+'"]').size() > 0 || keyword == '') return false;
    $('<li class="keyword-pill">' +
      keyword +
      '<a href="#" class="close remove-parent" data-parent-selector = ".keyword-pill">close</a>' +
      '<input type="hidden" name="event[searchable_attributes][keywords][]" value="' +keyword + '" />' +
      '</li>'
    ).hide().appendTo($(selector)).fadeIn('slow');
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
    
    function keywordHandler(keyword) {
        if(addKeyword(keyword, '#explore-keywords'))
            if (typeof refreshResults == "function") {
                if(history && history.pushState)
                    history.pushState(null, null, getSearchParams());
                refreshResults();
            }
    }
    

    $('.keyword-pill').live('ss:removed', function() {
        if (typeof refreshResults == "function") {
            if(history && history.pushState)
                history.pushState(null, null, getSearchParams());
            refreshResults();
        }
    });

    $('#q-textfield').keydown(function(e) {
        if (e.keyCode == 13) {
            console.log('enter pressed');
            keywordHandler(this.value);
            this.value = '';
            e.stopPropagation();
            return false;
        }
        return true;
    });


    // local key/val cache so if it does ajax json for "ba", it caches the result the first time.
    // So if user types "ba" again it uses the local cache instead of doing another AJAX request - KV
    var cache = {},
    lastXhr;
    $( "#q-textfield" ).autocomplete({
        minLength: 2,
        source: function( request, response ) {
            var term = request.term;
            if ( term in cache ) {
                response( cache[ term ] );
                return;
            }

            lastXhr = $.getJSON( keywordsJsonURL, request, function( data, status, xhr ) {
                cache[ term ] = data;
                if ( xhr === lastXhr ) {
                    response( data );
                }
            });
        },
        select: function( event, ui ) {
            console.log('item selected');
            this.value = '';
            keywordHandler(ui.item.value);
            return false;
        }
    });
});
