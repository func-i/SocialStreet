$.fn.serializeObject = function()
    {
        var o = {};
        var a = this.serializeArray();
        $.each(a, function() {
            if (o[this.name] !== undefined) {
                if (!o[this.name].push) {
                    o[this.name] = [o[this.name]];
                }
                o[this.name].push(this.value || '');
            } else {
                o[this.name] = this.value || '';
            }
        });
        return o;
    };

$(function() {
    $('.remove-parent').live('click', function(event) {
        var $this = $(this);
        var parentSelector = $this.data('parent-selector');
        if (parentSelector) {
            $this.closest(parentSelector).remove();
        }
        $this.trigger('ss:removed');
        return false;
    });

    $('.popup-modal').live('click', function() {
        var divId = '#' + $(this).attr('popup-div-id');
        $(divId).show();

        if(document.getElementById("TB_overlay") === null){
            $("body").append("<div id='TB_overlay'></div>");
            $("#TB_overlay").addClass("TB_overlayBG");
            $("#TB_overlay").click(function(){
                removeModal($(divId))
            });
        }

        if( $(this).attr('action_id') != null)
        {
            //this is for creating event from comment section
            var u = $(divId).find('#event_action_id')
            if(u != null){
                u.val($(this).attr('action_id'))
            }
        }

        console.log($(divId).find('.row-map').length);
        if($(divId).find('.row-map').length > 0)
            google.maps.event.trigger(map, 'resize');

        return false;
    });

    $('.popup-modal-ajax').live('click', function() {
        var divId = '#' + $(this).attr('popup-div-id');
        var title = $(this).attr('modal-title')
        var requestURL = $(this).attr('request-url');
        var requestParams = $(this).attr('request-params');

        popup_modal_ajax(divId, title, requestURL, requestParams);
    });

    $('.btn-close').live('click', function() {
        removeModal(this);
    });

    $('.link-close').live('click', function() {
        removeModal(this);
    });
})

function popup_modal_ajax(modal_divID, modal_title, requestURL, requestParams){
    //Set the modal title
    $(modal_divID).find('#modal-title').text(modal_title)

    //Display the modal
    $(modal_divID).show();

    console.log($(modal_divID))

    //Display overlay
    if(document.getElementById("TB_overlay") === null){
        $("body").append("<div id='TB_overlay'></div>");
        $("#TB_overlay").addClass("TB_overlayBG");
        $("#TB_overlay").click(function(){
            removeModal($(modal_divID))
        });
    }

    var request = requestURL.valueOf();

    //Send request to load data into the modal
    if(requestParams != null)
        request += "?=" + requestParams.valueOf();

     console.log(requestURL);
     console.log(request);
     
    $.getScript(request);
}

function removeModal(element) {
    var ele;

    if($(element).hasClass('.pop-up'))
        ele = $(element)
    else
        ele = $(element).closest('.pop-up')

    $(ele).fadeOut("fast", function() {
        $('#TB_overlay').trigger("unload").unbind().remove();
    }); 
}


$.extend({
    getUrlVars: function(){
        var vars = [], hash;
        var hashes = window.location.href.slice(window.location.href.indexOf('?') + 1).split('&');
        for(var i = 0; i < hashes.length; i++)
        {
            hash = hashes[i].split('=');
            vars.push(hash[0]);
            vars[hash[0]] = hash[1];
        }
        return vars;
    },
    getUrlVar: function(name){
        return $.getUrlVars()[name];
    }
});