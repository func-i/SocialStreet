class Jobs::Facebook::UpdateOpenGraph
  def self.perform(event_id)
    event = Event.find event_id
    Net::HTTP.post('http://graph.facebook.com/' + event_url(event), 'scrape=true')
  end
end