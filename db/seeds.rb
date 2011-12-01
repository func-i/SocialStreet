################################
## STUB EVENT TYPES
################################
types = {}
#PARENTS
types[:sports] = EventType.create!(:name => 'Sports', :image_path => "/images/event_types/sports.png")
types[:fitness] = EventType.create!(:name => 'Fitness', :image_path => "/images/event_types/fitness.png")
types[:recreation] = EventType.create!(:name => 'Recreation', :image_path => "/images/event_types/recreation.png")
types[:language_exchange] = EventType.create!(:name => 'Language Exchange', :image_path => "/images/event_types/language_exchange.png")
types[:eating] = EventType.create!(:name => 'Eating', :image_path => "/images/event_types/eating.png")
types[:drinking] = EventType.create!(:name => 'Drinking', :image_path => "/images/event_types/drinking.png")
types[:arts_and_culture] = EventType.create!(:name => 'Arts & Culture', :image_path => "/images/event_types/arts_culture.png")
types[:service_exchange] = EventType.create!(:name => 'Service Exchange', :image_path => "/images/event_types/service_exchange.png")
types[:professional_networking] = EventType.create!(:name => 'Professional Networking', :image_path => "/images/event_types/networking.png")

#MAIN TYPES

types[:baseball] = EventType.create!(:name => 'Baseball', :image_path => "/images/event_types/baseball.png", :parent => types[:sports])
types[:volleyball] = EventType.create!(:name => 'Volleyball', :image_path => "/images/event_types/volleyball.png", :parent => types[:sports])
types[:hockey] = EventType.create!(:name => 'Hockey', :image_path => "/images/event_types/hockey.png", :parent => types[:sports])
types[:basketball] = EventType.create!(:name => 'Basketball', :image_path => "/images/event_types/basketball.png", :parent => types[:sports])
types[:football] = EventType.create!(:name => 'Football', :image_path => "/images/event_types/football.png", :parent => types[:sports])
types[:soccer] = EventType.create!(:name => 'Soccer', :image_path => "/images/event_types/soccer.png", :parent => types[:sports])
types[:frisbee] = EventType.create!(:name => 'Frisbee', :image_path => "/images/event_types/frisbee.png", :parent => types[:sports])
types[:dodgeball] = EventType.create!(:name => 'Dodgeball', :image_path => "/images/event_types/dodgeball.png", :parent => types[:sports])
types[:squash] = EventType.create!(:name => 'Squash', :image_path => "/images/event_types/squash.png", :parent => types[:sports])
types[:golf] = EventType.create!(:name => 'Golf', :image_path => "/images/event_types/golf.png", :parent => types[:sports])
types[:tennis] = EventType.create!(:name => 'Tennis', :image_path => "/images/event_types/tennis.png", :parent => types[:sports])
types[:table_tennis] = EventType.create!(:name => 'Table Tennis', :image_path => "/images/event_types/table_tennis.png", :parent => types[:sports])
types[:skateboard] = EventType.create!(:name => 'Skateboard', :image_path => "/images/event_types/skateboard.png", :parent => types[:sports])

types[:run] = EventType.create!(:name => 'Run', :image_path => "/images/event_types/run.png", :parent => types[:fitness])
types[:swim] = EventType.create!(:name => 'Swim', :image_path => "/images/event_types/swimming.png", :parent => types[:fitness])
types[:cycling] = EventType.create!(:name => 'Cycling', :image_path => "/images/event_types/cycling.png", :parent => types[:fitness])
types[:weights] = EventType.create!(:name => 'Weights', :image_path => "/images/event_types/weights.png", :parent => types[:fitness])
types[:cardio] = EventType.create!(:name => 'Cardio', :image_path => "/images/event_types/cardio.png", :parent => types[:fitness])
types[:exercise_class] = EventType.create!(:name => 'Exercise Class', :image_path => "/images/event_types/exercise_class.png", :parent => types[:fitness])
types[:walk] = EventType.create!(:name => 'Walk', :image_path => "/images/event_types/walk.png", :parent => types[:fitness])

