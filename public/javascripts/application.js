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

        //Set the modal title
        $(divId).find('#modal-title').text($(this).attr('modal-title'))

        //Display the modal
        $(divId).show();

        //Display overlay
        if(document.getElementById("TB_overlay") === null){
            $("body").append("<div id='TB_overlay'></div>");
            $("#TB_overlay").addClass("TB_overlayBG");
            $("#TB_overlay").click(function(){
                removeModal($(divId))
            });
        }

        //Send request to load data into the modal
        //
        //
        var requestURL = $(this).attr('request-url').valueOf();

        var requestParams = $(this).attr('request-params');
        
        if(requestParams != null)
            requestURL += "?=" + requestParams.valueOf();
        
        $.getScript(requestURL);

        //Call post load hook if exists
        var callback = $(this).attr('request-callback')
        if(callback != null){
            eval(callback.valueOf()+'()')
        }


    //        
    //        if(requestParams == null)
    //            $(divId).find('.ajax_add_here').load(requestURL);
    //        else
    //            $(divId).find('.ajax_add_here').load(requestURL, requestParams.valueOf());
    //
    //        //Call post load hook if exists
    //        var callback = $(this).attr('request-callback')
    //        if(callback != null){
    //            eval(callback.valueOf()+'()')
    //        }
    });



    $('.btn-close').live('click', function() {
        removeModal(this);
    });

    $('.link-close').live('click', function() {
        removeModal(this);
    });
})

function removeModal(element) {
    var ele;

    if($(element).hasClass('.pop-up'))
        ele = $(element);
    else if($(element).hasClass('.pop-up-modal'))
        ele = $(element);
    else
        ele = $(element).closest('.pop-up')

    if(ele==null)
        ele = $(element).closest('.pop-up-modal');

    $(ele).fadeOut("fast", function() {
        $('#TB_overlay').trigger("unload").unbind().remove();
    });
    $('#empty_modal_1').removeClass('pop-up').addClass('pop-up-modal');

    ele.html('#empty_modal_1').html('<div class="pop-up1 pop-up2"><div class="heading"><strong><span id="modal-title">#</span></strong><a href="#" class="btn-close">close</a></div><div class="content content1"><div class="pop-up1-content ajax-content"></div></div></div>');

   

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