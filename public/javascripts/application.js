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

function refreshResults(caller) {
    if (refreshTimer) {
        clearInterval(refreshTimer);
        delete refreshTimer;
    }
    refreshTimer = setTimeout(function() {

        if(caller == "events")
            $.getScript('/events/load_events' + getSearchParams());
        else if(caller == "explore"){

            updateCommentBox();

            $('form.search-params').submit();
        }
    }, 250);
}

function expandHowItWorks() {
    $('.w2').removeClass('page-explore');
    $('.w2').removeClass('page-map');
 
    $('#how_it_works').closest('li').addClass('active');
    $('#top_explore_form').hide(1, function() {
        $('#header').addClass('open');
        $('.video-box').show();
        $('.w2').addClass('header-open');
    });
}

function retractHowItWorks(f) {
    
    $('.video-box').slideUp('slow', function() {
        $('#header').removeClass('open');
        $('#top_explore_form').show();
        $('#how_it_works').closest('li').removeClass('active');
        $('.w2').removeClass('header-open');
    });

    if(typeof f == "function")
        f();

}


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

    $('#how_it_works').click(function() { 
        if($('#header').hasClass('open'))
            retractHowItWorks();
        else
            expandHowItWorks();
        return false;
    });

    $('#how_btn_close').click(function() {
        retractHowItWorks();
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
            $("body").append("<div id='ss_modal_overlay'></div>");
            $("#ss_modal_overlay").addClass("ss_modal_overlayBG");
            $("#ss_modal_overlay").click(function(){
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
        //set facebook value in form if found
        var $modal_header = $(this).closest('.pop-up-modal');
        if($modal_header.find('.facebok-checkbox-in-header').css('display') != 'none'){
            var $FB_value = $($modal_header).find('.facebook-checkbox').val();

            if( $FB_value == 'on'){
                $($modal_header).find('#post-to-facebook').val(1);
            }
            else{
                $($modal_header).find('#post-to-facebook').val(0);
            }

        }


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
    $('.pop-up .content').css('min-height', $mainWindowHeight - $saveButtonHeight - 200);

    var $sideWindowHeight = $mainWindowHeight - 39; //54+31=85 for sidebar padding, -19 for sidebar margin, -27 for modal padding == 39
    $('.day-detail').css('height', $sideWindowHeight);
    $('.day-detail').css('min-height', $sideWindowHeight - 200);
    
    var $sideListHeight = $sideWindowHeight - 83; //76 for header, 13+13=26 for header padding, -19 for sidebar margin == 83
    $('.pop-up .friends-list-holder').css('height', $sideListHeight);//This one is annoying, but seems needed
    $('.pop-up .friends-list-holder').css('min-height', $sideListHeight - 200);//This one is annoying, but seems needed
}

function popup_modal_ajax(modal_divID, modal_title, requestURL, requestParams){
    //Set the modal title
    $(modal_divID).find('#modal-title').text(modal_title);

    // Scroll to the top of the document
    window.scrollTo(0,0);

    //Disable scrolling for the body
    $("body").css("overflow", "hidden");

    //Display the modal
    $(modal_divID).show();

    //Display overlay
    if(document.getElementById("ss_modal_overlay") === null){
        $("body").append("<div id='ss_modal_overlay'></div>");
        $("#ss_modal_overlay").addClass("ss_modal_overlayBG");
        $("#ss_modal_overlay").click(function(){
            removeModal($(modal_divID));
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
        $('#ss_modal_overlay').trigger("unload").unbind().remove();
        $("body").css("overflow", "auto");
    });

    //Hack to make save this search modal work
    element.removeClass('follow-modal');

    element.find('.ajax-content').empty();
    element.find('#modal-title').empty();
    element.find('.ajax-main-content').empty();
    element.find('.ajax-sidebar-content').empty();

    element.find('.facebok-checkbox-in-header').hide();
    element.find('.save-button-at-bottom').hide();
}

$(function() {
    if(-1 == document.cookie.indexOf('current_location_latitude') || -1 == document.cookie.indexOf('current_location_longitude'))
    {
        if(navigator.geolocation){
            navigator.geolocation.getCurrentPosition(onGeoLocationSuccess, function(){}, {maximumAge: 600000});
        }
    }
})

function onGeoLocationSuccess(e){
    $.getScript('/locations/update_users_location?latitude=' + e.coords.latitude + '&longitude=' + e.coords.longitude, function(data, textStatus){
        //TODO - should update the explore page results somehow....
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