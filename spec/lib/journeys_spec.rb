require 'rspec'
require 'journeys'

describe 'Journeys' do
  it 'should raise an error when the route does not exist' do
    expect {
      Journeys.new([]) do
        at :non_existent_route, {}
      end
    }.to raise_error('Route non_existent_route does not exist')
  end

  it 'should raise an error when one of the next routes does not exist' do
    expect {
      Journeys.new([:existing_route_url]) do
        at :existing_route, [] => :non_existent_route
      end
    }.to raise_error('Route non_existent_route does not exist')
  end

  it 'should return the next route' do
    journeys = Journeys.new([:a_page_url, :another_page_url]) do
      at :a_page, [] => :another_page
    end
    expect(journeys.next(:a_page, Set.new)).to eql(:another_page)
  end

  it 'should return the next route matching conditional containing subset of session' do
    journeys = Journeys.new([:a_page_url, :another_page_url, :default_page_url]) do
      at :a_page,
         [:some_condition, :another_condition] => :another_page,
         [] => :default_page
    end
    expect(journeys.next(:a_page, Set.new([:some_condition, :another_condition, :third_condition]))).to eql(:another_page)
  end

  it 'should return the next route matching first acceptable conditional' do
    journeys = Journeys.new([:a_page_url, :another_page_url, :pie_page_url, :default_page_url]) do
      at :a_page,
         [:some_condition, :another_condition] => :another_page,
         [:some_condition, :another_condition, :loves_pie] => :pie_page,
         [] => :default_page
    end
    expect(journeys.next(:a_page, Set.new([:some_condition, :another_condition, :loves_pie]))).to eql(:another_page)
  end
end
