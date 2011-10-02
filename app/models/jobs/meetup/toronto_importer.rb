class Jobs::Meetup::TorontoImporter

  class << self

    def perform
      require 'net/http'
      require 'net/https'
      require 'uri'

      url = URI.parse("https://api.meetup.com")
      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true
      res = http.start do |req|
        req.get("/2/open_events?key=13e7266216d552c771643154544122&sign=true&city=Toronto&country=CA&page=20&format=json")
      end

      results = JSON.parse(res.body)

      ss_user = User.find_by_first_name_and_last_name("Social", "Street")

      # => LOL at the line below :)
      results["results"].each do |result|
        begin
          if result["name"] && Event.find_by_name(result["name"]).nil? && result["venue"]
            start_time = Time.at(result["time"].to_i / 1000)
            event_attrs = {
              :user => ss_user,
              :name => result["name"],
              :description => result["description"],
              :start_date => start_time,
              :end_date => start_time + 1.hour,
              :location_attributes => {
                :latitude => result["venue"]["lat"], :longitude => result["venue"]["lon"],
                :geocoded_address => result["venue"]["address_1"]
              }
            }
            e = Event.create!(event_attrs)
            e.event_rsvps.first.update_attribute("status", EventRsvp.statuses[:not_attending])
            puts "created => #{e.title}"
          
          end
        rescue
        end
      end
      
    end


  end

end
