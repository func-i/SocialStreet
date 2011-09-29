class Jobs::Scraper::Now
  class << self

    def perform
      require 'nokogiri'
      require 'open-uri'
      require 'geocoder'

      ss_user = User.find_by_first_name_and_last_name("Social", "Street")
      
      url = "http://www.nowtoronto.com/music/listings"
      doc = Nokogiri::HTML(open(url))
      listing_ids = doc.css('.List-Name').collect{|listing| listing.parent.parent.parent.parent.attributes['onclick'].value.gsub(/[^\d]/, '')}

      listing_ids.first(500).each do |listing_id|
        event_link = "http://www.nowtoronto.com/music/listings/listing.cfm?listingid=#{listing_id}"
        event_page = Nokogiri::HTML(open(event_link))
        event_title = event_page.at_css(".listing-title").text.gsub("\t", '').gsub("\n", '')
        event_admission = event_page.search(".listing-genre").select{|lt| lt.content.gsub("\t", '').gsub("\n", '').include?("Admission")}

        description = ""
        unless event_admission.blank?          
          description += "Admission:#{event_admission.first.next.text}, "
        end

        description += "Webpage: #{event_link}"

        event_location = event_page.search('span').select{|s| !s.attributes["property"].blank? && s.attributes["property"].value == "v:location"}.first.content.gsub("\t", '').gsub("\n", '')
        event_date = event_page.search('span').select{|s| !s.attributes["property"].blank? && s.attributes["property"].value == "v:datestart"}.first.attributes['content'].value.gsub("\t", '').gsub("\n", '')
        event_date = "#{event_date} 21:00".to_date

        lat_lng = Geocoder.coordinates(event_location)
        
        if lat_lng && !lat_lng.empty?
          event_attrs = {
            :user => ss_user,
            :name => event_title,
            :start_date => event_date,
            :end_date => event_date + 1.hour,
            :description => description,
            :location_attributes => {:geocoded_address => event_location, :latitude => lat_lng.first, :longitude => lat_lng.last}
          }

          Event.create!(event_attrs) if Event.where(:name => event_title).empty?
        end

      end
      
    end

    def watir_perform
      require 'watir-webdriver-rails'

      begin
        headless = Headless.new
        headless.start

        browser = Watir::Browser.new :firefox
        browser.goto "http://www.nowtoronto.com/music/listings"

        raise browser.inspect

      end
    end
  end
end