class ChooseACountryController < ApplicationController
  def choose_a_country
    setup_countries
  end

  def choose_a_country_submit
    setup_countries

    country = params[:country]
    if country.empty?
      flash.now[:errors] = true
      render 'choose_a_country'
      return
    end
    redirect_to '/redirect-to-country'
  end

  def redirect_to_country
    'TODO: The country page HERE'
  end

private

  def setup_countries
    if current_countries.nil?
      session_id = session['verify_session_id']
      response = SESSION_PROXY.get_countries(session_id)
      session[:countries] = response.map { |country| Country.from_api(country) }
    end
    @countries = COUNTRY_DISPLAY_DECORATOR.decorate_collection(current_countries)
  end
end
