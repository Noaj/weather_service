# Class that use SmartyAddress to validate US Address. We can open this more for internationals in the future
class UsZipcodeSingleLookup
  require 'street_address'

  # Method to validate Address
  # Return Status and Zipcode
  def validate_address(address:)

    address = StreetAddress::US.parse(address)

    if address.nil?
      return {status: 'invalid_address', zipcode: nil}
    end  
    id = Rails.configuration.smarty_streets_auth_id
    token = Rails.configuration.smarty_streets_auth_token
    credentials = SmartyStreets::StaticCredentials.new(id, token)

    client = SmartyStreets::ClientBuilder.new(credentials).build_us_zipcode_api_client

    # Documentation for input fields can be found at:
    # https://smartystreets.com/docs/cloud/us-zipcode-api

    lookup = SmartyStreets::USZipcode::Lookup.new
    lookup.city = address.city
    lookup.state = address.state
    lookup.zipcode = address.postal_code

    begin
      client.send_lookup(lookup)
    rescue SmartyStreets::SmartyError => err
      puts err
      return
    end

    {status: lookup.result.status, zipcode: lookup.zipcode}
  end
end
