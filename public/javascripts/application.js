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


    //Resize modal windows to match screen resolution
    $(window).resize(function(){
        resizeModals();
    });
    resizeModals();

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

    $('.save-modal-button').click('click', function(){
       $(this).parent('.save-button-at-bottom').parent().parent().find('.modal-submit-form').submit();
    });

    $('.btn-close').live('click', function() {
        removeModal($(this).closest('.pop-up-modal'));
    });

    $('.link-close').live('click', function() {
        removeModal($(this).closest('.pop-up-modal'));
    });
})

function resizeModals(){
    var $mainWindowHeight = ($(window).height() > 450 ? $(window).height() : 450);
    $mainWindowHeight = ($mainWindowHeight < 750 ? $mainWindowHeight : 750);

    var $saveButtonHeight = 0;
    $('.save-button-at-bottom').each(function(index, elem){
        if($(elem).css('display') != "none"){
            $saveButtonHeight = 77; //Save button height
        }
    });

    $mainWindowHeight = $mainWindowHeight - 150; //76 for position, 15+12=27 for modal padding, 27+11=38 for modal header, 9 for bottom of screen seperation == 150
    $('.pop-up .content').css('max-height', $mainWindowHeight - $saveButtonHeight);
    $('.pop-up .content').css('min-height', $mainWindowHeight - $saveButtonHeight);

    var $sideWindowHeight = $mainWindowHeight - 39; //54+31=85 for sidebar padding, -19 for sidebar margin, -27 for modal padding == 39
    $('.day-detail').css('height', $sideWindowHeight);
    $('.day-detail').css('min-height', $sideWindowHeight);
    
    var $sideListHeight = $sideWindowHeight - 83; //76 for header, 13+13=26 for header padding, -19 for sidebar margin == 83
    $('.pop-up .friends-list-holder').css('height', $sideListHeight);//This one is annoying, but seems needed
    $('.pop-up .friends-list-holder').css('min-height', $sideListHeight);//This one is annoying, but seems needed
}

function popup_modal_ajax(modal_divID, modal_title, requestURL, requestParams){
    //Set the modal title
    $(modal_divID).find('#modal-title').text(modal_title)

    //Display the modal
    $(modal_divID).show();

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

    $.getScript(request, function(data, textStatus){
        resizeModals();
    });
}

function removeModal(element) {
    $(element).fadeOut("fast", function() {
        $('#TB_overlay').trigger("unload").unbind().remove();
    });

    element.find('.ajax-content').empty();
    element.find('.ajax-main-content').empty();
    element.find('.ajax-sidebar-content').empty();

    element.find('.facebok-checkbox-in-header').hide();
    element.find('.save-button-at-bottom').hide();
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