if(!Array.indexOf) {
    Array.prototype.indexOf = function(obj){
        for(var i=0; i<this.length; i++){
            if(this[i]==obj){
                return i;
            }
        }
        return -1;
    }
}


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

var refreshTimer = null;
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
            
    $('html').css('overflow', 'auto');
 
    $('#how_it_works').closest('li').addClass('active');
    $('#top_explore_form').hide(1, function() {
        $('#how_link_li').hide();
        $('#sign_in_li').hide();
        $('#sign_in_ribbon_li').show();
        $('#header').addClass('open');
        $('.video-box').show(200);
        $('.w2').addClass('header-open');
    });
}

function retractHowItWorks(f) {
    if($('#header').hasClass('open')) {
        $('#sign_in_ribbon_li').hide();
        $('.video-box').slideUp('slow', function() {
            $('#how_link_li').show();
            $('#sign_in_li').show();            
            $('#header').removeClass('open');
            $('#top_explore_form').show();
            $('#how_it_works').closest('li').removeClass('active');
            $('.w2').removeClass('header-open');
            $(window).scrollTop(0);

            if(typeof checkMapPageSize == 'function')
                checkMapPageSize();

            var IE7 = (navigator.appVersion.indexOf("MSIE 7.")==-1) ? false : true;
            if(IE7) {
        // Hack fix for position in IE7
        //$('.main-top').css('height', '77px');
        //$('.main-top .holder').css('background', '');
        }

        });

        if(typeof f == "function")
            f();
    }
}


$(function() {

    window.onorientationchange = function() {
        refresh_iScrollers();
    }

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
        // Scroll to the top of the document
        window.scrollTo(0,0);

        var divId = '#' + $(this).attr('popup-div-id');
        $(divId).show();

        // Display overlay
        if(document.getElementById("ss_modal_overlay") === null){
            $("body").append("<div id='ss_modal_overlay'></div>");
            $("#ss_modal_overlay").addClass("ss_modal_overlayBG");
            $("#ss_modal_overlay").click(function(){
                removeModal($(divId));
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

        resizeModals();

        //Disable scrolling for the body
        $("html").css("overflow", "hidden");

        setTimeout(function () {
            attach_iScroll(divId);
        },0);

        return false;
    });

    $('.popup-modal-ajax').live('click', function() {
        var divId = '#' + $(this).attr('popup-div-id');
        var title = $(this).attr('modal-title')
        var requestURL = $(this).attr('request-url');
        var requestParams = $(this).attr('request-params');

        popup_modal_ajax(divId, title, requestURL, requestParams);
    });

    $('.save-modal-button').click('click', function() {
        $(this).parent('.row-btn').parent().parent().find('.modal-submit-form').submit();
        $(this).attr('disabled', true);
    });

    $('.modal-submit-form').live('ajax:complete', function(event){
        $('.save-modal-button').removeAttr('disabled');
    });

    $('.btn-close').live('click', function() {
        removeModal($(this).closest('.pop-up-modal'));
    });

    $('.link-close').live('click', function() {
        removeModal($(this).closest('.pop-up-modal'));
    });

    $('.dismiss-onscreenkeyboard').live('keydown', function(e) {
        if (e.keyCode == 13) {
            e.stopPropagation();
            $(this).blur();
        }
        
    });
})

function resizeModals(){
    var $mainWindowHeight = ($(window).height() > 450 ? $(window).height() : 450);
    $mainWindowHeight = ($mainWindowHeight < 850 ? $mainWindowHeight : 850);

    var $saveButtonHeight = 0;
    $('.save-button-at-bottom').each(function(index, elem){
        if($(elem).css('display') != "none") {
            $saveButtonHeight = 54; //Save button height
        }
    });

    $mainWindowHeight = $mainWindowHeight - 99; //15 for position, 15+12=27 for modal padding, 27+11=38 for modal header, 9 for bottom of screen seperation == 99
    
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

    //Display the modal
    $(modal_divID).show();

    //attach_iScroll for touch displays
    setTimeout(function () {
        attach_iScroll(modal_divID);
    },0);

    // Display overlay
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
        removeTabIndex(modal_divID);

        refresh_iScrollers();
    });

    //Disable scrolling for the body
    $("html").css("overflow", "hidden");

}

