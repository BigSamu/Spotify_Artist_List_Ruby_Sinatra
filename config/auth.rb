require 'rest-client'               # HTTP client for making API requests
require 'json'                      # JSON parsing and serialization
require_relative 'settings'         # Import the settings module

module Auth
  class Token
    def self.get_access_token
      response = RestClient.post(Settings::SPOTIFY_AUTH_URL, {
        grant_type: 'client_credentials',
        client_id: Settings::CLIENT_ID,
        client_secret: Settings::CLIENT_SECRET
      })

      if response.code == 200
        response_data = JSON.parse(response.body)
        response_data['access_token']
      else
        # Handle the case when obtaining the access token fails
        nil
      end
    end
  end
end
