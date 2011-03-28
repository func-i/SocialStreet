# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)

Event.create! :name => "Event 0001",
  :description => "Fake description for Event based on some random string Lorem Ipsum style",
  :held_on => 10.days.from_now,
  :free => true

Event.create! :name => "Event 0002",
  :description => "Fake description for Event based on some random string Lorem Ipsum style",
  :held_on => 3.days.from_now,
  :cost => 1200 # 12 dollars
