class Jobs::Facebook::UpdateOpenGraph
  require 'net/http'
  
  @queue = :actions

  def self.perform(event_id)
    uri = URI("http://graph.facebook.com/http://www.socialstreet.com/events/#{event_id}")
    Net::HTTP.post_form(uri, 'scrape' => 'true')
  end
end