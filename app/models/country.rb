class Country
  include ActiveModel::Model
  attr_reader :simple_id, :entity_id, :enabled
  validates_presence_of :simple_id, :entity_id, :enabled

  def initialize(hash)
    @simple_id = hash['simple_id']
    @entity_id = hash['entity_id']
    @enabled   = hash['enabled']
  end

  def self.from_api(hash)
    new(
      'simple_id' => hash['simpleId'],
      'entity_id' => hash['entityId'],
      'enabled'   => hash['enabled']
    )
  end

  def self.from_session(object)
    return object if object.is_a? Country
    return new(object) if object.is_a? Hash
  end
end
