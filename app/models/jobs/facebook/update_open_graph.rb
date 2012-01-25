class Jobs::Facebook::UpdateOpenGraph  
  @queue = :actions

  def self.perform(event_id)
    Net::HTTP.post("http://graph.facebook.com/http://www.socialstreet.com/events/#{event_id}/?scrape=true")
  end
end