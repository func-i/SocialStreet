class SearchFiltersController < ApplicationController

  
  def create
    attrs = {
      :location => nullable_param(:location),
      :radius => nullable_param(:radius),
      :from_date => params[:from_date].blank? ? nil : Time.zone.parse(params[:from_date]),
      :to_date => params[:to_date].blank? ? nil : Time.zone.parse(params[:to_date]),
      :inclusive => nullable_param(:inclusive),
      :from_time => nullable_param(:from_time),
      :to_time => nullable_param(:to_time),
      :day_0 => day_selected?(0),
      :day_1 => day_selected?(1),
      :day_2 => day_selected?(2),
      :day_3 => day_selected?(3),
      :day_4 => day_selected?(4),
      :day_5 => day_selected?(5),
      :day_6 => day_selected?(6),
    }

    @search_filter = SearchFilter.new(attrs)
    @search_filter.user = current_user

    if @search_filter.save
      render :text => @search_filter.inspect
    else
      render :text => @search_filter.errors.full_messages.inspect # shouldn't really ever go in here unless there's a bug or something unexpected
    end
  end

  protected

  def nullable_param(key)
    params[key].blank? ? nil : params[key]
  end

  def day_selected?(day)
    params[:days] && params[:days].include?(day.to_s)
  end

end
