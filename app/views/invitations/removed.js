$('.search-bar form').submit(function() {
    var $input = $(this).find('input.search-field');
    var email = $input.val();
    // make sure it's a valid email that was not already included in the list
    if (isEmail(email) && $selectedList.find('input[value="'+email+'"]').size() == 0) {
        $input.val('');
        var u = $('<div class="user email-only">' +
            '<div class="avatar"><img src="/images/avatar.gif" alt="Avatar"></img></div>' +
            '<span class="name">'+email+'</span>' +
            '<a href="#" class="remove-btn">[X]</a>' +
            '<div class="clear"></div>' +
            '<input type="hidden" name="emails[]" value="'+email+'"/>' +
            '</div>');
        $selectedList.prepend(u);
    }
    return false;
});

$('.search-bar .search-field').keyup(function(e) {
    if (timeout) {
        clearTimeout(timeout);
        delete timeout;
    }
    var query = this.value;
    if (lastQuery != query) {
        timeout = setTimeout(function() {
            lastQuery = query;
            $.getJSON(searchURL, {
                query: query
            }, function(data, textStatus, jqHXR) {
                $userList.empty();
                $.each(data, function(i, user) {
                    var u = $('<div class="user" data-user-id="'+user.id+'">' +
                        '<div class="avatar"><img src="'+ user.avatar_url+'" alt="Avatar"></img></div>' +
                        '<span class="name">'+user.name+'</span>' +
                        '<a href="#" class="remove-btn">[X]</a>' +
                        '<div class="clear"></div>' +
                        '<input type="hidden" name="user_ids[]" value="'+user.id+'"/>' +
                        '</div>');
                    if ($selectedList.find('.user[data-user-id="'+user.id+'"]')[0]) {
                        u.addClass('selected');
                    }
                    $userList.append(u);
                });
            });
        }, 280);
    }
});