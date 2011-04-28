class SearchSubscription < ActiveRecord::Base

  belongs_to :user
  belongs_to :searchable

  @@frequencies = {
    :immediate => 'Immediate',
    :daily => 'Daily',
    :weekly => 'Weekly',
    :none => 'None'
  }
  cattr_accessor :frequencies

  validates :name, :presence => true

  default_value_for :frequency, @@frequencies[:daily]

  def self.new_from_params(params)
    searchable = Searchable.new_from_params(params)
    SearchSubscription.new(:searchable => searchable)
  end

  def url_params   
    self.searchable.url_params
  end

  protected

  def self.nullable_param(params, key)
    params[key].blank? ? nil : params[key]
  end

  def self.day_selected?(params, day)
    params[:days] && params[:days].include?(day.to_s)
  end
end
