class EventType < ActiveRecord::Base

  belongs_to :synonym, :class_name => "EventType"
  belongs_to :parent, :class_name => "EventType"
  has_many :searchable_event_types

  make_searchable :fields => %w{event_types.name}

  after_create :default_synonym_to_self

  def image_path
    synonym == self ? read_attribute('image_path') : synonym.image_path
  end

  scope :with_parent_name, lambda { |keyword| select("event_types.name").joins(:parent).where("UPPER(parents_event_types.name) LIKE ?", "%#{keyword.upcase}%") }

  protected

  def default_synonym_to_self
    update_attributes :synonym => self unless synonym
  end

end
