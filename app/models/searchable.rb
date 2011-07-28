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

  # overriding the with_keywords scope that is normally specified in SuperSearchable mixin
  scope :with_keywords, lambda { |keywords| # keywords in this case is an array, not a string (as expected by SuperSearchable
    unless keywords.blank?
      chain = includes(:event).includes(:comment)
      query = []
      args = {}
      
      keywords.each_with_index do |k, i|
        unless(k.blank?)
          query << "UPPER(comments.body) LIKE :key#{i}
          OR UPPER(events.name) LIKE :key#{i}
          OR UPPER(events.description) LIKE :key#{i}
          OR searchables.id IN ( 
            SELECT searchable_event_types.searchable_id FROM searchable_event_types, event_types
              WHERE searchable_event_types.searchable_id = searchables.id
              AND event_types.id = searchable_event_types.event_type_id
              AND (
                UPPER(searchable_event_types.name) LIKE :key#{i}
                OR UPPER(event_types.name) LIKE :key#{i}
              )
          )"
          args["key#{i}".to_sym] = "%#{k.upcase}%"
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
        query << "LOWER(set.name) LIKE :key#{i}"
        args["key#{i}".to_sym] = "%#{k.name.downcase}%"

        if k.event_type_id
          query << "set.event_type_id = :key_b#{i}"
          args["key_b#{i}".to_sym] = "#{k.event_type_id}"
        end
      }

      text_array = text.split(' ') #TODO - this doesn't work when the keywords are multiple words (ex: Ping Pong)
      text_array.each_with_index { |k,i|
        query << "LOWER(set.name) LIKE :key#{i}
          OR LOWER(et.name) LIKE :key#{i}"

        args["key#{i}".to_sym] = "%#{k.downcase}%"
      }
      
      chain.where(query.join(" OR "), args)
    end
  }

  scope :on_or_after_date, lambda {|date|
    date = Time.zone.parse(date) if date.is_a? String
    includes(:searchable_date_ranges).where('searchable_date_ranges.starts_at >= ?', date.beginning_of_day) if date
  }
  scope :on_or_before_date, lambda {|date|
    date = Time.zone.parse(date)
    includes(:searchable_date_ranges).where('searchable_date_ranges.starts_at <= ?', date.end_of_day) if date
  }
  scope :at_or_after_time_of_day, lambda {|time|
    interval = sql_interval_for_utc_offset
    includes(:searchable_date_ranges).where("date_part('hour', searchable_date_ranges.starts_at#{interval}) * 60 + date_part('minute', searchable_date_ranges.starts_at#{interval}) >= ?", time)
  }
  scope :at_or_before_time_of_day, lambda {|time|
    interval = sql_interval_for_utc_offset
    includes(:searchable_date_ranges).where("date_part('hour', searchable_date_ranges.starts_at#{interval}) * 60 + date_part('minute', searchable_date_ranges.starts_at#{interval}) <= ?", time)
  }
  scope :starts_at_days, lambda { |days| # days would look like ['0', '1', '2', ... ] which means ['sun', 'mon', 'tues']
    interval = sql_interval_for_utc_offset
    includes(:searchable_date_ranges).where("searchable_date_ranges.dow IN (?) OR EXTRACT(DOW FROM searchable_date_ranges.starts_at#{interval}) IN (?)", days, days)
  }
  
  scope :on_days_or_in_date_range, lambda {|days, from_date, to_date, inclusive|
    if from_date && to_date && (from_date = Time.zone.parse(from_date)) && (to_date = Time.zone.parse(to_date))
      from_date = from_date.beginning_of_day
      to_date = to_date.end_of_day

      if days
        interval = sql_interval_for_utc_offset
        if inclusive
          includes(:searchable_date_ranges).where("searchable_date_ranges.dow IN (?) OR EXTRACT(DOW FROM searchable_date_ranges.starts_at#{interval}) IN (?) OR (searchable_date_ranges.starts_at BETWEEN ? AND ?)", days, days, from_date, to_date)
        else
          #Exclusion should be treated as an OR condition, because we want to remove the days regardless q
          includes(:searchable_date_ranges).where("(searchable_date_ranges.dow IN (?) OR EXTRACT(DOW FROM searchable_date_ranges.starts_at#{interval}) IN (?)) AND (searchable_date_ranges.starts_at NOT BETWEEN ? AND ?)", days, days, from_date, to_date)
        end
      else
        includes(:searchable_date_ranges).where("searchable_date_ranges.starts_at #{'NOT' if !inclusive} BETWEEN ? AND ?", from_date, to_date)
      end
    elsif !days.blank?
      starts_at_days(days)
    end
  }

  scope :on_day_and_in_hours, lambda {|day, hours|
    
  }

  # Expects type IDs, not EventType objects
  scope :with_event_types, lambda {|type_ids|
    includes(:searchable_event_types).where("searchable_event_types.event_type_id IN (?)", type_ids)
  }

  #  scope :excluding_nested_actions, where("searchables.id NOT IN (SELECT searchable_id FROM actions WHERE actions.searchable_id = searchables.id AND actions.action_id IS NOT NULL)")
  # for some reason :excluding_comments scope causes a PG SQL ERROR and I don't know why, yet - KV
  #  scope :excluding_comments, where("searchables.id NOT IN (SELECT searchable_id FROM comments WHERE comments.searchable.id = searchables.id)")
  #  scope :excluding_comments, joins("LEFT OUTER JOIN comments ON comments.searchable_id = searchables.id").where("comments.id IS NULL")
  #  scope :excluding_subscriptions, joins("LEFT OUTER JOIN search_subscriptions ON search_subscriptions.searchable_id = searchables.id").where("search_subscriptions.id IS NULL")
  #  scope :only_search_comment_actions, joins("LEFT OUTER JOIN actions ON actions.searchable_id = searchables.id").where("actions.id IS NULL OR actions.action_type='Search Comment'") #TODO
  #  scope :excluding_actions, includes(:action).where("actions.id IS NULL")
  #  scope :including_search_comments, where("searchables.id NOT IN (SELECT comments.searchable_id FROM comments
  #    INNER JOIN actions ON actions.reference_id = comments.id AND actions.reference_type = 'Comment'
  #    WHERE comments.searchable_id = searchables.id AND (actions.action_type <> 'Search Comment' OR actions.action_id IS NULL))#")
  # called from the explore controller/action
  
  #  scope :with_excludes_for_explore, excluding_actions.excluding_subscriptions.excluding_actions.including_search_comments
  scope :explorable, where(:explorable => true)
  
  scope :with_only_subscriptions, joins(:search_subscription)

  scope :in_bounds, lambda { |ne_lat, ne_lng, sw_lat, sw_lng|
    includes(:location) & Location.in_bounds(ne_lat, ne_lng, sw_lat, sw_lng)
  }

  scope :intersecting_bounds, lambda { |ne_lat, ne_lng, sw_lat, sw_lng|
    includes(:location) & Location.intersecting_bounds(ne_lat, ne_lng, sw_lat, sw_lng)
  }
  
