var faye = new Faye.Client('http://localhost:9292/faye');
var chatMarkerManager;


$(function(){
    chatMarkerManager = new MarkerManager({
        map: map
    });

    $('.chat-text-field').live('keydown', function(e){
        if(e.keyCode == 13 && !e.shiftKey){
            $(this).closest('form').submit();
            $(this).val('');            
            return false;            
        }
        return true;
    });

    $('.chat-header').live('click', function(e) {
        toggleChatRoom($(this).closest('.chat-holder')[0].id.split('_')[1]);
        e.stopPropagation();
        e.preventDefault();
    });
    $('.chat-close').live('click', function(e){
        closeChatRoom($(this).closest('.chat-holder')[0].id.split('_')[1]);
        e.preventDefault();
        e.stopPropagation();
    });

});

function createChatRoomMarker(lat, lng, chatRoomID) {
    var marker = chatMarkerManager.addMarker(lat, lng);
    marker.setIcon('/images/ss_chat_ico.png');
    marker.setShadow(null);
    marker.chatRoomId = chatRoomID;

    google.maps.event.addListener(marker, 'click', function() {
        $.each(marker.clusteredMarkers_, function(index, cMarker){
            openChatRoom(cMarker.chatRoomId);
        });
    });

    return marker;
}

function showChatMarkers(){
    chatMarkerManager.showAllMarkers();
}
function clearChatMarkers(){
    chatMarkerManager.deleteAllMarkers();
}

function openChatRoom(chatRoomID){

    if($('#chat_' + chatRoomID).length < 1) {
        var $chatWindow = $('#chat_room_template').clone();
        $chatWindow[0].id = 'chat_' + chatRoomID;
        $('#chat_bar').prepend($chatWindow);
        $.ajax({
            url: '/chat_rooms/' + chatRoomID,
            success: function(data){
                $chatWindow.html(data);
                setupTipsy();
                $chatWindow.removeClass('hidden');
                
                var subscribeObj = faye.subscribe('/chat_rooms/' + chatRoomID, function (data) {
                    eval(data);
                });
                $chatWindow.data('subscribe', subscribeObj);
                $chatWindow.find('.chat-content').scrollTop($chatWindow.find('.chat-content').attr('scrollHeight'));
            }
        })

        resizePageElements();
    }
}

function closeChatRoom(chatRoomID){
    var $chatWindow = $('#chat_' + chatRoomID);
    $chatWindow.closest('.chat-holder').data('subscribe').cancel();
    $chatWindow.closest('.chat-holder').remove();
    $.ajax({
        url: "/chat_rooms/" + chatRoomID + "/leave"
    });
}

function toggleChatRoom(chatRoomID){
    var $chatHolder = $('#chat_' + chatRoomID);
    $chatHolder.find('.chat-content').toggleClass('hidden');
    $chatHolder.find('.new_message').toggleClass('hidden');
    $chatHolder.find('.chat-minimize').toggleClass('hidden');
    $chatHolder.toggleClass('minimized');
    $chatHolder.find('.chat-content').scrollTop($chatHolder.find('.chat-content').attr('scrollHeight'));
}
