class Jobs::Facebook::PostEventAttendance
  @queue = :connections

  def self.perform(user_id, event_id)
    user = User.find user_id
    event = Event.find event_id

    if !event.event_types.empty? && et = event.event_types.detect {|et| et.image_path? }
      photo_url = et.image_path
    else
      photo_url = 'event_types/streetmeet' + (rand(8) + 1).to_s + '.png'
    end

    message = "I'm attending this StreetMeet on SocialStreet!"
    message = "I'm considering attending this StreetMeet on SocialStreet!" unless event.event_rsvps.maybe_attending.by_user(user).empty?

    options = {
      :picture => "http://www.socialstreet.com/#{photo_url}",
      :link => "http://www.socialstreet.com/events/#{event.id}",
      :name => event.title,
      :caption => "Brought to you by SocialStreet",
      :description => event.name.blank? ? "" : event.title_from_parameters(true),
      :message => message,
      :type => "link"
    }

    fb_user = user.facebook_user
    fb_user.feed!(options) if fb_user.permissions.include?(:publish_stream)
  end
end
