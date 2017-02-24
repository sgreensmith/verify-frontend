require 'set'

class Journeys
  def initialize(url_helper_methods, &blk)
    @url_helper_methods = url_helper_methods
    @journeys = {}
    instance_eval(&blk)
  end

  def at(route, cases)
    ([route] + cases.values).map { |r| validate_route(r) }
    @journeys[route] = cases.map { |k, v| [Set.new(k), v] }.to_h
  end

  def next(route, session)
    # Check for first case array which is a subset of user session array
    matching_case = @journeys[route].keys.select { |key| key.subset?(session) }.first
    @journeys[route][matching_case]
  end

private

  def validate_route(route)
    unless @url_helper_methods.include?("#{route}_url".to_sym)
      raise "Route #{route} does not exist"
    end
  end
end
