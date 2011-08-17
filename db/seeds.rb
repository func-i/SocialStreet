# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).

# This file is currently being used for dummy / stub data used to development and testing.
# This is not the long term plan however - KV

################################
## STUB EVENT TYPES
################################
types = {}
#PARENTS
types[:sports] = EventType.create!(:name => 'Sports', :image_path => "/images/event_types/basketball.png")

#MAIN TYPES
types[:basketball] = EventType.create!(:name => 'Basketball', :image_path => "/images/event_types/basketball.png", :parent => types[:sports])
types[:bbq] = EventType.create!(:name => 'BBQ', :image_path => "/images/event_types/bbq.png")
types[:beer] = EventType.create!(:name => 'Beer', :image_path => "/images/event_types/beer.png")
types[:board_game] = EventType.create!(:name => 'Board Game', :image_path => "/images/event_types/boardgame.png")
types[:bottle_service] = EventType.create!(:name => 'Bottle Service', :image_path => "/images/event_types/bottleservice.png")
types[:bowling] = EventType.create!(:name => 'Bowling', :image_path => "/images/event_types/bowling.png")
types[:breakfast] = EventType.create!(:name => 'Breakfast', :image_path => "/images/event_types/breakfast.png")
types[:cards] = EventType.create!(:name => 'Cards', :image_path => "/images/event_types/cards.png")
types[:carpool] = EventType.create!(:name => 'Carpool', :image_path => "/images/event_types/carpool.png")
types[:chess] = EventType.create!(:name => 'Chess', :image_path => "/images/event_types/chess.png")
types[:chinese] = EventType.create!(:name => 'Chinese', :image_path => "/images/event_types/chinese.png")
types[:clubbing] = EventType.create!(:name => 'Clubbing', :image_path => "/images/event_types/clubbing.png")
types[:coffee] = EventType.create!(:name => 'Coffee', :image_path => "/images/event_types/coffee.png")
types[:cycling] = EventType.create!(:name => 'Cycling', :image_path => "/images/event_types/cycling.png")
types[:dinner] = EventType.create!(:name => 'Dinner', :image_path => "/images/event_types/dinner.png")
types[:dodgeball] = EventType.create!(:name => 'Dodgeball', :image_path => "/images/event_types/dodgeball.png", :parent => types[:sports])
types[:espanol] = EventType.create!(:name => 'Spanish', :image_path => "/images/event_types/espanol.png")
types[:fitness] = EventType.create!(:name => 'Fitness', :image_path => "/images/event_types/fitness.png")
types[:fossball] = EventType.create!(:name => 'Foosball', :image_path => "/images/event_types/foosball.png")
types[:football] = EventType.create!(:name => 'Football', :image_path => "/images/event_types/football.png")
types[:francais] = EventType.create!(:name => 'French', :image_path => "/images/event_types/francais.png")
types[:frisbee] = EventType.create!(:name => 'Frisbee', :image_path => "/images/event_types/frisbee.png")
types[:golf] = EventType.create!(:name => 'Golf', :image_path => "/images/event_types/golf.png")
types[:hockey] = EventType.create!(:name => 'Hockey', :image_path => "/images/event_types/hockey.png")
types[:house_party] = EventType.create!(:name => 'House Party', :image_path => "/images/event_types/houseparty.png")
types[:ice_cream] = EventType.create!(:name => 'Ice Cream', :image_path => "/images/event_types/icecream.png")
types[:italiano] = EventType.create!(:name => 'Italian', :image_path => "/images/event_types/italiano.png")
types[:jam_session] = EventType.create!(:name => 'Jam Session', :image_path => "/images/event_types/jamsession.png")
types[:korean] = EventType.create!(:name => 'Korean', :image_path => "/images/event_types/korean.png")
types[:lunch] = EventType.create!(:name => 'Lunch', :image_path => "/images/event_types/lunch.png")
types[:meeting] = EventType.create!(:name => 'Meeting', :image_path => "/images/event_types/meeting.png")
types[:mini_golf] = EventType.create!(:name => 'Mini Golf', :image_path => "/images/event_types/minigolf.png")
types[:movie] = EventType.create!(:name => 'Movie', :image_path => "/images/event_types/movie.png")
types[:paintball] = EventType.create!(:name => 'Paintball', :image_path => "/images/event_types/paintball.png")
types[:pool] = EventType.create!(:name => 'Pool', :image_path => "/images/event_types/pool.png")
types[:pre_drink] = EventType.create!(:name => 'Pre Drink', :image_path => "/images/event_types/predrink.png")
types[:run] = EventType.create!(:name => 'Run', :image_path => "/images/event_types/run.png")
types[:sightseeing] = EventType.create!(:name => 'Sightseeing', :image_path => "/images/event_types/sightseeing.png")
types[:soccer] = EventType.create!(:name => 'Soccer', :image_path => "/images/event_types/soccer.png")
types[:squash] = EventType.create!(:name => 'Squash', :image_path => "/images/event_types/squash.png")
types[:study] = EventType.create!(:name => 'Study', :image_path => "/images/event_types/study.png")
types[:swimming] = EventType.create!(:name => 'Swimming', :image_path => "/images/event_types/swimming.png")
types[:table_tennis] = EventType.create!(:name => 'Table Tennis', :image_path => "/images/event_types/tabletennis.png", :parent => types[:sports])
types[:tennis] = EventType.create!(:name => 'Tennis', :image_path => "/images/event_types/tennis.png")
types[:tv] = EventType.create!(:name => 'Television', :image_path => "/images/event_types/tv.png")
types[:videogames] = EventType.create!(:name => 'Videogames', :image_path => "/images/event_types/videogames.png")
types[:volleyball] = EventType.create!(:name => 'Volleyball', :image_path => "/images/event_types/volleyball.png")
types[:walk] = EventType.create!(:name => 'Walk', :image_path => "/images/event_types/walk.png")
types[:waterballon_fight] = EventType.create!(:name => 'Waterballon Fight', :image_path => "/images/event_types/waterballon.png")
types[:weights] = EventType.create!(:name => 'Weights', :image_path => "/images/event_types/weights.png")

#SYNONYMS - Don't need to specify parent if defined on synonym
types[:futball] = EventType.create!(:name => 'Futball', :synonym => types[:soccer] )
types[:ping_pong] = EventType.create!(:name => 'Ping Pong', :synonym => types[:table_tennis] )


################################
## STUB USERS
################################
user = User.create!({})

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
        { :event_type => types[:soccer], :name => "Soccer" }
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
        { :event_type => types[:squash], :name => "Squash" }
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
        { :event_type => types[:basketball], :name => "Basketball" }
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
        { :event_type => types[:baseball], :name => "Baseball" }
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