=begin
  scope :matching_date_ranges, lambda { |date_ranges| # events date ranges
    interval = sql_interval_for_utc_offset
    query, values = [], []
    
    date_ranges.each do |dr|
      query << "(
        (( searchable_date_ranges.starts_at IS NOT NULL AND searchable_date_ranges.ends_at IS NOT NULL
            AND (
              searchable_date_ranges.starts_at#{interval} BETWEEN ? AND ?
              OR searchable_date_ranges.ends_at#{interval} BETWEEN ? AND ?
              OR ? BETWEEN searchable_date_ranges.starts_at#{interval} AND searchable_date_ranges.ends_at#{interval}
              OR ? BETWEEN searchable_date_ranges.starts_at#{interval} AND searchable_date_ranges.ends_at#{interval}
            )
        )
        OR (
          searchable_date_ranges.starts_at IS NULL AND searchable_date_ranges.ends_at IS NULL 
          AND ( searchable_date_ranges.dow IS NOT NULL AND searchable_date_ranges.dow = ? )
        ))
        AND (
          searchable_date_ranges.start_time IS NOT NULL OR searchable_date_ranges.end_time IS NULL
          OR searchable_date_ranges.start_time BETWEEN ? AND ?
          OR searchable_date_ranges.end_time BETWEEN ? AND ?
          OR ? BETWEEN searchable_date_ranges.start_time AND searchable_date_ranges.end_time
          OR ? BETWEEN searchable_date_ranges.start_time AND searchable_date_ranges.end_time
        )
      "
      values += [ 
        dr.starts_at.beginning_of_day, dr.ends_at.end_of_day,
        dr.starts_at.beginning_of_day, dr.ends_at.end_of_day,
        dr.starts_at.beginning_of_day, dr.ends_at.end_of_day,
        dr.starts_at.beginning_of_day, dr.ends_at.end_of_day,
        dr.starts_at.wday ] # wday = day of week (0 to 6)
    end

    unless query.empty?
      includes(:searchable_date_ranges).
        where(query.join(" OR "), values)
    end
  }
