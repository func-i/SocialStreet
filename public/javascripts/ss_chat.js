var faye = new Faye.Client('http://localhost:9292/faye');

$(function(){
    $('.chat-text-field').live('keydown', function(e){
        if(e.keyCode == 13 && !e.shiftKey){
            $(this).closest('form').submit();
            $(this).val('');
            return false;
        }
    });

    $('.chat-header').live('click', function(e) {
        toggleChatRoom($(this).closest('.chat-room')[0].id.split('_')[1]);
        e.preventDefault();
        e.stopPropagation();
    });
    $('.chat-close').live('click', function(e){
        closeChatRoom($(this).closest('.chat-room')[0].id.split('_')[1]);
        e.preventDefault();
        e.stopPropagation();
    });

});

function createChatRoomMarker(lat, lng, chatRoomID) {
    var marker = new google.maps.Marker({
        map: map,
        icon: '/images/ss_chat_ico.png',
        position: new google.maps.LatLng(lat, lng)
    });
    marker.chatRoomId = chatRoomID;

    google.maps.event.addListener(marker, 'click', function() {
        openChatRoom(marker.chatRoomId);
    });

    return marker;
}

function openChatRoom(chatRoomID){

    if($('#chat_' + chatRoomID).length < 1) {
        var $chatWindow = $('#chat_room_template').clone();
        $chatWindow.removeAttr('id');
        $('#bottom_pane').append($chatWindow);
        $.ajax({
            url: '/chat_rooms/' + chatRoomID,
            success: function(data){
                $chatWindow.html(data);
                setupTipsy();
                $chatWindow.show();
                
                var subscribeObj = faye.subscribe('/chat_rooms/' + chatRoomID, function (data) {
                    eval(data);
                });
                $chatWindow.data('subscribe', subscribeObj);
            }
        })

        resizePageElements();
    }
}

function closeChatRoom(chatRoomID){
    var $chatWindow = $('#chat_' + chatRoomID);
    $chatWindow.data('subscribe').cancel();
    $chatWindow.closest('.chat-holder').remove();
}

function toggleChatRoom(chatRoomID){
    var $chatHolder = $('#chat_' + chatRoomID).closest('.chat-holder');
    $chatHolder.find('.chat-content').toggle();
    $chatHolder.find('.new_message').toggle();
    $chatHolder.find('.chat-minimize').toggle();
    $chatHolder.toggleClass('minimized');
}