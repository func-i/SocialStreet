class SearchFilter < ActiveRecord::Base

  belongs_to :user


  def self.new_from_params(params)
    attrs = {
      :location => nullable_param(params, :location),
      :radius => nullable_param(params, :radius),
      :from_date => params[:from_date].blank? ? nil : Time.zone.parse(params[:from_date]),
      :to_date => params[:to_date].blank? ? nil : Time.zone.parse(params[:to_date]),
      :inclusive => nullable_param(params, :inclusive),
      :from_time => nullable_param(params, :from_time),
      :to_time => nullable_param(params, :to_time),
      :day_0 => day_selected?(params, 0),
      :day_1 => day_selected?(params, 1),
      :day_2 => day_selected?(params, 2),
      :day_3 => day_selected?(params, 3),
      :day_4 => day_selected?(params, 4),
      :day_5 => day_selected?(params, 5),
      :day_6 => day_selected?(params, 6),
    }
    new(attrs)
  end

  protected

  def self.nullable_param(params, key)
    params[key].blank? ? nil : params[key]
  end

  def self.day_selected?(params, day)
    params[:days] && params[:days].include?(day.to_s)
  end


end
