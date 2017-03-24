require 'rails_helper'

RSpec.describe Country do
  it 'is valid when simple_id and entity_id are provided' do
    country = Country.new('entity_id' => 'entityId1', 'simple_id' => 'simpleId1', 'enabled' => 'enabled')
    expect(country).to be_valid
  end

  it 'should load from session' do
    country = Country.from_session('entity_id' => 'entityId1', 'simple_id' => 'simpleId1', 'enabled' => 'enabled')
    expect(country.simple_id).to eql 'simpleId1'
    expect(country.entity_id).to eql 'entityId1'
  end

  it 'should load from session' do
    provider = Country.new('entity_id' => 'entityId1', 'simple_id' => 'simpleId1', 'enabled' => 'enabled')
    country = Country.from_session(provider)
    expect(country).to eql provider
  end
end
