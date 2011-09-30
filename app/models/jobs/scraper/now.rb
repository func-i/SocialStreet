class Jobs::Scraper::Now
  class << self

    def perform
      require 'nokogiri'
      require 'open-uri'
      require 'geocoder'

      ss_user = User.find_by_first_name_and_last_name("Social", "Street")

      %w{art music}.each do |keyword|

        date_one = Date.today.strftime("%d-%b-%y")
        date_two = (Date.today + 2.months).strftime("%d-%b-%y")
      
        url = "http://www.nowtoronto.com/#{keyword}/listings"
        date_url = url + "?/index.cfm?date1=#{date_one}&date2=#{date_two}"
        doc = Nokogiri::HTML(open(date_url))
        listing_ids = doc.css('.List-Name').collect{|listing| listing.parent.parent.parent.parent.attributes['onclick'].value.gsub(/[^\d]/, '') rescue nil}

        listing_ids.compact.each do |listing_id|
          event_link = "#{url}/listing.cfm?listingid=#{listing_id}"
          event_page = Nokogiri::HTML(open(event_link))
        
          case keyword
          when "art"

            event_loc = event_page.search(".listing-genre").select{|lt| lt.content.gsub("\t", '').gsub("\n", '').include?("Where")}
   
            unless event_loc.blank?
              event_location = event_loc.first.next.text.gsub("\t", '').gsub("\n", '').gsub("\r", "").strip
            end

            lat_lng = Geocoder.coordinates(event_location)
            next if !lat_lng || lat_lng.empty?
              
            event_artist = event_page.search(".listing-genre").select{|lt| lt.content.gsub("\t", '').gsub("\n", '').include?("Artist")}

            event_title = event_artist.blank?  ? "Art @ #{event_location}" : event_artist.first.next.text

            event_date = event_artist = event_page.search(".listing-genre").select{|lt| lt.content.gsub("\t", '').gsub("\n", '').include?("When")}
            unless event_date.blank?
                 
              begin
                ed_text = event_date.first.next.text.gsub("\t", '').gsub("\n", '').gsub("\r", '')
                ed_arr = ed_text.split(" ")
                ed_month = ed_arr.first
                ed_day = ed_arr.last.gsub(/[^\d]/, ' ').split(" ").first
              
                event_date = DateTime.strptime("#{ed_month} #{ed_day} 2011", "%b %d %Y")
              rescue
                next
              end
            end

          else
            #begin

            event_location = event_page.search('span').select{|s| !s.attributes["property"].blank? && s.attributes["property"].value == "v:location"}.first.content.gsub("\t", '').gsub("\n", '')
            lat_lng = Geocoder.coordinates(event_location)
            next if !lat_lng || lat_lng.empty?
            event_date = event_page.search('span').select{|s| !s.attributes["property"].blank? && s.attributes["property"].value == "v:datestart"}.first.attributes['content'].value.gsub("\t", '').gsub("\n", '')

            event_date = "#{event_date} 21:00".to_date
            #rescue
            #  next
            #end
            event_title = event_page.at_css(".listing-title").text.gsub("\t", '').gsub("\n", '')
          end
          
          event_admission = event_page.search(".listing-genre").select{|lt| lt.content.gsub("\t", '').gsub("\n", '').include?("Admission")}

          description = ""
          unless event_admission.blank?
            description += "Admission:#{event_admission.first.next.text}, "
          end

          description += "Webpage: #{event_link}"
          
          event_attrs = {
            :user => ss_user,
            :name => event_title,
            :start_date => event_date,
            :end_date => event_date + 1.hour,
            :description => description,
            :location_attributes => {:geocoded_address => event_location, :latitude => lat_lng.first, :longitude => lat_lng.last},
            :event_keywords_attributes => [{:name => keyword}]
          }
            
          if Event.where(:name => event_title).empty?
            Event.create!(event_attrs)
            puts "created => #{event_title}"
          end
             

        end # => End all listings
      end # => End keyword
      
    end    
  end
end