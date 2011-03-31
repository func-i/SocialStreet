# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).

# This file is currently being used for dummy / stub data used to development and testing.
# This is not the long term plan however - KV

Event.create!(
  {
    :name => "Event 0001",
    :description => "Fake description for Event based on some random string Lorem Ipsum style",
    :held_on => 10.days.from_now.beginning_of_day + 240.minutes,
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
    :held_on => 3.days.from_now.beginning_of_day + 480.minutes,
    :cost => 1200,
    :location_attributes => {
      :street => "628 Fleet Street \#1601",
      :city => "Toronto",
      :state => "ON",
      :postal => "M5V 1A8"
    }
  })

Event.create!(
  {:name => "Event 0003",
    :description => "Fake description for Event based on some random string Lorem Ipsum style",
    :held_on => 2.days.from_now.beginning_of_day + 990.minutes,
    :cost => 13000,
    :location_attributes => {
      :street => "",
      :city => "Mississauga",
      :state => "ON",
      :postal => "L5L3M1"
    }
  })

Event.create!(
  {:name => "Event 0004",
    :description => "Fake description for Event based on some random string Lorem Ipsum style",
    :held_on => 4.days.from_now.beginning_of_day + 1035.minutes,
    :cost => 1400,
    :location_attributes => {
      :street => "",
      :city => "Toronto",
      :state => "ON",
      :postal => "M5V1C4"
    }
  })
