# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).

# This file is currently being used for dummy / stub data used to development and testing.
# This is not the long term plan however - KV

################################
## STUB EVENT TYPES
################################
types = {}
types[:soccer] = EventType.create!(:name => 'Soccer', :image_path => "/images/type_icons/soccer.png")
types[:basketball] = EventType.create!(:name => 'Basketball', :image_path => "/images/type_icons/basketball.png")
types[:baseball] = EventType.create!(:name => 'Baseball', :image_path => "/images/type_icons/baseball.png")
types[:football] = EventType.create!(:name => 'Football', :image_path => "/images/type_icons/football.png")
types[:squash] = EventType.create!(:name => 'Squash', :image_path => "/images/type_icons/squash.png")
types[:hockey] = EventType.create!(:name => 'Hockey', :image_path => "/images/type_icons/hockey.png")

################################
## STUB USERS
################################
user = User.create!(
  {
  }
)

################################
## STUB EVENTS
################################

Event.create!(
  {
    :name => "Soccer at Turd Park!",
    :user => user,
    :description => "Fake description for Event based on some random string Lorem Ipsum style",
    :searchable_attributes => {
      :searchable_event_types_attributes => [
        { :event_type => types[:soccer] }
      ],
      :searchable_date_ranges_attributes => [
        { :starts_at => 10.days.from_now.beginning_of_day + 240.minutes }
      ],
      :location_attributes => {
        :text => "SocialStreet Head Office",
        :street => "373 Front Street W \#1701",
        :city => "Toronto",
        :state => "ON",
        :user_id => user.id
      }
    }
  })

Event.create!(
  {:name => "Squash Tournament",
    :user => user,
    :description => "We love squash, do you?",
    :cost => 1200,
    :searchable_attributes => {
      :searchable_event_types_attributes => [
        { :event_type => types[:squash] }
      ],
      :searchable_date_ranges_attributes => [
        {
          :starts_at => 3.days.from_now.beginning_of_day + 480.minutes,
          :ends_at => 3.days.from_now.beginning_of_day + 990.minutes,
        }
      ],
      :location_attributes => {
        :text => "YMCA Downtown (not really)",
        :street => "628 Fleet Street \#1601",
        :city => "Toronto",
        :state => "ON",
        :postal => "M5V 1A8",
        :user_id => user.id
      }
    }
  })

Event.create!(
  {:name => "Basketball - We only play '21'",
    :user => user,
    :description => "We suck at this, please help us",
    :cost => 13000,
    :searchable_attributes => {
      :searchable_event_types_attributes => [
        { :event_type => types[:basketball] }
      ],
      :searchable_date_ranges_attributes => [
        {
          :starts_at => 2.days.from_now.beginning_of_day + 990.minutes,
          :ends_at => 2.days.from_now.beginning_of_day + 1035.minutes,
        }
      ],
      :location_attributes => {
        :text => "Downtown Mississauga",
        :street => "",
        :city => "Mississauga",
        :state => "ON",
        :postal => "L5L3M1",
        :user_id => user.id
      }
    }
  })

Event.create!(
  {:name => "Baseball Tournament",
    :user => user,
    :description => "Baseball although it's not as good as cricket, is what this event is about.",
    :cost => 1400,
    :searchable_attributes => {
      :searchable_event_types_attributes => [
        { :event_type => types[:baseball] }
      ],
      :searchable_date_ranges_attributes => [
        {
          :starts_at => 4.days.from_now.beginning_of_day + 1035.minutes,
          :ends_at => 5.days.from_now.beginning_of_day + 990.minutes,
        }
      ],
      :location_attributes => {
        :text => "Downtown Toronto",
        :street => "",
        :city => "Toronto",
        :state => "ON",
        :postal => "M5V1C4",
        :user_id => user.id
      }
    }
  })