types[:mini_golf] = EventType.create!(:name => 'Mini Golf', :image_path => "/images/event_types/mini_golf.png", :parent => types[:recreation])
types[:foosball] = EventType.create!(:name => 'Foosball', :image_path => "/images/event_types/foosball.png", :parent => types[:recreation])
types[:board_game] = EventType.create!(:name => 'Board Game', :image_path => "/images/event_types/boardgame.png", :parent => types[:recreation])
types[:pool] = EventType.create!(:name => 'Pool', :image_path => "/images/event_types/pool.png", :parent => types[:recreation])
types[:bowling] = EventType.create!(:name => 'Bowling', :image_path => "/images/event_types/bowling.png", :parent => types[:recreation])
types[:paintball] = EventType.create!(:name => 'Paintball', :image_path => "/images/event_types/paintball.png", :parent => types[:recreation])
types[:chess] = EventType.create!(:name => 'Chess', :image_path => "/images/event_types/chess.png", :parent => types[:recreation])
types[:cards] = EventType.create!(:name => 'Cards', :image_path => "/images/event_types/cards.png", :parent => types[:recreation])
types[:water_balloon] = EventType.create!(:name => 'Water Balloon Fight', :image_path => "/images/event_types/water_balloon.png", :parent => types[:recreation])
types[:video_games] = EventType.create!(:name => 'Video Games', :image_path => "/images/event_types/video_games.png", :parent => types[:recreation])
types[:hookah] = EventType.create!(:name => 'Hookah', :image_path => "/images/event_types/hookah.png", :parent => types[:recreation])
types[:hottub] = EventType.create!(:name => 'Hot Tub', :image_path => "/images/event_types/hottub.png", :parent => types[:recreation])
types[:shopping] = EventType.create!(:name => 'Shopping', :image_path => "/images/event_types/shopping.png", :parent => types[:recreation])

types[:french] = EventType.create!(:name => 'French', :image_path => "/images/event_types/francais.png", :parent => types[:language_exchange])
types[:spanish] = EventType.create!(:name => 'Spanish', :image_path => "/images/event_types/espanol.png", :parent => types[:language_exchange])
types[:cantonese] = EventType.create!(:name => 'Cantonese', :image_path => "/images/event_types/cantonese.png", :parent => types[:language_exchange])
types[:mandarin] = EventType.create!(:name => 'Mandarin', :image_path => "/images/event_types/mandarin.png", :parent => types[:language_exchange])
types[:italian] = EventType.create!(:name => 'Italian', :image_path => "/images/event_types/italiano.png", :parent => types[:language_exchange])

types[:breakfast] = EventType.create!(:name => 'Breakfast', :image_path => "/images/event_types/breakfast.png", :parent => types[:eating])
types[:lunch] = EventType.create!(:name => 'Lunch', :image_path => "/images/event_types/lunch.png", :parent => types[:eating])
types[:dinner] = EventType.create!(:name => 'Dinner', :image_path => "/images/event_types/dinner.png", :parent => types[:eating])
types[:coffee] = EventType.create!(:name => 'Coffee', :image_path => "/images/event_types/coffee.png", :parent => types[:eating])
types[:ice_cream] = EventType.create!(:name => 'Ice Cream', :image_path => "/images/event_types/icecream.png", :parent => types[:eating])
types[:bbq] = EventType.create!(:name => 'BBQ', :image_path => "/images/event_types/bbq.png", :parent => types[:eating])
types[:picnic] = EventType.create!(:name => 'Picnic', :image_path => "/images/event_types/picnic.png", :parent => types[:eating])
types[:potluck] = EventType.create!(:name => 'Potluck', :image_path => "/images/event_types/potluck.png", :parent => types[:eating])
types[:wine_cheese] = EventType.create!(:name => 'Wine & Cheese', :image_path => "/images/event_types/wine_cheese.png", :parent => types[:eating])

types[:beer] = EventType.create!(:name => 'Beer', :image_path => "/images/event_types/beer.png", :parent => types[:drinking])
types[:house_party] = EventType.create!(:name => 'House Party', :image_path => "/images/event_types/house_party.png", :parent => types[:drinking])
types[:clubbing] = EventType.create!(:name => 'Clubbing', :image_path => "/images/event_types/clubbing.png", :parent => types[:drinking])
types[:pre_drink] = EventType.create!(:name => 'Pre-Drink', :image_path => "/images/event_types/predrinking.png", :parent => types[:drinking])
types[:bottle_service] = EventType.create!(:name => 'Bottle Service', :image_path => "/images/event_types/bottle_service.png", :parent => types[:drinking])

