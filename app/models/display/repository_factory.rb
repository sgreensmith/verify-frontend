module Display
  class RepositoryFactory
    def initialize(translator)
      @translator = translator
    end

    def create_idp_repository(directory)
      create(directory, Display::IdpDisplayData)
    end

    def create_country_repository(directory)
      create(directory, Display::CountryDisplayData)
    end

    def create_rp_repository(directory)
      create(directory, Display::RpDisplayData)
    end

    def create_cycle_three_repository(directory)
      create(directory, Display::CycleThreeDisplayData)
    end

  private

    def create(directory, klass)
      display_data_collection = Dir[File.join(directory, '*.yml').to_s].map do |file|
        klass.new(File.basename(file, '.yml'), @translator)
      end
      display_data_collection.each(&:validate_content!)
      display_data_collection.inject({}) do |hash, data|
        hash[data.simple_id] = data
        hash
      end
    end
  end
end
