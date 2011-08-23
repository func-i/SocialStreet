class Searchable < ActiveRecord::Base

  geocoded_by :location_address
  
  belongs_to :location

  has_one :event
  has_one :action
  has_one :comment
  has_one :search_subscription

  has_many :searchable_date_ranges, :dependent => :destroy
  has_many :searchable_event_types, :dependent => :destroy

  has_many :event_types, :through => :searchable_event_types

  accepts_nested_attributes_for :location
  accepts_nested_attributes_for :searchable_date_ranges
  accepts_nested_attributes_for :searchable_event_types, :reject_if => lambda{|set| set["name"].blank? }
  
  before_save :cache_lat_lng
  #  after_create :set_explorable

  scope :order_by_rank_to_user, lambda{ |user|
    joins("LEFT OUTER JOIN connections ON searchable.user_id == connections.to_user_id AND connections.user_id = ?", user.id).
      order("connections.rank ASC NULLS LAST")
  }


  # overriding the with_keywords scope that is normally specified in SuperSearchable mixin
  scope :with_keywords, lambda { |keywords| # keywords in this case is an array, not a string (as expected by SuperSearchable
    unless keywords.blank?
      chain = includes(:event).includes(:comment)
      query = []
      args = {}
      
      keywords.each_with_index do |k, i|
        unless(k.blank?)
          query << "comments.body ~* :key#{i}
          OR events.name ~* :key#{i}
          OR events.description ~*:key#{i}
          OR searchables.id IN ( 
            SELECT searchable_event_types.searchable_id FROM searchable_event_types, event_types
              WHERE searchable_event_types.searchable_id = searchables.id
              AND (
                  searchable_event_types.name LIKE :key#{i}
                  OR (
                    searchable_event_types.event_type_id IS NOT NULL
                    AND event_types.id = searchable_event_types.event_type_id
                    AND event_types.name ~* :key#{i}
                  )
              )
          )"
          args["key#{i}".to_sym] = "#{k}"
        end
      end
      chain.where(query.join(" OR "), args)
    end
  }

  scope :with_keywords_that_match_text_or_keywords, lambda { |text, searchable|
    if !text.blank? && searchable.searchable_event_types.count > 0
      chain = joins("INNER JOIN searchable_event_types AS set ON set.searchable_id = searchables.id")
      chain = chain.joins("INNER JOIN event_types AS et ON set.event_type_id = et.id")
      query = []
      args = {}

      searchable.searchable_event_types.each_with_index{ |k,i|
        query << "set.name ~* :key#{i}"
        args["key#{i}".to_sym] = "#{k.name}"

        if k.event_type_id
          query << "set.event_type_id = :key_b#{i}"
          args["key_b#{i}".to_sym] = "#{k.event_type_id}"
        end
      }

      text_array = text.split(' ') #TODO - this doesn't work when the keywords are multiple words (ex: Ping Pong)
      text_array.each_with_index { |k,i|
        query << "set.name ~* :key#{i}
          OR et.name ~* :key#{i}"

        args["key#{i}".to_sym] = "#{k}"
      }
      
      chain.where(query.join(" OR "), args)
    end
  }

  scope :on_or_after_datetime, lambda {|datetime|
    datetime = Time.zone.parse(datetime) if datetime.is_a? String
    includes(:searchable_date_ranges).where('((searchable_date_ranges.ends_at IS NULL AND searchable_date_ranges.starts_at >= ?) OR searchable_date_ranges.ends_at >= ?)', datetime, datetime) if datetime
  }

  # Expects type IDs, not EventType objects
  scope :with_event_types, lambda {|type_ids|
    includes(:searchable_event_types).where("searchable_event_types.event_type_id IN (?)", type_ids)
  }
  
  scope :explorable, where(:explorable => true)
  
  scope :with_only_subscriptions, joins(:search_subscription)

  scope :with_only_messages, joins(:comment).where("comments.commentable_id IS NULL")

  scope :with_only_events, joins(:event)

  scope :in_bounds, lambda { |ne_lat, ne_lng, sw_lat, sw_lng|
    includes(:location).merge(Location.in_bounds(ne_lat, ne_lng, sw_lat, sw_lng))
  }

  scope :intersecting_bounds, lambda { |ne_lat, ne_lng, sw_lat, sw_lng|
    includes(:location) & Location.intersecting_bounds(ne_lat, ne_lng, sw_lat, sw_lng)
  }
  

  def title_for_searchable
    title = ''

    if keywords.blank? || keywords.empty?
      #title += keywords.to_sentence(:connector => '&', :skip_last_comma => true)
      title += 'Anything'
    else
      title += keywords.to_sentence
    end

    if location
      if location.text && !location.text.blank?
        title += ' near ' + location.text
      else
        title += ' near ' + "#{location.street}, #{location.city}"
      end
    end

    if false && searchable_date_ranges && !searchable_date_ranges.blank?
      # TODO - Include date in title
      title += ' on '
      
      searchable_date_ranges.group_by(&:dow).each do |dr_grp|
        if !dr_grp.first.nil?
          title += SearchableDateRange.dow_string(dr_grp.first)
          days = []
          dr_grp.last.each do |dr|
            case dr.start_time / 3600
            when 0
              days << "Morning"
            when 11
              days << "Afternoon"
            when 17
              days << "Evening"
            end
          end

          title += " (#{days.join(", ")}) " unless days.blank?

        end
      end
    end

    return (title.size > 254 ? (title.first(251) + "...") : title)
  end

  def location_address
    location.geocodable_address if location
  end

  def location_address_for_explore
    location.humanized_address if location
  end

  def geo_located?
    location && location.geo_located?
  end

  def global_comment?
    comment && comment.global?
  end

  def top_level_comment?
    comment && !comment.nested?
  end

  def event_type_ids
    searchable_event_types.all.collect &:event_type_id
  end

  def lat_lng_bounds
    location.bounds
  end

  # search filter params from the form
  def self.new_from_params(params)
    attrs = {}
    
    # assume map_center is set if map_bounds is set - KV
    if !params[:map_bounds].blank?
      # lat/lng order: ne_lat, ne_lng, sw_lat, sw_lng
      bounds = params[:map_bounds].split(",").collect { |point| point.to_f }
      attrs[:location_attributes] = {
        :text => params[:map_location],
        :ne_lat => bounds[0],
        :ne_lng => bounds[1],
        :sw_lat => bounds[2],
        :sw_lng => bounds[3],
        :latitude => params[:map_center].split(",").first.to_f,
        :longitude => params[:map_center].split(",").last.to_f
      }
    elsif !params[:map_center].blank?
      lat,lng = params[:map_center].split(",")
      attrs[:location_attributes] = {
        :text => params[:map_location],
        :latitude => lat.to_f,
        :longitude => lng.to_f
      }
    end
    
    attrs[:searchable_date_ranges_attributes] = []

    unless(date_search = params[:date_search]).blank?
      
      date_search.group_by{|ds| ds.first}.each do |grp|
        day = grp.first
        hours = []

        grp.last.collect{|g| g.split(",").last}.each do |hr|
          case hr
          when "0"
            attrs[:searchable_date_ranges_attributes] << {:dow => day, :start_time => 0.hour, :end_time => 12.hour}
          when "1"
            attrs[:searchable_date_ranges_attributes] << {:dow => day, :start_time => 11.hour, :end_time => 18.hour}
          when "2"
            attrs[:searchable_date_ranges_attributes] << {:dow => day, :start_time => 17.hour, :end_time => 24.hour}
          end
        end
      end
    end

    unless params[:keywords].blank?
      attrs[:searchable_event_types_attributes] = []
      params[:keywords].each do |keyword|
        # if the event_type is already in the db, then link the near searchable_event_type record to it
        # otherwise, have it create a new one
        lower_keyword = keyword.downcase

        event_type = EventType.where("lower(name) = ?", lower_keyword).first # could be nil

        attrs[:searchable_event_types_attributes] << {
          :event_type_id => event_type.try(:id),
          :name => keyword
        }
      end
    end

    new(attrs)
  end

  def keywords
    searchable_event_types.collect &:name
  end

  def searchable_keywords
    keywords = []

    searchable_event_types.each do |set|
      keywords << set.name
      keywords << set.event_type.name if set.event_type
    end

    return keywords.uniq_by{|k| k.downcase}
  end

  def keywords=(keywords_array)
    keywords_array.each do |keyword|
      unless keyword.blank?
        # if the event_type is already in the db, then link the near searchable_event_type record to it
        # otherwise, have it create a new one
        lower_keyword = keyword.downcase

        event_type = EventType.where("lower(name) = ?", lower_keyword).first # could be nil

        self.searchable_event_types.build({
            :event_type => event_type,
            :name => keyword
          })
      end
    end
    
  end

  def url_params
    params = {}

    #Event Types
    params[:keywords] = searchable_event_types.collect { |searchable_event_type|
      searchable_event_type.name ||  searchable_event_type.event_type.try(:name)
    } unless searchable_event_types.blank?

    #Location
    if location
      params[:map_location] = location.text
      params[:map_center] = "#{location.latitude},#{location.longitude}"
      # assume all 4 points set if 1 set for bounds - KV
      # order: ne_lat, ne_lng, sw_lat, sw_lng
      if location.sw_lat?
        params[:map_bounds] = "#{location.ne_lat},#{location.ne_lng},#{location.sw_lat},#{location.sw_lng}"
        params[:map_fit_bounds] = "1"
      end
    end

    unless searchable_date_ranges.blank?
      #TODO
    end

    return params
  end

  protected

  def cache_lat_lng
    if location && !location.new_record?
      self.latitude = location.latitude
      self.longitude = location.longitude
    end

    # => before_save callbacks need to return true otherwise they won't save
    return true
  end

  def self.day_selected?(params, day)
    params[:days] && params[:days].include?(day.to_s)
  end

  # both fields and keywords are arrays
  def self.keyword_conditions_for(fields, keywords)
    fields.collect {|f| "#{f} LIKE '%#{keywords.first}%'"  }.join(" OR ")
  end

end
