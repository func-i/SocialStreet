$(function() {

    function addKeyword(keyword) {
        if ($('#keywords .keyword-pill input[type="hidden"][value="'+keyword+'"]').size() > 0) return false;
        $('<li class="keyword-pill">' +
            '<input type="hidden" name="'+keywordsParamKey+'" value="'+keyword+'">' +
            keyword +
            '<a href="#" class="remove-parent" data-parent-selector=".keyword-pill">' +
            '<img src="/images/web-app-theme/icons/cross.png" />' +
            '</li>').hide().appendTo($('#keywords')).fadeIn('slow');
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
            addKeyword(this.value);
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
            addKeyword(ui.item.value);
            return false;
        }
    });
});
