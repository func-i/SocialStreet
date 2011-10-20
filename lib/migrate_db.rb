class MigrateDb

  def switch_to_legacy
    ActiveRecord::Base.establish_connection :legacy
  end

  def switch_to_current
    ActiveRecord::Base.establish_connection "#{RAILS_ENV}"
  end
  
  def migrate
    migrate_users()
    migrate_connections()
    migrate_authentications()

    migrate_event_types()

    migrate_locations()

    migrate_events()
    migrate_rsvps()
    migrate_keywords()
    migrate_comments()
  end

  #TODO - This doesnt work for non-top level comments
  def migrate_comments()
    comment_inserts = []

    switch_to_legacy

    comments = ActiveRecord::Base.connection.query("SELECT comments.*, events.id AS event_id FROM comments LEFT OUTER JOIN events ON comments.searchable_id = events.searchable_id WHERE events.id IS NOT NULL;")
    comments.each do |comment|
      comment_inserts.push(
        "(
      #{comment.user_id},
      #{comment.body},
      #{comment.event_id},
      #{comment.created_at},
      #{comment.updated_at}
      )"
      )
    end

    comments = ActiveRecord::Base.connection.query("SELECT comments.*, events.id AS event_id FROM actions LEFT OUTER JOIN actions AS ref_actions ON actions.id = ref_actions.action_id INNER JOIN comments ON comments.id = ref_actions.reference_id INNER JOIN events ON actions.event_id = events.id WHERE actions.action_type = 'Event Comment' AND ref_actions.action_type = 'Action Comment';")
    comments.each do |comment|
      comment_inserts.push(
        "(
      #{comment.user_id},
      #{comment.body},
      #{comment.event_id},
      #{comment.created_at},
      #{comment.updated_at}
      )"
      )
    end

    switch_to_current

    sql = "INSERT INTO comments (
user_id,
body,
event_id,
created_at,
updated_at
) VALUES #{comment_inserts.join(", ")}"

    ActiveRecord::Base.connection.insert(sql)
  end

  def migrate_keyword()
    keyword_inserts = []

    switch_to_legacy

    keywords = ActiveRecord::Base.connection.query("SELECT searchable_event_types.*, events.id AS event_id FROM searchable_event_types INNER JOIN events ON searchable_event_types.searchable_id = events.searchable_id")
    keywords.each do |keyword|
      keyword_inserts.push(
        "(
      #{keyword.name},
      #{keyword.event_type_id},
      #{keyword.event_id}
      #{keyword.created_at},
      #{keyword.updated_at}
      )"
      )
    end

    switch_to_current

    sql = "INSERT INTO event_keywords (
name,
event_type_id,
event_id,
created_at,
updated_at
) VALUES #{keyword_inserts.join(", ")}"

    ActiveRecord::Base.connection.insert(sql)
  end

  def migrate_rsvps()
    rsvp_inserts = []

    switch_to_legacy

    rsvps = ÅctiveRecord::Base.connection.query("SELECT * FROM rsvps")
    rsvps.each do |rsvp|
      rsvp_inserts.push(
        "(
      #{rsvp.user_id},
      #{rsvp.event_id},
      #{rsvp.posted_to_facebook},
      #{rsvp.status},
      #{rsvp.administrator},
      #{rsvp.created_at},
      #{rsvp.updated_at},
      '',
      ''
      )"
      )
    end

    invitations = ActiveRecord::Base.connection.query("SELECT invitations.*, rsvp.status FROM invitations LEFT OUTER JOIN rsvps ON invitations.to_user_id = rsvps.user_id AND invitations.event_id = rsvps.event_id WHERE rsvps.id IS NULL;")
    invitations.each do |invite|
      rsvp_inserts.push(
        "(
        #{invite.to_user_id},
        #{invite.event_id},
        false,
        'Invited',
        false,
        #{invite.created_at},
        #{invite.updated_at},
        #{invite.email},
        #{invite.user_id}
      )"
      )
    end

    switch_to_current

    sql = "INSERT INTO event_rsvps (
user_id,
event_id,
posted_to_facebook,
status,
organizer,
created_at,
updated_at,
email,
invitor_id
) VALUES #{rsvp_inserts.join(", ")}"

    ActiveRecord::Base.connection.insert(sql)
  end

  def migrate_events()
    event_inserts = []

    switch_to_legacy

    events = ActiveRecord::Base.connection.query("SELECT events.*, searchable_date_ranges.starts_at, searchable_date_ranges.ends_at FROM events LEFT OUTER JOIN searchable_date_ranges ON events.searchable_id = searchable_date_ranges.searchable_id;")
    events.each do |event|
      event_inserts.push(
        "(
      #{event.event_id},
      #{event.name},
      #{event.description},
      #{event.user_id},
      #{event.canceled},
      #{event.promoted},
      #{event.location_id},
      #{event.starts_at},
      #{event.ends_at},
      #{event.created_at},
      #{event.updated_at}
      )"
      )
    end

    switch_to_current

    sql = "INSERT INTO events (
