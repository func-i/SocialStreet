class EventType < ActiveRecord::Base
  belongs_to :synonym, :class_name => "EventType"
  belongs_to :parent, :class_name => "EventType"
  has_many :children, :class_name => "EventType", :foreign_key => "parent_id"
  has_many :event_keywords

  after_create :default_synonym_to_self

  scope :matching_text, lambda { |text|
    where("event_types.name ~* ?", "[[:<:]]#{text}")
  }
  scope :with_parent_name, lambda { |keyword| joins(:parent).where("parents_event_types.name ~* ?", "[[:<:]]#{keyword}") }

  def image_path
    synonym == self ? read_attribute('image_path') : synonym.image_path
  end

  protected

  def default_synonym_to_self
    update_attributes :synonym => self unless synonym
  end
end
