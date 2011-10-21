class MigrateDb

  def switch_to_legacy
    ActiveRecord::Base.establish_connection :legacy
  end

  def switch_to_current
    ActiveRecord::Base.establish_connection "#{RAILS_ENV}"
  end
  
  def migrate
    puts Time.now
    puts "Migrating Users"
    migrate_users()
    puts "Migrating Connections"
    migrate_connections()
    puts "Migrating Authentication"
    migrate_authentications()

    puts "Migrating Event Types"
    migrate_event_types()

    puts "Migrating Locations"
    migrate_locations()

    puts "Migrating Events"
    migrate_events()
    puts "Migrating Rsvps"
    migrate_rsvps()
    puts "Migrating Keywords"
    migrate_keywords()
    puts "Migrating Comments"
    migrate_comments()
    puts Time.now
  end

  #TODO - This doesnt work for non-top level comments
  def migrate_comments()
    switch_to_legacy

    find_in_batches("SELECT comments.user_id, comments.body, events.id, comments.created_at, comments.updated_at FROM comments LEFT OUTER JOIN events ON comments.searchable_id = events.searchable_id WHERE events.id IS NOT NULL") do |comments|
      comment_inserts = []
      
      comments.each do |comment|
        comment_inserts.push(
          "(
      '#{comment[0]}',
      '#{comment[1] ? comment[1].gsub(/[']/, "''") : nil}',
      '#{comment[2]}',
      '#{comment[3] || Time.now}',
      '#{comment[4] || Time.now}'
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
      
      switch_to_legacy
    end

    find_in_batches("SELECT comments.user_id, comments.body, events.id, comments.created_at, comments.updated_at FROM actions LEFT OUTER JOIN actions AS ref_actions ON actions.id = ref_actions.action_id INNER JOIN comments ON comments.id = ref_actions.reference_id INNER JOIN events ON actions.event_id = events.id WHERE actions.action_type = 'Event Comment' AND ref_actions.action_type = 'Action Comment'") do |comments|
      comment_inserts = []

      comments.each do |comment|
        comment_inserts.push(
          "(
      '#{comment[0]}',
      '#{comment[1] ? comment[1].gsub(/[']/, "''") : nil}',
      '#{comment[2]}',
      '#{comment[3] || Time.now}',
      '#{comment[4] || Time.now}'
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

      switch_to_legacy
    end
  end

  def migrate_keywords()
    switch_to_legacy

    find_in_batches("SELECT searchable_event_types.name, searchable_event_types.event_type_id, events.id, searchable_event_types.created_at, searchable_event_types.updated_at FROM searchable_event_types INNER JOIN events ON searchable_event_types.searchable_id = events.searchable_id") do |keywords|
      keyword_inserts = []

      keywords.each do |keyword|
        keyword_inserts.push(
          "(
      '#{keyword[0] ? keyword[0].gsub(/[']/, "''") : nil}',
      #{keyword[1] ? "'" + keyword[1] + "'" : "NULL"},
      '#{keyword[2]}',
      '#{keyword[3] || Time.now}',
      '#{keyword[4] || Time.now}'
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

      switch_to_legacy
    end
  end

  def migrate_rsvps()
    switch_to_legacy

    find_in_batches("SELECT user_id, event_id, posted_to_facebook, status, administrator, created_at, updated_at FROM rsvps") do |rsvps|
      rsvp_inserts = []
        
      rsvps.each do |rsvp|
        rsvp_inserts.push(
          "(
      '#{rsvp[0]}',
      '#{rsvp[1]}',
      '#{rsvp[2]}',
      '#{rsvp[3]}',
      '#{rsvp[4]}',
      '#{rsvp[5] || Time.now}',
      '#{rsvp[6] || Time.now}',
      '',
      NULL
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

      switch_to_legacy
    end

    find_in_batches("SELECT invitations.to_user_id, invitations.event_id, invitations.created_at, invitations.updated_at, invitations.email, invitations.user_id FROM invitations LEFT OUTER JOIN rsvps ON invitations.to_user_id = rsvps.user_id AND invitations.event_id = rsvps.event_id WHERE rsvps.id IS NULL") do |invites|
      rsvp_inserts = []

      invites.each do |invite|
        rsvp_inserts.push(
          "(
        #{invite[0] || "NULL"},
        '#{invite[1]}',
        'f',
        'Invited',
        'f',
        '#{invite[2] || Time.now}',
        '#{invite[3] || Time.now}',
        '#{invite[4]}',
        '#{invite[5]}'
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

      switch_to_legacy
    end
  end

  def migrate_events()
    switch_to_legacy

    find_in_batches("SELECT events.id, events.name, events.description, events.user_id, events.canceled, events.promoted, searchables.location_id, searchable_date_ranges.starts_at, searchable_date_ranges.ends_at, events.created_at, events.updated_at FROM events LEFT OUTER JOIN searchable_date_ranges ON events.searchable_id = searchable_date_ranges.searchable_id LEFT OUTER JOIN searchables ON events.searchable_id = searchables.id") do |events|
      event_inserts = []

      events.each do |event|
        event_inserts.push(
          "(
      '#{event[0]}',
      '#{event[1] ? event[1].gsub(/[']/, "''") : nil}',
      '#{event[2] ? event[2].gsub(/[']/, "''") : nil}',
      '#{event[3]}',
      '#{event[4]}',
      '#{event[5] || 'f'}',
      '#{event[6] || 'f'}',
      '#{event[7] || 'NULL'}',
      '#{event[8] || 'NULL'}',
      '#{event[9] || Time.now}',
      '#{event[10] || Time.now}'
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

      switch_to_legacy
    end
  end

  def migrate_locations()
    switch_to_legacy

    find_in_batches("SELECT id, latitude, longitude, street, city, state, country, postal, neighborhood, route, text, geocoded_address, created_at, updated_at FROM locations") do |locs|
      location_inserts = []

      locs.each do |loc|
        location_inserts.push(
          "(
      '#{loc[0]}',
      #{loc[1] || 'NULL'},
      #{loc[2] || 'NULL'},
      '#{loc[3]}',
      '#{loc[4]}',
      '#{loc[5]}',
      '#{loc[6]}',
      '#{loc[7]}',
      '#{loc[8]}',
      '#{loc[9]}',
      '#{loc[10] ? loc[10].gsub(/[']/, "''") : nil}',
      '#{loc[11] ? loc[11].gsub(/[']/, "''") : nil}',
      '#{loc[12] || Time.now}',
      '#{loc[13] || Time.now}'
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
updated_at
) VALUES #{location_inserts.join(", ")}"

      ActiveRecord::Base.connection.insert(sql)

      switch_to_legacy
    end
  end

  def migrate_event_types()
    switch_to_legacy

    find_in_batches("SELECT id, name, image_path, synonym_id, parent_id, created_at, updated_at FROM event_types") do |ets|
      et_inserts = []
      
      ets.each do |et|        
        et_inserts.push(
          "(
      '#{et[0]}',
      '#{et[1]}',
      '#{et[2]}',
      #{et[3] || 'NULL'},
      #{et[4] || 'NULL'},
      '#{et[5] || Time.now}',
      '#{et[6] || Time.now}'
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

      switch_to_legacy
    end
  end

  def migrate_authentications()
    switch_to_legacy

    find_in_batches("SELECT user_id, provider, uid, created_at, updated_at, auth_response FROM authentications") do |authentications|
      authentication_inserts = []
      
      authentications.each do |authentication|
        authentication_inserts.push(
          "(
      '#{authentication[0]}',
      '#{authentication[1]}',
      '#{authentication[2]}',
      '#{authentication[3] || Time.now}',
      '#{authentication[4] || Time.now}',
      '#{authentication[5] ? authentication[5].gsub(/[']/, "''") : nil}'
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

      switch_to_legacy
    end
  end

  def migrate_connections()

    switch_to_legacy

    find_in_batches("SELECT user_id, to_user_id, strength, rank, facebook_friend, created_at, updated_at FROM connections") do |connections|
      connection_inserts = []

      connections.each do |connection|
        connection_inserts.push(
          "(
      '#{connection[0]}',
      '#{connection[1]}',
      '#{connection[2]}',
      '#{connection[3]}',
      '#{connection[4]}',
      '#{connection[5] || Time.now}',
      '#{connection[6] || Time.now}'
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

      switch_to_legacy
    end
  end

  def migrate_users()
    switch_to_legacy

    find_in_batches("SELECT id, email, sign_in_count, created_at, updated_at, first_name, last_name, username, facebook_profile_picture_url, fb_uid, gender, location, last_known_longitude, last_known_longitude, last_known_location_datetime, fb_friends_imported, accepted_tncs FROM users") do |users|
      user_inserts = []

      user.each do |user|
        user_inserts.push(
          "(
      '#{user[0]}',
      '#{user[1]}',
      '#{user[2]}',
      '#{user[3] || Time.now}',
      '#{user[4] || Time.now}',
      '#{user[5] ? user[5].gsub(/[']/, "''") : nil}',
      '#{user[6] ? user[6].gsub(/[']/, "''") : nil}',
      '#{user[7] ? user[7].gsub(/[']/, "''") : nil}',
      '#{user[8]}',
      '#{user[9]}',
      '#{user[10]}',
      '#{user[11]}',
      #{user[12] || 'NULL'},
      #{user[13] || 'NULL'},
      '#{user[14] || Time.now}',
      '#{user[15]}',
      '#{user[16]}'
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
        
      switch_to_legacy

    end
  end

  BATCH_SIZE = 1000
  def find_in_batches(sql)
    offset = 0
    new_sql = sql + " LIMIT #{BATCH_SIZE} OFFSET #{offset}"
    records = ActiveRecord::Base.connection.query(new_sql)

    while records.any?
      yield records

      break if records.size < BATCH_SIZE

      offset = offset + BATCH_SIZE
      new_sql = sql + " LIMIT #{BATCH_SIZE} OFFSET #{offset}"
      records = ActiveRecord::Base.connection.query(new_sql)
    end
  end
end