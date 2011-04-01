# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).

# This file is currently being used for dummy / stub data used to development and testing.
# This is not the long term plan however - KV

################################
## STUB EVENT TYPES
################################
types = {}
types[:soccer] = EventType.create!(:name => 'Soccer')
types[:basketball] = EventType.create!(:name => 'Basketball')
types[:baseball] = EventType.create!(:name => 'Baseball')
types[:football] = EventType.create!(:name => 'Football')
types[:squash] = EventType.create!(:name => 'Squash')
types[:hockey] = EventType.create!(:name => 'Hockey')

################################
## STUB EVENTS
################################

Event.create!(
  {
    :name => "Soccer at Turd Park!",
    :description => "Fake description for Event based on some random string Lorem Ipsum style",
    :starts_at => 10.days.from_now.beginning_of_day + 240.minutes,
    :free => true,
    :event_type => types[:soccer],
    :location_attributes => {
      :street => "373 Front Street W \#1701",
      :city => "Toronto",
      :state => "ON"
    }
  })

Event.create!(
  {:name => "Squash Tournament",
    :description => "We love squash, do you?",
    :starts_at => 3.days.from_now.beginning_of_day + 480.minutes,
    :finishes_at => 3.days.from_now.beginning_of_day + 990.minutes,
    :cost => 1200,
    :event_type => types[:squash],
    :location_attributes => {
      :street => "628 Fleet Street \#1601",
      :city => "Toronto",
      :state => "ON",
      :postal => "M5V 1A8"
    }
  })

Event.create!(
  {:name => "Basketball - We only play '21'",
    :description => "We suck at this, please help us",
    :starts_at => 2.days.from_now.beginning_of_day + 990.minutes,
    :finishes_at => 2.days.from_now.beginning_of_day + 1035.minutes,
    :event_type => types[:basketball],
    :cost => 13000,
    :location_attributes => {
      :street => "",
      :city => "Mississauga",
      :state => "ON",
      :postal => "L5L3M1"
    }
  })

Event.create!(
  {:name => "Baseball Tournament",
    :description => "Baseball although it's not as good as cricket, is what this event is about.",
    :starts_at => 4.days.from_now.beginning_of_day + 1035.minutes,
    :finishes_at => 5.days.from_now.beginning_of_day + 990.minutes,
    :event_type => types[:baseball],
    :cost => 1400,
    :location_attributes => {
      :street => "",
      :city => "Toronto",
      :state => "ON",
      :postal => "M5V1C4"
    }
  })
