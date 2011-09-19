class Jobs::Facebook::PostEventInvitation
  @queue = :connections

  def self.perform(from_user_id, to_user_id, event_id)
    # => Load the fb_user and post to their feed using fb_graph
    from_user = User.find(from_user_id)
    to_user = User.find(to_user_id)
    event = Event.find event_id

    if !event.event_types.empty? && et = event.event_types.detect {|et| et.image_path? }
      photo_url = et.image_path
    else
      photo_url = 'event_types/streetmeet' + (rand(8) + 1).to_s + '.png'
    end

    options = {
      :picture => "http://www.socialstreet.com/#{photo_url}",
      :link => "http://www.socialstreet.com/events/#{event.id}",
      :name => event.title,
      :caption => "Brought to you by SocialStreet",
      :description => event.name.blank? ? "" : event.title_from_parameters(true),
      :message => "I want to invite you to join this StreetMeet on SocialStreet!",
      :type => "link"
    }

    fb_user = from_user.facebook_user
    fb_friend = fb_user.friends.select{|f| f.identifier.eql?(to_user.fb_uid)}.first if fb_user
    fb_friend.feed!(options.merge(:access_token => from_user.fb_auth_token)) if fb_friend && fb_user.permissions.include?(:publish_stream)
  end
end
