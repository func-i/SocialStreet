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

    $('.chat-placeholder').live('click', function(e) {
        toggleChatRoom($(this).attr('id').split('_')[3]);
        e.stopPropagation();
        e.preventDefault();
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

    $('.min-chat-close').live('click', function(e){
        closeChatRoom($(this).closest('.chat-placeholder')[0].id.split("_")[3]);
        e.preventDefault();
        e.stopPropagation();
    });

    $('#chat_scroll_right').live('click', function(e){
        var $scrollContainer =  $('#chat_rooms_scroll_container');
        $scrollContainer.scrollLeft($scrollContainer.scrollLeft() + 238);

        toggleScrollButtons();
        repositionChatWindows();
    });

    $('#chat_scroll_left').live('click', function(e){
        var $scrollContainer =  $('#chat_rooms_scroll_container');
        var scrollLeftPosition = $scrollContainer.scrollLeft();
        $scrollContainer.scrollLeft(scrollLeftPosition - 238);

        toggleScrollButtons();
        repositionChatWindows();

    });

});

function toggleScrollButtons() {
    var $scrollContainer =  $('#chat_rooms_scroll_container');      
    var scrollLeftPosition = $scrollContainer.scrollLeft();
    var numChats = $('.chat-holder:not(#chat_room_template)').length;
    var numHiddenLeft = parseInt(scrollLeftPosition / 238);
    var numHiddenRight = numChats - numHiddenLeft - 3;

    numHiddenLeft > 0 ? $('#chat_scroll_left').removeClass('invisible') : $('#chat_scroll_left').addClass('invisible');
    numHiddenRight > 0 ? $('#chat_scroll_right').removeClass('invisible') : $('#chat_scroll_right').addClass('invisible');
}

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

        $('#content').prepend($chatWindow);
        
        $.ajax({
            url: '/chat_rooms/' + chatRoomID,
            success: function(data){
                $chatWindow.html(data);
                setupTipsy();

                var $minChatWindow = $('#chat_room_placeholder_' + chatRoomID);

                $minChatWindow.prependTo('#chat_rooms_holder');
                $chatWindow.css('position', 'absolute');

                repositionChatWindows();

                $chatWindow.css('zIndex', 1000000);
                $chatWindow.removeClass('hidden');
                
                var subscribeObj = faye.subscribe('/chat_rooms/' + chatRoomID, function (data) {
                    eval(data);
                });
                $chatWindow.data('subscribe', subscribeObj);
                $chatWindow.find('.chat-content').scrollTop($chatWindow.find('.chat-content').attr('scrollHeight'));

                $.ajax({
                    url: '/chat_rooms/' + chatRoomID + '/join'
                })

                resizeChatHolder();
                toggleScrollButtons();
            }
        })

        resizePageElements();
    }
}

function closeChatRoom(chatRoomID){
    var $chatWindow = $('#chat_' + chatRoomID);
    $chatWindow.closest('.chat-holder').data('subscribe').cancel();
    $chatWindow.closest('.chat-holder').remove();
    $('#chat_room_placeholder_' + chatRoomID).remove();
    $.ajax({
        url: "/chat_rooms/" + chatRoomID + "/leave"
    });

    resizeChatHolder();
    repositionChatWindows();
    toggleScrollButtons();

//$('#chat_rooms_holder').width($('#chat_rooms_holder').width() - 238);
}

function resizeChatHolder() {
    if($('.chat-holder:not(#chat_room_template)').length >= 3) {
        $('#chat_scroll_left, #chat_scroll_right').removeClass('hidden');
        $('#chat_rooms_holder').width($('.chat-holder:not(#chat_room_template)').length * 243);
        $('#chat_rooms_scroll_container').scrollLeft($('#chat_rooms_scroll_container').width());

        repositionChatWindows();
    }
    else {
        $('#chat_bar').width('');
    //$('#chat_scroll_left, #chat_scroll_right').addClass('hidden');
    }
}

function minimizeChatRoom(chatRoomID) {
    var $chatHolder = $('#chat_' + chatRoomID);
    var $minChatHolder = $('#chat_room_placeholder_' + chatRoomID);
    
    $minChatHolder.removeClass('invisible');
    $chatHolder.addClass('hidden');
    $chatHolder.height(0);
    $chatHolder.find('.chat-room, .chat-content, .chat-user-list-container, .new_message, .chat-minimize, .chat-header').addClass('hidden');
}

function maximizeChatRoom(chatRoomID) {
    var $chatHolder = $('#chat_' + chatRoomID);
    var $minChatHolder = $('#chat_room_placeholder_' + chatRoomID);

    if($minChatHolder.position().left > 0 && $minChatHolder.position().left < 800) {
        $minChatHolder.addClass('invisible');
        $chatHolder.css('height', '');
        $chatHolder.removeClass('hidden');
        $chatHolder.find('.chat-room, .chat-content, .chat-user-list-container, .new_message, .chat-minimize, .chat-header').removeClass('hidden');
        $chatHolder.find('.chat-content').scrollTop($chatHolder.find('.chat-content').attr('scrollHeight'));
    }

}

function toggleChatRoom(chatRoomID){
    
    var $minChatHolder = $('#chat_room_placeholder_' + chatRoomID);

    if($minChatHolder.hasClass('invisible')) {
        // chat placeholder is invisible, chat window is maximized, need to minimize
        minimizeChatRoom(chatRoomID);
    }
    else {
        // chat placeholder is not invisible, so we need to maximize
        maximizeChatRoom(chatRoomID);
    }
}

function repositionChatWindows() {
    $('.chat-holder:not(#chat_room_template)').each(function() {
        var thisChatRoomID = $(this).attr('id').split('_')[1];
        var $placeHolder = $('#chat_room_placeholder_' + thisChatRoomID);
        if($placeHolder.length > 0) {
            $(this).css('left', $placeHolder.offset().left);
            
            if($placeHolder.position().left < 0 || ($placeHolder.position().left) > 700)
                minimizeChatRoom(thisChatRoomID);
        }


    });
}
