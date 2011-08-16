class Event < ActiveRecord::Base

  humanize_price :cost # creates cost_in_dollars getter/setter methods
  mount_uploader :photo, EventPhotoUploader

  belongs_to :user
  belongs_to :searchable, :dependent => :destroy
  
  belongs_to :action # if created through an activity stream
  
  has_many :rsvps, :dependent => :destroy
  has_many :rsvp_users, :through => :rsvps, :source => :user

  has_many :invitations

  has_many :actions, :dependent => :destroy
  has_many :comments, :as => :commentable, :dependent => :destroy
  
  accepts_nested_attributes_for :searchable

  attr_accessor :exclude_end_date
  attr_accessor :current_user
  attr_accessor :facebook

  # => Because this is an accessor the checkbox on the forms will populate it with "0"
  # => If it is set to "0" then set it to false
  def facebook=(val)
    @facebook = (val.eql?("0") ? false : val)
  end

  #before_validation :set_default_title, :if => Proc.new{|e| e.name.blank?}
  before_create :build_initial_rsvp
  
  #before_destroy :validate_destroy  
  after_create :make_searchable_explorable

  after_create {|record| record.user.post_to_facebook_wall(
      :message => "SocialStreet Event Created: #{record.name}"
    ) if record.facebook }

  #after_save :set_default_title, :on => :update,  :if => Proc.new{|e| e.default_title?}

  #validates :name, :presence => true, :length => { :maximum => 60 }
  validates :starts_at, :presence => {:message => "^ When? can't be blank?"}
  validates :cost, :presence => true, :numericality => { :only_integer => true, :greater_than_or_equal_to => 0 }
  validates :minimum_attendees, :numericality => {:only_integer => true, :greater_than_or_equal_to => 0, :allow_blank => true }
  validates :maximum_attendees, :numericality => {:only_integer => true, :greater_than_or_equal_to => 1, :allow_blank => true }
  #  validates :event_type, :presence => true
  #validate :valid_dates
  validate :valid_maximum_attendees

  validate :validate_event_types, :message => "^ What? can't be blank", :on => :create

  def validate_event_types
    if searchable.keywords.empty?
      errors.add :searchable, "^ What? can't be blank"
    end
  end

  default_value_for :guests_allowed, true
  default_value_for :cost_in_dollars, 0
  default_value_for :facebook, true
  default_value_for :canceled, false

  scope :attended_by_user, lambda {|user|
    includes(:rsvps).where({ :rsvps => {:user_id => user.id, :status => Rsvp::statuses[:attending] }})
  }
  scope :upcoming, lambda {
    includes({:searchable => [:searchable_date_ranges] }).where("searchable_date_ranges.starts_at > ? AND events.canceled = false", Time.zone.now)
  }
  scope :passed, lambda {
    includes({:searchable => [:searchable_date_ranges] }).where("searchable_date_ranges.starts_at < ?", Time.zone.now)
  }
  scope :administered_by_user, lambda {|user|
    includes(:rsvps).where({ :rsvps => {:user_id => user.id, :administrator => true }})
  }  

  # SELECT xyz FROM events JOIN dateranges ON  dr.event_id = e.id WHERE dr.x = 1 OR dr.y = 1

  #  def exclude_end_date
  #    finishes_at ? 0 : 1
  #  end
  #
  #  def exclude_end_date=(exclude_end_date_val)
  #    if exclude_end_date_val != 0
  #      self.finishes_at = nil
  #      #TODO - Why doesn't this work?
  #    end
  #  end

  def title
    return self.name unless self.name.blank?
        
    title = (self.searchable_event_types.first.try(:name) || "Something").clone # need clone otherwise event type name is modified

    if self.location
      if self.location.text.blank?
        if self.location.neighborhood.blank?
          if self.location.route.blank?
            title << " @ #{self.location.street}"
          else
            title << " on #{self.location.route}"
          end
        else
          title << " in #{self.location.neighborhood}"
        end
      else
        title << " @ #{self.location.text}"
      end
    end

    title << (" - " + (self.starts_at ? self.starts_at.to_s(:date_with_time) : "Sometime"))


    return title
  end

  def upcoming
    bool = false
    searchable.searchable_date_ranges.each do |dr|
      if dr.starts_at && dr.starts_at > Time.zone.now
        bool = true
      end
    end

    bool && !self.canceled
  end

  def location_address
    location.geocodable_address if location
  end

  def geo_located?
    location && location.geo_located?
  end

  # Stub
  def custom_image?
    false # for now
  end

  def attending_users
    User.attending_event(self).where("rsvps.status IN (?)", Rsvp::statuses.except(:not_attending).values)
  end

  def num_attending
    rsvps.attending.size
  end
  def attendees_rsvps_list
    rsvps.attending
  end
  def num_waiting
    rsvps.waiting.size
  end
  def waitees_rsvps_list
    rsvps.waiting
  end

  def num_maybe_attending
    rsvps.maybe_attending.size
  end
  def maybe_attendees_rsvps_list
    rsvps.maybe_attending
  end

  def num_attending_or_maybe_attending
    rsvps.attending_or_maybe_attending.size
  end
  def attending_or_maybe_attendees_rsvps_list
    rsvps.attending_or_maybe_attending
  end

  def num_administrators
    rsvps.administrators.size
  end
  def administrators_rsvps_list
    rsvps.administrators
  end


  def free?
    !paid?
  end
  def paid?
    cost? && cost > 0
  end

  def number_of_attendees_needed
    if minimum_attendees?
      diff = minimum_attendees - num_attending
      if diff < 0
        return 0
      else
        return diff
      end
    else
      return 0
    end
  end

  def number_of_spots_left
    if maximum_attendees?
      diff = maximum_attendees - num_attending
      if diff < 0
        return 0
      else
        return diff
      end
    end
  end


  def editable_by?(user)
    return false if user == nil
    
    rsvp = rsvps.by_user(user).first

    user == self.user || (rsvp && rsvp.administrator)
  end

  EDITABLE_OFFSET = 0
  def editable_time?
    #editable if not within X hours before the start_time
    return (starts_at - EDITABLE_OFFSET > Time.zone.now)
  end

  def editable?(user)
    editable_by?(user) && editable_time?
  end

  def cancellable_by?(user)
    self.user == user
  end

  def cancellable?(user)
    return cancellable_by?(user) && editable_time?
  end

  # TEMPORARY HELPERS

  def location
    searchable.try(:location)
  end
  def latitude
    searchable.latitude
  end
  def longitude
    searchable.longitude
  end

  def searchable_event_types
    searchable.searchable_event_types
  end

  def event_types
    searchable.searchable_event_types.collect(&:event_type).compact
  end

  def starts_at # assuming non recurring events, for now
    searchable.searchable_date_ranges.first.try :starts_at
  end

  def finishes_at  # assuming non recurring events, for now
    searchable.searchable_date_ranges.first.try :ends_at
  end

  def start_date
    searchable.searchable_date_ranges.first.try(:starts_at).strftime("%B %d")
  end

  def end_date
    searchable.searchable_date_ranges.first.try(:ends_at).strftime("%B %d")
  end

  def cancel
    update_attribute("canceled", true)
    searchable.update_attribute("ignored", true)
  end

  def default_title?
    self.name =~ /^\w+\s@\s.+(\son\s)/
  end

  
  protected

  def make_searchable_explorable
    searchable.update_attributes :explorable => true if searchable
  end

  def set_default_title
    self.name = (searchable_event_types.first.try(:name) || "Something").clone # need clone otherwise event type name is modified
    self.name << (" @ " + (location.text ? location.text : "#{location.street} #{location.city}, #{location.state}"))
    self.name << (" on " + (starts_at ? starts_at.to_s(:date_with_time) : "Sometime"))
  end

  #  def valid_dates
  #    errors.add :finishes_at, 'must be after the event starts' if finishes_at && finishes_at <= starts_at
  #  end
  def valid_maximum_attendees
    if minimum_attendees? && maximum_attendees? && maximum_attendees < minimum_attendees
      errors.add :maximum_attendees, 'must be greater than or equal to the minimum'
    end
  end

  def build_initial_rsvp
    rsvps.build(:user=>user, :status => Rsvp.statuses[:attending], :administrator => 1, :facebook => false) if rsvps.empty?
  end 
  
end
