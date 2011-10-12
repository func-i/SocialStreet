class Event < ActiveRecord::Base
  before_create :build_initial_rsvp
  before_save :save_default_name

  before_save Proc.new{|event| event.description = event.description.gsub("\r", "<br />") if event.description}
  
  has_many :event_keywords
  has_many :event_rsvps;
  has_many :comments

  belongs_to :user
  belongs_to :location

  accepts_nested_attributes_for :event_keywords, :location

  scope :valid, where(:canceled => false);
  scope :upcoming, where("events.end_date > ?", Time.now)
  
  scope :in_bounds, lambda { |ne_lat, ne_lng, sw_lat, sw_lng|
    includes(:location).merge(Location.in_bounds(ne_lat, ne_lng, sw_lat, sw_lng))
  }

  scope :matching_keywords, lambda { |keywords, include_searchables_with_no_keywords|
    unless keywords.blank?
      chain = joins("LEFT OUTER JOIN event_keywords ON event_keywords.event_id = events.id")
      query = []
      args = {}

      keywords.each_with_index do |k,i|
        unless k.blank?
          query << "events.name ~* :key#{i}
          OR events.description ~* :key#{i}
          OR event_keywords.id IS NULL
          OR event_keywords.name ~* :key#{i}
          "
          args["key#{i}".to_sym] = "#{k}"
        end
      end
      chain.where(query.join(" OR "), args)
    end
  }

  def duration_in_seconds
    end_date - start_date
  end

  def duration_array
    diff_in_seconds = end_date - start_date
    minutes = diff_in_seconds / 60
    hours = minutes / 60
    days = hours / 24

    return [days.floor, "Days"] if days > 1
    return [hours.floor, "Hours"] if hours > 1
    return [minutes.floor, "Minutes"] if minutes > 1
    return [diff_in_seconds, "Seconds"]
  end

  def upcoming
    Time.zone.now < start_date
  end
  
  def event_types
    event_keywords.collect(&:event_type).compact
  end

  def event_keywords_as_sentence
    event_keywords.collect(&:name).compact.to_sentence({:two_words_connector => "&", :last_word_connector => "&"})
  end

  def date_range_as_sentence
    rtn_sentence = start_date.strftime("%a %b %e %l:%M %p")
    if start_date.strftime("%b %e") != end_date.strftime("%b %e")
      rtn_sentence = "#{rtn_sentence} - #{end_date.strftime("%b %e %l:%M %p")}"
    else
      rtn_sentence = "#{rtn_sentence} - #{end_date.strftime("%l:%M %p")}"
    end
  end

  def location_as_sentence
    location.as_sentence
  end

  def title
    return self.name unless self.name.blank?

    return title_from_parameters
  end

  def title_from_parameters(include_date = false)
    title = (self.event_keywords.first.try(:name) || "Something").clone

    if self.location
      if self.location.text.blank?
        if self.location.route.blank?
          title << " @ #{self.location.street}"
        else
          title << " on #{self.location.route}"
        end
      else
        title << " @ #{self.location.text}"
      end
    end

    title << (" - " + (self.starts_at ? self.starts_at.to_s(:date_with_time) : "Sometime")) if include_date

    return title
  end

  def number_of_attendees
    event_rsvps.attending_or_maybe_attending.size
  end

  def can_edit?(user)
    user && !canceled && event_rsvps.by_user(user).first.try(:organizer)
  end

  protected

  def build_initial_rsvp
    event_rsvps.build(:user=>user, :status => EventRsvp.statuses[:attending], :organizer => true) if event_rsvps.empty?
  end

  def save_default_name
    self.name = title_from_parameters(false) unless self.name
  end
end