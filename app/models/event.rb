class Event < ActiveRecord::Base
  before_create :build_initial_rsvp

  has_many :event_keywords
  has_many :event_rsvps;
  has_many :comments

  belongs_to :user
  belongs_to :location

  accepts_nested_attributes_for :event_keywords, :location

  scope :valid, where(:canceled => false);
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

#    unless keywords.blank?
#      chain = includes(:event).includes(:comment)
#      chain = chain.joins("LEFT OUTER JOIN searchable_event_types ON searchable_event_types.searchable_id = searchables.id") if include_searchables_with_no_keywords
#      query = []
#      args = {}
#
#      keywords.each_with_index do |k, i|
#        unless(k.blank?)
#          query << "comments.body ~* :key#{i}
#          OR events.name ~* :key#{i}
#          OR events.description ~*:key#{i}
#          OR searchables.id IN (
#            SELECT set.searchable_id FROM searchable_event_types AS set, event_types
#              WHERE set.searchable_id = searchables.id
#              AND (
#                  set.name LIKE :key#{i}
#                  OR (
#                    set.event_type_id IS NOT NULL
#                    AND event_types.id = set.event_type_id
#                    AND event_types.name ~* :key#{i}
#                  )
#              )
#          )
          #{"OR searchable_event_types.id IS NULL" if include_searchables_with_no_keywords}
          #"
#          args["key#{i}".to_sym] = "#{k}"
#        end
#      end
#      chain.where(query.join(" OR "), args)
#    end
  }

  def event_types
    event_keywords.collect(&:event_type).compact
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

  protected

  def build_initial_rsvp
    event_rsvps.build(:user=>user, :status => EventRsvp.statuses[:attending], :organizer => true) if event_rsvps.empty?
  end

end