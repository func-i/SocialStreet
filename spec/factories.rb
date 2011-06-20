Factory.sequence :email do |n|
  "email#{n}@mytestapp.com"
end

Factory.define :user do |user|
  user.first_name 'Person'
  user.sequence(:last_name) {|n| "#{n}"}
  user.email {Factory.next(:email)}
  user.fb_friends_imported true
end

Factory.define :user_with_sign_in, :parent=>:user do |user|
  user.sign_in_count 1
end

Factory.define :event_type do |et|
  et.name "New Event Type"
end

Factory.define :event do |event|
  event.name "New Event"
  event.association :user, :factory => :user_with_sign_in
  event.association :searchable
  event.after_create{|e| Factory(:rsvp, :event=>e)}
end

Factory.define :rsvp do |rsvp|
  rsvp.association :user, :factory => :user_with_sign_in
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