types[:girls_night] = EventType.create!(:name => 'Girls Night', :image_path => "/images/event_types/girlsnight.png", :parent => types[:drinking])

types[:jam_session] = EventType.create!(:name => 'Jam Session', :image_path => "/images/event_types/jam_session.png", :parent => types[:arts_and_culture])
types[:sight_seeing] = EventType.create!(:name => 'Sight Seeing', :image_path => "/images/event_types/sight_seeing.png", :parent => types[:arts_and_culture])
types[:movie] = EventType.create!(:name => 'Movie', :image_path => "/images/event_types/movie.png", :parent => types[:arts_and_culture])
types[:tv] = EventType.create!(:name => 'TV', :image_path => "/images/event_types/tv.png", :parent => types[:arts_and_culture])
types[:theatre] = EventType.create!(:name => 'Theatre', :image_path => "/images/event_types/theater.png", :parent => types[:arts_and_culture])
types[:concert] = EventType.create!(:name => 'Concert', :image_path => "/images/event_types/concert.png", :parent => types[:arts_and_culture])
types[:painting] = EventType.create!(:name => 'Painting', :image_path => "/images/event_types/painting.png", :parent => types[:arts_and_culture])
types[:cooking] = EventType.create!(:name => 'Cooking', :image_path => "/images/event_types/cooking.png", :parent => types[:arts_and_culture])

types[:carpool] = EventType.create!(:name => 'Carpool', :image_path => "/images/event_types/carpool.png", :parent => types[:service_exchange])
types[:meeting] = EventType.create!(:name => 'Meeting', :image_path => "/images/event_types/meeting.png", :parent => types[:service_exchange])
types[:study] = EventType.create!(:name => 'Study', :image_path => "/images/event_types/study.png", :parent => types[:service_exchange])

types[:finance] = EventType.create!(:name => 'Finance Networking', :image_path => "/images/event_types/finances.png", :parent => types[:professional_networking])
types[:technology] = EventType.create!(:name => 'Technology Networking', :image_path => "/images/event_types/technology.png", :parent => types[:professional_networking])
types[:startups] = EventType.create!(:name => 'Startups Networking', :image_path => "/images/event_types/startups.png", :parent => types[:professional_networking])


#PARENT SYNONYMS - Don't need to specify parent if defined on synonym
types[:play_sport] = EventType.create!(:name => 'Play Sport', :synonym => types[:sports] )
types[:workout] = EventType.create!(:name => 'Workout', :synonym => types[:fitness] )
types[:exercise] = EventType.create!(:name => 'Exercise', :synonym => types[:fitness] )
types[:gym] = EventType.create!(:name => 'Gym', :synonym => types[:fitness] )
types[:activities] = EventType.create!(:name => 'Activities', :synonym => types[:recreation] )
types[:play_game] = EventType.create!(:name => 'Play Game', :synonym => types[:recreation] )
types[:games] = EventType.create!(:name => 'Games', :synonym => types[:recreation] )
types[:speak] = EventType.create!(:name => 'Speak', :synonym => types[:language_exchange] )
types[:talk] = EventType.create!(:name => 'Talk', :synonym => types[:language_exchange] )
types[:eat] = EventType.create!(:name => 'Eat', :synonym => types[:eating] )
types[:food] = EventType.create!(:name => 'Food', :synonym => types[:eating] )
types[:dining] = EventType.create!(:name => 'Dining', :synonym => types[:eating] )
types[:restaurant] = EventType.create!(:name => 'Restaurant', :synonym => types[:eating] )
types[:drink] = EventType.create!(:name => 'Drink', :synonym => types[:drinking] )
types[:alcohol] = EventType.create!(:name => 'Alcohol', :synonym => types[:drinking] )
types[:parties] = EventType.create!(:name => 'Parties', :synonym => types[:drinking] )
types[:bar] = EventType.create!(:name => 'Bar', :synonym => types[:drinking] )
types[:networking] = EventType.create!(:name => 'Networking', :synonym => types[:professional_networking] )
types[:business] = EventType.create!(:name => 'Business Networking', :synonym => types[:professional_networking] )


