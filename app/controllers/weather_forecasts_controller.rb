class WeatherForecastsController < ApplicationController
    # Home page: Show the form with an input for an address to query the weather forecast 
    def index  
    end

    # Endpoint to query the weather data
    def weather_by_zipcode
        api = WeatherApi.new(params['address'])
        if api.nil?
            redirect_to '/', allow_other_host: false, notice: "Invalit Address: Please add a valid address. address formatting: 1111 999nd St Cool City, NY 99999 ", status: 302
        end

        response = api.weather_by_address
        if response[:forecast].nil?
            redirect_to '/', allow_other_host: false, notice: "Invalit Address: Please add a valid address. address formatting: 1111 999nd St Cool City, NY 99999 ", status: 302
        end

        @weather = response[:forecast]
        @cache_data = response[:cache_data]

        # This are icons data name, since its coming from the API, Rails doesn;t have it internaly, so we mapped the Rails and the VisualCrossing
        @weather_icons = {"snow"=>"fa-snowflake", "rain" => "fa-cloud-rain", "fog"=> "fa-smog", "wind" =>"fa-wind", 
        "cloudy" => "fa-cloud", "partly-cloudy-day" => "fa-cloud-sun", "partly-cloudy-night" => "fa-cloud-moon",
        "clear-day" => "fa-sun", "clear-night" => "fa-moon"}

        respond_to do |format|
            format.html
            format.json { render json: { weather: @weather, cache_data:@cache_data, weather_icons: @weather_icons}, status: :ok }
        end
    end
end
