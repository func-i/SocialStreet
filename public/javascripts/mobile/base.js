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

$(function() {

    window.onorientationchange = function() {
        refresh_iScrollers();
    }

    $('.dismiss-onscreenkeyboard').live('keydown', function(e) {
        if (e.keyCode == 13) {
            e.stopPropagation();
            $(this).blur();
        }

    });
})

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
    $.getScript('/locations/update_user_location?latitude=' + latitude + '&longitude=' + longitude + '&=update_db=' + updateDB, function(data, textStatus){});
}