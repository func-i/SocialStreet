Factory.define :user do |user|
  user.first_name 'Person'
  user.sequence(:last_name) {|n| "#{n}"}
  user.sequence(:email) {|n| "email#{n}@mytestapp.com"}
end

Factory.define :event_type do |et|
  et.name "New Event Type"
end

Factory.define :event do |event|
  event.name "New Event"
  event.association :user
  event.association :searchable
  event.after_create{|e| Factory(:rsvp, :event=>e)}
end

Factory.define :rsvp do |rsvp|
  rsvp.association :user
  rsvp.association :event
  rsvp.status "Attending"
end

Factory.define :location do |loc|
  loc.text "A new location"
end

Factory.define :searchable do |sea|
  sea.association :location
  sea.after_create{|s| Factory(:searchable_date_range, :searchable=>s)}
end

Factory.define :searchable_date_range do |sdr|
  sdr.starts_at "#{5.days.from_now}"
end

