class SourceDB < ActiveRecord::Base
  ActiveRecord::Base.establish_connection(
    :adapter => 'postgres',
    :database => 'SocialStreet_reborn_test',
    :username => 'postgres',
    :password => '',
    :host => 'localhost'
  )
end

class SinkDB < ActiveRecord::Base
  ActiveRecord::Base.establish_connection(
    :adapter => 'postgres',
    :database => 'SocialStreet_reborn_test',
    :username => 'postgres',
    :password => '',
    :host => 'localhost'
  )
end


def migrate
  srcDB = SourceDB.new
  sinkDB = SinkDB.new

  migrate_users(srcDB, sinkDB)
  migrate_connections(srcDB, sinkDB)
  migrate_authentications(srcDB, sinkDB)

  migrate_event_types(srcDB, sinkDB)

  migrate_locations(srcDB, sinkDB)

  migrate_events(srcDB, sinkDB)
  migrate_rsvps(srcDB, sinkDB)
end

def migrate_rsvps(srcDB, sinkDB)
  rsvps = srcDB.connection.query("SELECT * FROM rsvps LEFT OUTER JOIN invitations ON rsvps.id = invitations.rsvp_id")
  rsvp_inserts = []
  rsvps.each do |rsvp|
    rsvp_inserts.push(
      "(
      #{rsvp.user_id},
      #{rsvp.event_id},
      #{rsvp.posted_to_facebook},
      #{rsvp.status},
      #{rsvp.administrator},
      #{rsvp.email},

      #{rsvp.created_at},
      #{rsvp.updated_at}
      )"
    )
  end

  sql = "INSERT INTO event_rsvps (
user_id,
event_id,
posted_to_facebook,
status,
organizer,
email,
created_at,
updated_at
) VALUES #{event_inserts.join(", ")}"

  sinkDB.connection.insert(sql)
end

def migrate_events(srcDB, sinkDB)
  events = srcDB.connection.query("SELECT * FROM events LEFT OUTER JOIN searchable_date_ranges ON events.searchable_id = searchable_date_ranges.searchable_id")
  event_inserts = []
  events.each do |event|
    event_inserts.push(
      "(
      #{event.id},
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

  sinkDB.connection.insert(sql)
end

def migrate_locations(srcDB, sinkDB)
  locations = srcDB.connection.query("SELECT * FROM locations")
  location_inserts = []
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

  sinkDB.connection.insert(sql)
end

def migrate_event_types(srcDB, sinkDB)
  event_types = srcDB.connection.query("SELECT * FROM event_types")
  et_inserts = []
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

  sql = "INSERT INTO event_types (
id,
name,
image_path,
synonym_id,
parent_id,
created_at,
updated_at
) VALUES #{et_inserts.join(", ")}"

  sinkDB.connection.insert(sql)
end

def migrate_authentications(srcDB, sinkDB)
  authentications = srcDB.connection.query("SELECT * FROM authentications")
  authentication_inserts = []
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

  sql = "INSERT INTO authentications (
user_id,
provider,
uid,
created_at,
updated_at,
auth_response
) VALUES #{authentication_inserts.join(", ")}"

  sinkDB.connection.insert(sql)
end

def migrate_connections(srcDB, sinkDB)
  connections = srcDB.connection.query("SELECT * FROM connections")
  connection_inserts = []
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

  sql = "INSERT INTO connections (
user_id,
to_user_id,
strength,
rank,
facebook_friend,
created_at,
updated_at
) VALUES #{connection_inserts.join(", ")}"

  sinkDB.connection.insert(sql)
end

def migrate_users(srcDB, sinkDB)
  users = srcDB.connection.query("SELECT * FROM users")
  user_inserts = []
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

  sinkDB.connection.insert(sql)
end