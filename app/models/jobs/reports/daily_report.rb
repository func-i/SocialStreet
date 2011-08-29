class Jobs::DailyReport

  def self.perform(last_report_datetime)
    #
    #USERS
    #
    @num_all_users = User.count
    
    @num_all_signed_up_users = User.has_signed_in.count
    @all_signed_up_users_locations #TODO
    @all_signed_up_users_activity_histogram #TODO - how active the users are broken down by number of action buckets

    @num_new_users #TODO
    @num_new_signed_up_users #TODO
    @num_new_signed_up_users_male #TODO
    @num_new_signed_up_users_female #TODO
    @num_new_signed_up_users_received_facebook_post #TODO - How many of these users were referred through facebook
    @new_signed_up_users_locations #TODO
    @new_signed_up_users_activity_histogram #TODO - how active the users are broken down by number of action buckets

    #
    #EVENTS
    #
    @num_new_events = Event.where("events.created_at >= ?", last_report_datetime).count
    @new_events_type_histogram #TODO - new events broken down by event type
    @new_events_locations

    @num_occurred_events = Event.includes({:searchable => [:searchable_date_ranges] }).where("searchable_date_ranges.starts_at > ?", last_report_datetime).count
    @occurred_events_type_histogram #TODO - occurred events broken down by event type
    @occurred_events_num_attendees_histogram #TODO - occurred events broken down by number of attendees
    @occured_events_locations

    #
    #MESSAGES
    #
    @num_new_search_messages_created #TODO
    @num_new_search_messages_replied #TODO
    @new_search_messages_created_activity_histogram
    @new_search_messages_locations

    @num_new_profile_messages_created #TODO
    @num_new_profile_messages_replied #TODO

    @num_new_event_messages_created #TODO
    @num_new_event_messages_replied #TODO
  end
end

