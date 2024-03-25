class WeatherApi
    include HTTParty
    require 'street_address'
    
    # API initialization with an Address. 
    # Return a build URL ready to query VisualCrossing
    def initialize(address)
        # Dates used for 5 days forescast
        start_date = DateTime.now.strftime("%Y-%m-%d")
        end_date = 5.days.from_now.strftime("%Y-%m-%d")
        # Getting the crossing api credentials
        visualcrossing_url = Rails.configuration.visualcrossing_api_url
        visualcrossing_key = Rails.configuration.visualcrossing_api_key
        @address = address
        parse_address = StreetAddress::US.parse(address)
        
        # If while parsing the addres, there is a mistake/wrong address field, return nil
        if parse_address.nil?
            return nil
        end

        @url = visualcrossing_url + "#{parse_address.city}/#{parse_address.state}/#{parse_address.postal_code}" + "/#{start_date}/#{end_date}?key=" + visualcrossing_key
    end

    # Endpoint that returns a response and a boolean if the data is coming from cache.
    # Note: If the Address is not valid, the response will be nil.
    def weather_by_address
        cache_forecast_data = true
        is_address_valid = address_validation(address: @address)
        
        if is_address_valid[:status].nil?
            forecast = $redis.get(is_address_valid[:zipcode]) rescue nil
  
            if forecast.nil?
                cache_forecast_data = false
                forecast = HTTParty.get(@url)
                $redis.set(is_address_valid[:zipcode], forecast)
                $redis.expire(is_address_valid[:zipcode], 1800.seconds.to_i)
            else
                forecast = JSON.parse(forecast)
            end

            response =  { forecast: forecast, cache_data: cache_forecast_data }
        else
            response =  { forecast: nil, cache_data: false }
        end
    end

    # Address validation: We use SmartyStreets to validate Address. It will return a Status and a Zipcode.
    # Status: If its nil, means that the Address is valid, otherwise, somethig is wrong with the address.
    # Zipcode: Contain teh Zipcode
    def address_validation(address:)
        verifier = UsZipcodeSingleLookup.new
        response = verifier.validate_address(address: address)
        response
    end    
end
