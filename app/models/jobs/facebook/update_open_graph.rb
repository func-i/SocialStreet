class Jobs::Facebook::UpdateOpenGraph
  include ActionController::UrlWriter
  require 'UrlHelper'
  
  @queue = :actions

  def self.perform(event_id)
    event = Event.find event_id
    Net::HTTP.post('http://graph.facebook.com/' + event_url(event, :host => "www.socialstreet.com"), 'scrape=true')
  end
end