#MAIN TYPE SYNONYMS - Don't need to specify parent if defined on synonym
types[:play_catch] = EventType.create!(:name => 'Play Catch', :synonym => types[:baseball] )
types[:beach_volleyball] = EventType.create!(:name => 'Beach Volleyball', :synonym => types[:volleyball] )
types[:ice_hockey] = EventType.create!(:name => 'Ice Hockey', :synonym => types[:hockey] )
types[:ball_hockey] = EventType.create!(:name => 'Ball Hockey', :synonym => types[:hockey] )
types[:street_hockey] = EventType.create!(:name => 'Street Hockey', :synonym => types[:hockey] )
types[:shoot_hoops] = EventType.create!(:name => 'Shoot Hoops', :synonym => types[:basketball] )
types[:flag_football] = EventType.create!(:name => 'Flag Football', :synonym => types[:football] )
types[:tackle_football] = EventType.create!(:name => 'Tackle Football', :synonym => types[:football] )
types[:futball] = EventType.create!(:name => 'Futball', :synonym => types[:soccer] )
types[:ultimate_frisbee] = EventType.create!(:name => 'Ultimate Frisbee', :synonym => types[:frisbee] )
types[:biking] = EventType.create!(:name => 'Biking', :synonym => types[:cycling] )
types[:bike_riding] = EventType.create!(:name => 'Bike Riding', :synonym => types[:cycling] )
types[:mountain_biking] = EventType.create!(:name => 'Mountain Biking', :synonym => types[:cycling] )
types[:bmx] = EventType.create!(:name => 'BMX', :synonym => types[:cycling] )
types[:driving_range] = EventType.create!(:name => 'Driving Range', :synonym => types[:golf] )
types[:putting] = EventType.create!(:name => 'Putting', :synonym => types[:golf] )
types[:chipping] = EventType.create!(:name => 'Chipping', :synonym => types[:golf] )
types[:ping_pong] = EventType.create!(:name => 'Ping Pong', :synonym => types[:table_tennis] )
types[:jogging] = EventType.create!(:name => 'Jogging', :synonym => types[:run] )
types[:jog] = EventType.create!(:name => 'Jog', :synonym => types[:run] )
types[:running] = EventType.create!(:name => 'Running', :synonym => types[:run] )
types[:beach] = EventType.create!(:name => 'Beach', :synonym => types[:swim] )
types[:swimming_pool] = EventType.create!(:name => 'Swimming Pool', :synonym => types[:swim] )
types[:swimming] = EventType.create!(:name => 'Swimming', :synonym => types[:swim] )
types[:walk_dog] = EventType.create!(:name => 'Walk Dog', :synonym => types[:walk] )
types[:strength_training] = EventType.create!(:name => 'Strength Training', :synonym => types[:weights] )
types[:bench_press] = EventType.create!(:name => 'Bench Press', :synonym => types[:weights] )
types[:treadmill] = EventType.create!(:name => 'Treadmill', :synonym => types[:cardio] )
types[:elliptical] = EventType.create!(:name => 'Elliptical', :synonym => types[:cardio] )
types[:stationary_bike] = EventType.create!(:name => 'Stationary Bike', :synonym => types[:cardio] )
types[:yoga] = EventType.create!(:name => 'Yoga', :synonym => types[:exercise_class] )
types[:pilates] = EventType.create!(:name => 'Pilates', :synonym => types[:exercise_class] )
types[:aerobics] = EventType.create!(:name => 'Aerobics', :synonym => types[:exercise_class] )
types[:spin_class] = EventType.create!(:name => 'Spin Class', :synonym => types[:exercise_class] )
types[:dance_class] = EventType.create!(:name => 'Dance Class', :synonym => types[:exercise_class] )
types[:mini_putt] = EventType.create!(:name => 'Mini Putt', :synonym => types[:mini_golf] )
types[:miniature_golf] = EventType.create!(:name => 'Miniature Golf', :synonym => types[:mini_golf] )
types[:billiards] = EventType.create!(:name => 'Billiards', :synonym => types[:pool] )
types[:snooker] = EventType.create!(:name => 'Snooker', :synonym => types[:pool] )
types[:poker] = EventType.create!(:name => 'Poker', :synonym => types[:cards] )
types[:euchre] = EventType.create!(:name => 'Euchre', :synonym => types[:cards] )
types[:cribbage] = EventType.create!(:name => 'Cribbage', :synonym => types[:cards] )
types[:rummy] = EventType.create!(:name => 'Rummy', :synonym => types[:cards] )
types[:bridge] = EventType.create!(:name => 'Bridge', :synonym => types[:cards] )
types[:magic_the_gathering] = EventType.create!(:name => 'Magic the Gathering', :synonym => types[:cards] )
types[:pokemon] = EventType.create!(:name => 'Pokemon', :synonym => types[:cards] )
types[:arcade] = EventType.create!(:name => 'Arcade', :synonym => types[:video_games] )
types[:xbox_360] = EventType.create!(:name => 'Xbox 360', :synonym => types[:video_games] )
types[:ps3] = EventType.create!(:name => 'PS3', :synonym => types[:video_games] )
types[:playstation_3] = EventType.create!(:name => 'Playstation 3', :synonym => types[:video_games] )
types[:nintendo_wii] = EventType.create!(:name => 'Nindendo Wii', :synonym => types[:video_games] )
types[:wii] = EventType.create!(:name => 'Wii', :synonym => types[:video_games] )
types[:playstation] = EventType.create!(:name => 'Playstation', :synonym => types[:video_games] )
types[:xbox] = EventType.create!(:name => 'Xbox', :synonym => types[:video_games] )
types[:supper] = EventType.create!(:name => 'Supper', :synonym => types[:dinner] )
types[:coffee_break] = EventType.create!(:name => 'Coffee Break', :synonym => types[:coffee] )
types[:starbucks] = EventType.create!(:name => 'Starbucks', :synonym => types[:coffee] )
types[:tim_hortons] = EventType.create!(:name => 'Tim Hortons', :synonym => types[:coffee] )
types[:gelato] = EventType.create!(:name => 'Gelato', :synonym => types[:ice_cream] )
types[:frozen_yogurt] = EventType.create!(:name => 'Frozen Yogurt', :synonym => types[:ice_cream] )
types[:barbecue] = EventType.create!(:name => 'Barbecue', :synonym => types[:bbq] )
types[:cook_off] = EventType.create!(:name => 'Cook-off', :synonym => types[:bbq] )
types[:pub] = EventType.create!(:name => 'Pub', :synonym => types[:beer] )
types[:beer_pong] = EventType.create!(:name => 'Beer Pong', :synonym => types[:beer] )
types[:kegger] = EventType.create!(:name => 'Kegger', :synonym => types[:house_party] )
types[:dancing] = EventType.create!(:name => 'Dancing', :synonym => types[:clubbing] )
types[:dance] = EventType.create!(:name => 'Dance', :synonym => types[:clubbing] )
types[:rave] = EventType.create!(:name => 'Rave', :synonym => types[:clubbing] )
types[:vip] = EventType.create!(:name => 'VIP', :synonym => types[:bottle_service] )
types[:play_music] = EventType.create!(:name => 'Play Music', :synonym => types[:jam_session] )
types[:museum] = EventType.create!(:name => 'Museum', :synonym => types[:sight_seeing] )
types[:art_gallery] = EventType.create!(:name => 'Art Gallery', :synonym => types[:sight_seeing] )
types[:attractions] = EventType.create!(:name => 'Attractions', :synonym => types[:sight_seeing] )
types[:tourist_attractions] = EventType.create!(:name => 'Tourist Attractions', :synonym => types[:sight_seeing] )
types[:movie_theatre] = EventType.create!(:name => 'Movie Theatre', :synonym => types[:movie] )
types[:movies] = EventType.create!(:name => 'Movies', :synonym => types[:movie] )
types[:cinema] = EventType.create!(:name => 'Cinema', :synonym => types[:movie] )
types[:watch_movie] = EventType.create!(:name => 'Watch Movie', :synonym => types[:movie] )
types[:television] = EventType.create!(:name => 'Television', :synonym => types[:tv] )
types[:watch_tv] = EventType.create!(:name => 'Watch TV', :synonym => types[:tv] )
types[:watch_television] = EventType.create!(:name => 'Watch Television', :synonym => types[:tv] )
types[:live_theatre] = EventType.create!(:name => 'Live Theatre', :synonym => types[:theatre] )
types[:sketch_comedy] = EventType.create!(:name => 'Sketch Comedy', :synonym => types[:theatre] )
types[:play] = EventType.create!(:name => 'Play', :synonym => types[:theatre] )
types[:standup_comedy] = EventType.create!(:name => 'Standup Comedy', :synonym => types[:theatre] )
types[:improv] = EventType.create!(:name => 'Improv', :synonym => types[:theatre] )
types[:indie] = EventType.create!(:name => 'Indie Music', :synonym => types[:concert] )
types[:alternative] = EventType.create!(:name => 'Alternative Music', :synonym => types[:concert] )
types[:classical] = EventType.create!(:name => 'Classical Music', :synonym => types[:concert] )
types[:rock] = EventType.create!(:name => 'Rock Music', :synonym => types[:concert] )
types[:jazz] = EventType.create!(:name => 'Jazz Music', :synonym => types[:concert] )
types[:blues] = EventType.create!(:name => 'Blues Music', :synonym => types[:concert] )
types[:listen_music] = EventType.create!(:name => 'Listen Music', :synonym => types[:concert] )
types[:house_music] = EventType.create!(:name => 'House Music', :synonym => types[:concert] )
types[:music] = EventType.create!(:name => 'Music', :synonym => types[:concert] )
types[:paint] = EventType.create!(:name => 'Paint', :synonym => types[:painting] )
types[:draw] = EventType.create!(:name => 'Draw', :synonym => types[:painting] )
types[:create_art] = EventType.create!(:name => 'Create Art', :synonym => types[:painting] )
types[:ride] = EventType.create!(:name => 'Ride', :synonym => types[:carpool] )
types[:grocery_run] = EventType.create!(:name => 'Grocery Run', :synonym => types[:carpool] )
types[:opportunity] = EventType.create!(:name => 'Opportunity', :synonym => types[:meeting] )
types[:presentation] = EventType.create!(:name => 'Presentation', :synonym => types[:meeting] )
types[:lecture] = EventType.create!(:name => 'Lecture', :synonym => types[:meeting] )
types[:homework] = EventType.create!(:name => 'Homework', :synonym => types[:study] )
types[:tutor] = EventType.create!(:name => 'Tutor', :synonym => types[:study] )
types[:banking] = EventType.create!(:name => 'Banking Networking', :synonym => types[:finance] )
types[:stocks] = EventType.create!(:name => 'Stocks Networking', :synonym => types[:finance] )
types[:investing] = EventType.create!(:name => 'Investing Networking', :synonym => types[:finance] )
types[:web] = EventType.create!(:name => 'Web Networking', :synonym => types[:technology] )
types[:information_technology] = EventType.create!(:name => 'Information Technology Networking', :synonym => types[:technology] )
types[:IT] = EventType.create!(:name => 'IT Networking', :synonym => types[:technology] )
types[:mobile] = EventType.create!(:name => 'Mobile Networking', :synonym => types[:technology] )
types[:internet] = EventType.create!(:name => 'Internet Networking', :synonym => types[:technology] )
types[:entrepreneurs] = EventType.create!(:name => 'Entrepreneurs Networking', :synonym => types[:startups] )


################################
## STUB USERS
################################
user = User.create!({})

################################
## STUB LOCATION
################################
location = Location.create!(
  {
    :text => "Downtown Toronto",
    :street => "",
    :city => "Toronto",
    :state => "ON",
    :postal => "M5V1C4",
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
    :location => location,
    :start_date => 10.days.from_now.beginning_of_day + 240.minutes,
    :end_date => 10.days.from_now.beginning_of_day + 440.minutes,
    :event_keywords_attributes => [{
      :event_type => types[:soccer],
      :name => "Soccer"
    }]
  }
)

Event.create!(
  {
    :user => user,
    :description => "Fake description for Event based on some random string Lorem Ipsum style Lorem Ipsum style Lorem Ipsum style Lorem Ipsum style Lorem Ipsum style Lorem Ipsum style HAHAHAH Lorem Ipsum style Lorem Ipsum style BLAH",
    :location_attributes => {
      :longitude => -79.43879281240231,
      :latitude => 43.64670544118856
    },
    :start_date => 10.days.from_now.beginning_of_day + 240.minutes,
    :end_date => 11.days.from_now.beginning_of_day + 440.minutes,
    :event_keywords_attributes => [{
      :event_type => types[:basketball],
      :name => "Basketball"
    }]
  }
)