id,
name,
description,
user_id,
canceled,
promoted,
location_id,
start_date,
end_date,
created_at,
updated_at
) VALUES #{event_inserts.join(", ")}"

    ActiveRecord::Base.connection.insert(sql)
  end

  def migrate_locations()
    location_inserts = []

    switch_to_legacy

    locations = ActiveRecord::Base.connection.query("SELECT * FROM locations")
    locations.each do |loc|
      location_inserts.push(
        "(
      #{loc.id},
      #{loc.latitude},
      #{loc.longitude},
      #{loc.street},
      #{loc.city},
      #{loc.state},
      #{loc.country},
      #{loc.postal},
      #{loc.neighborhood},
      #{loc.route},
      #{loc.text},
      #{loc.geocoded_address},
      #{loc.created_at},
      #{loc.updated_at}
      )"
      )
    end

    switch_to_current

    sql = "INSERT INTO locations (
id,
latitude,
longitude,
street,
city,
state,
country,
postal,
neighborhood,
route,
text,
geocoded_address,
created_at,
updated_at,
) VALUES #{location_inserts.join(", ")}"

    ActiveRecord::Base.connection.insert(sql)
  end

  def migrate_event_types()
    et_inserts = []

    switch_to_legacy

    event_types = ActiveRecord::Base.connection.query("SELECT * FROM event_types")
    event_types.each do |et|
      et_inserts.push(
        "(
      #{et.id},
      #{et.name},
      #{et.image_path},
      #{et.synonym_id},
      #{et.parent_id},
      #{et.created_at},
      #{et.updated_at}
      )"
      )
    end

    switch_to_current

    sql = "INSERT INTO event_types (
id,
name,
image_path,
synonym_id,
parent_id,
created_at,
updated_at
) VALUES #{et_inserts.join(", ")}"

    ActiveRecord::Base.connection.insert(sql)
  end

  def migrate_authentications()
    authentication_inserts = []

    switch_to_legacy

    authentications = ActiveRecord::Base.connection.query("SELECT * FROM authentications")
    authentications.each do |authentication|
      authentication_inserts.push(
        "(
      #{authentication.user_id},
      #{authentication.provider},
      #{authentication.uid},
      #{authentication.created_at},
      #{authentication.updated_at},
      #{authentication.auth_response}
      )"
      )
    end

    switch_to_current

    sql = "INSERT INTO authentications (
user_id,
provider,
uid,
created_at,
updated_at,
auth_response
) VALUES #{authentication_inserts.join(", ")}"

    ActiveRecord::Base.connection.insert(sql)
  end

  def migrate_connections()
    connection_inserts = []

    switch_to_legacy

    connections = ActiveRecord::Base.connection.query("SELECT * FROM connections")
    connections.each do |connection|
      connection_inserts.push(
        "(
      #{connection.user_id},
      #{connection.to_user_id},
      #{connection.strength},
      #{connection.rank},
      #{connection.facebook_friend},
      #{connection.created_at},
      #{connection.updated_at}
      )"
      )
    end

    switch_to_current

    sql = "INSERT INTO connections (
user_id,
to_user_id,
strength,
rank,
facebook_friend,
created_at,
updated_at
) VALUES #{connection_inserts.join(", ")}"

    ActiveRecord::Base.connection.insert(sql)
  end

  def migrate_users()
    user_inserts = []

    switch_to_legacy

    users = ActiveRecord::Base.connection.query("SELECT * FROM users")
    users.each do |user|
      user_inserts.push(
        "(
      #{user.id}
      #{user.email},
      #{user.sign_in_count},
      #{user.created_at},
      #{user.updated_at},
      #{user.first_name},
      #{user.last_name},
      #{user.username},
      #{user.facebook_profile_picture_url},
      #{user.fb_uid},
      #{user.gender},
      #{user.location},
      #{user.last_known_longitude},
      #{user.last_known_latitude},
      #{user.last_known_location_datetime},
      #{user.fb_friends_imported},
      #{user.accepted_tncs},
    )")
    end

    switch_to_current

    sql = "INSERT INTO users (
id,
email,
sign_in_count,
created_at,
updated_at,
first_name,
last_name,
username,
facebook_profile_picture_url,
fb_uid,
gender,
location,
last_known_longitude,
last_known_latitude,
last_known_location_datetime,
facebook_friends_imports,
accepted_tncs
) VALUES #{user_inserts.join(", ")}"

    ActiveRecord::Base.connection.insert(sql)
  end
end