var my_iScrollArr = [];
function get_iScroller(scrollerID){

    for(var i = 0; i < my_iScrollArr.length; i++){
        if(my_iScrollArr[i][0] == scrollerID){
            return my_iScrollArr[i][1];
        }
    }
    return null;
}

function refresh_iScrollers(){
    setTimeout(function () {
        for(var i = 0; i < my_iScrollArr.length; i++){
            my_iScrollArr[i][1].refresh();
        }
    }, 0);
}

function attach_iScroll(divID){

    var myDiv = $(divID);

    var iScroll_ids = myDiv.data('iscroll-ids');
    var myIds;
    if(iScroll_ids){
        myIds = iScroll_ids.split(',');
    }
    else{
        myIds = [divID];
    }

    for(var i = 0; i < myIds.length; i++){
        my_iScrollArr.push([myIds[i], new iScroll(myIds[i], {
            onScrollMove: pageless_iscroll_callback
        })]);
    }
}

function pageless_iscroll_callback(that, e){
    var target = $(that.currentTarget);
    target.trigger('scroll.ss_pageless');
}

function detach_iScroll(divID){

    var myDiv = $(divID);

    var iScroll_ids = myDiv.data('iscroll-ids');
    var myIds;
    if(iScroll_ids){
        myIds = iScroll_ids.split(',');
    }
    else{
        myIds = divID;
    }

    var new_arr = []
    for(var i = 0; i < myIds.length; i++){
        for(var j = 0; j < my_iScrollArr.length; j++){
            if(my_iScrollArr[j][0] != myIds[i]){
                new_arr.push(my_iScrollArr[j])
            }
            else{
                my_iScrollArr[j][1].destroy();
            }
        }
    }
    my_iScrollArr = [];
    delete my_iScrollArr;
    my_iScrollArr = new_arr;
}

function removeTabIndex(modalDivID){
    // an array of selectors to loop through to disable elements inside the body
    $.each(['body a', 'body img', 'body input', 'body select'], function(index, selector) {
        $(selector).attr('tabIndex', -1)
    });

    // enable the same elements inside the modal
    $.each([modalDivID + ' a', modalDivID + ' img', modalDivID + ' input', modalDivID + ' select'], function(index, selector) {
        $(selector).attr('tabIndex', 1)
    });
}

function addTabIndex() {
    // re-enable all the body elements
    $.each(['body a', 'body img', 'body input', 'body select'], function(index, selector) {
        $(selector).attr('tabIndex', 1)
    });
}

function removeModal(element) {
    $(element).fadeOut("fast", function() {
        $('#ss_modal_overlay').trigger("unload").unbind().remove();
        $("html").css("overflow", "auto");
        
    });

    //Hack to make save this search modal work
    element.removeClass('follow-modal');

    element.find('.ajax-content').empty();
    element.find('.ajax-content').html('<img alt="Load" src="/images/load.gif?1305574304" style="margin-left:auto;margin-right: auto;display: block;">');
    element.find('#modal-title').empty();
    element.find('.ajax-main-content').empty();
    element.find('.ajax-main-content').html('<img alt="Load" src="/images/load.gif?1305574304" style="margin-left:auto;margin-right: auto;display: block;">');
    element.find('.ajax-sidebar-content').empty();

    element.find('.facebook-checkbox-in-header').hide();
    element.find('.facebook-checkbox-in-header').find('.facebook-checkbox').attr('checked', true);
    element.find('.save-button-at-bottom').hide();
    //element.find('.save-modal-button').disabled = false;

    addTabIndex();

    setTimeout(function () {
        detach_iScroll('#' + element.attr('id'));
    },0);

}

$(function() {
    if(-1 == document.cookie.indexOf('current_location_latitude') || -1 == document.cookie.indexOf('current_location_longitude'))
    {
        if(navigator.geolocation){
            navigator.geolocation.getCurrentPosition(function(e){
                updateUserLocation(e.coords.latitude, e.coords.longitude, true)
            }, function(e){
                },
                {
                    maximumAge: 600000
                });
        }
    }
})

function updateUserLocation(latitude, longitude, updateDB){
    $.getScript('/locations/update_users_location?latitude=' + latitude + '&longitude=' + longitude + '&=update_db=' + updateDB, function(data, textStatus){});
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