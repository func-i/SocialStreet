# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).

# This file is currently being used for dummy / stub data used to development and testing.
# This is not the long term plan however - KV

Event.create!(
  {
    :name => "Event 0001",
    :description => "Fake description for Event based on some random string Lorem Ipsum style",
    :held_on => 10.days.from_now,
    :free => true,
    :location_attributes => {
      :street => "373 Front Street W \#1701",
      :city => "Toronto",
      :state => "ON"
    }
  })

Event.create!(
  {:name => "Event 0002",
    :description => "Fake description for Event based on some random string Lorem Ipsum style",
    :held_on => 3.days.from_now,
    :cost => 1200,
    :location_attributes => {
      :street => "628 Fleet Street \#1601",
      :city => "Toronto",
      :state => "ON",
      :postal => "M5V 1A8"
    }
  })
