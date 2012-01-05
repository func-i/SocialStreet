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
        //$('#chat_bar').data('jsp').getContentPane().prepend($chatWindow);
        //$('#chat_bar').data('jsp').reinitialize();
        $('#content').prepend($chatWindow);
        
        $.ajax({
            url: '/chat_rooms/' + chatRoomID,
            success: function(data){
                $chatWindow.html(data);
                setupTipsy();
                $chatWindow.removeClass('hidden');
                $chatWindow.draggable({
                    containment: '#content'
                });
                $chatWindow.css('display', 'inline-block');
                if($('.chat-room').length > 3) {
                    $('#chat_bar').width(700);
                    $('#chat_rooms_holder').width($('.chat-room').length * 250);
                }
                else
                    $('#chat_bar').width('');

                
                var subscribeObj = faye.subscribe('/chat_rooms/' + chatRoomID, function (data) {
                    eval(data);
                });
                $chatWindow.data('subscribe', subscribeObj);
                $chatWindow.find('.chat-content').scrollTop($chatWindow.find('.chat-content').attr('scrollHeight'));

                $.ajax({
                    url: '/chat_rooms/' + chatRoomID + '/join'
                })
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

//$('#chat_rooms_holder').width($('#chat_rooms_holder').width() - 238);
}

function toggleChatRoom(chatRoomID){
    var $chatHolder = $('#chat_' + chatRoomID);

    if($chatHolder.draggable("option", "disabled")) {
        // chat is not draggable, therefore it is minimized.
        $chatHolder.appendTo("#content");
        $chatHolder.draggable("enable");
        $chatHolder.css('top', $chatHolder.data('top'));
        $chatHolder.css('left', $chatHolder.data('left'));
    }
    else {
        $chatHolder.appendTo('#chat_bar');
        $chatHolder.draggable("disable");
        $chatHolder.data("top", $chatHolder.css('top'));
        $chatHolder.data("left", $chatHolder.css('left'));
        $chatHolder.css('top', '');
        $chatHolder.css('left', '');
    }

    $chatHolder.find('.chat-content').toggleClass('hidden');
    $chatHolder.find('.chat-user-list-container').toggleClass('hidden');
    $chatHolder.find('.new_message').toggleClass('hidden');
    $chatHolder.find('.chat-minimize').toggleClass('hidden');
    $chatHolder.toggleClass('minimized');
    $chatHolder.find('.chat-content').scrollTop($chatHolder.find('.chat-content').attr('scrollHeight'));
}
