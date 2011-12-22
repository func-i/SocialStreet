var faye = new Faye.Client('http://10.0.1.9:9292/faye');

$(function(){
   $('.chat-text-field').live('keydown', function(e){
       if(e.keyCode == 13 && !e.shiftKey){
           $(this).closest('form').submit();
           $(this).val('');
           return false;
       }
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
    var $chatWindow = $('#chat_room_template').clone();
    $('#bottom_pane').append($chatWindow);
    $.ajax({
        url: '/chat_rooms/' + chatRoomID,
        success: function(data){
            $chatWindow.html(data);
            $chatWindow.show();
            faye.subscribe('/chat_rooms/' + chatRoomID, function (data) {
                eval(data);
            });
        }
    })

    resizePageElements();
}