=end

  def title_for_searchable
    title = ''

    if keywords
      #title += keywords.to_sentence(:connector => '&', :skip_last_comma => true)
      title += keywords.to_sentence
    else
      title += 'Anything'
    end

    if location.text && !location.text.blank?
      title += ' near ' + location.text
    end

    if searchable_date_ranges && !searchable_date_ranges.blank?
      # TODO - Include date in title
      title += ' on '

      dow_hash = {}
      searchable_date_ranges.each { |dr|
        if !dow_hash[dr.dow]
          dow_hash[dr.dow] = []
        end

        if dr.start_time < 13.hours
          dow_hash[dr.dow] << "Morning"
          if dr.end_time > 13.hours
            dow_hash[dr.dow] << "Afternoon"
            if dr.end_time > 19.hours
              dow_hash[dr.dow] << "Evening"
            end
          end
        elsif dr.start_time < 19.hours
          dow_hash[dr.dow] << "Afternoon"
          if dr.end_time > 19.hours
            dow_hash[dr.dow] << "Evening"
          end
        else
          dow_hash[dr.dow] << "Evening"
        end
      }

      dow_array = []
      dow_hash.each do |dow, time|
        #dow_array << @@dow[dow] + ' ' + time.to_sentence(:connector => '&', :skip_last_comma => true)
        dow_array << SearchableDateRange.dow_string(dow) + ' ' + time.to_sentence
      end

      #title += dow_array.to_sentence(:connector => 'and', :skip_last_comma => true)
      title += dow_array.to_sentence
    end

    return title
  end

  def location_address
    location.geocodable_address if location
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

    # Apply the time range from the time slider (if it's been used by the user) to each date range record
    #    if !params[:from_date].blank? || !params[:to_date].blank?
    #      date_range_attrs = {
    #        :starts_at => params[:from_date].blank? ? nil : Date.parse(params[:from_date]).beginning_of_day,
    #        :ends_at => params[:to_date].blank? ? nil : Date.parse(params[:to_date]).end_of_day,
    #        :inclusive => params[:inclusive].blank? ? false : (params[:inclusive]=="on" ? true : false),
    #      }
    #      if params[:from_time].to_i > DAY_FIRST_MINUTE || params[:to_time].to_i < DAY_LAST_MINUTE
    #        date_range_attrs[:start_time] = params[:from_time].to_i
    #        date_range_attrs[:end_time] = params[:to_time].to_i
    #      end
    #      attrs[:searchable_date_ranges_attributes] << date_range_attrs
    #    end
    #
    #    # Apply the time range from the time slider (if it's been used by the user) to each day-of-week (dow) record
    #    unless params[:days].blank?
    #      params[:days].each do |day|
    #        date_range_attrs = { :dow => day }
    #        if params[:from_time].to_i > DAY_FIRST_MINUTE || params[:to_time].to_i < DAY_LAST_MINUTE
    #          date_range_attrs[:start_time] = params[:from_time].to_i
    #          date_range_attrs[:end_time] = params[:to_time].to_i
    #        end
    #        attrs[:searchable_date_ranges_attributes] << date_range_attrs
    #      end
    #    end

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
      #      #Days of the week
      #      params[:days] = searchable_date_ranges.collect{|searchable_date_range| searchable_date_range.dow}.compact
      #
      #      #Date Ranges
      #      params[:from_time] = searchable_date_ranges.collect{|searchable_date_range| searchable_date_range.start_time}.compact.first
      #      params[:to_time] = searchable_date_ranges.collect{|searchable_date_range| searchable_date_range.end_time}.compact.first
      #      params[:inclusive] = searchable_date_ranges.collect{|searchable_date_range| searchable_date_range.inclusive}.compact.first
      #
      #      #Time Ranges
      #      params[:from_date] = searchable_date_ranges.collect{|searchable_date_range| searchable_date_range.start_date}.compact.first
      #      params[:to_date] = searchable_date_ranges.collect{|searchable_date_range| searchable_date_range.end_date}.compact.first
    end

    return params
  end

  #  def set_explorable
  #    val = !!((global_comment? && top_level_comment?) || event)
  #    update_attributes :explorable => val unless explorable == val
  #  end

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
