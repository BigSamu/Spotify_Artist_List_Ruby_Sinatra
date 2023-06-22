require 'rest-client'
require 'json'
require_relative 'settings'

module Auth
  class Token
    def self.get_access_token
      credentials = load_credentials
      begin
        response = RestClient.post(Settings::SPOTIFY_AUTH_URL, {
          grant_type: 'client_credentials',
          client_id: credentials['client_id'],
          client_secret: credentials['client_secret']
        })

        if response.code == 200
          response_data = JSON.parse(response.body)
          response_data['access_token']
        end

      rescue RestClient::ExceptionWithResponse => e
        # Handle specific RestClient exceptions, if needed
        puts "RestClient Exception: #{e.message}"
        puts "Response body: #{e.response.body}"
        puts "Please reload webapp and try again."
      end
    end

    private

    def self.load_credentials
      credentials_file_path = 'credentials.json'

      if File.exist?(credentials_file_path)
        credentials_file = File.read(credentials_file_path)
        JSON.parse(credentials_file)
      else
        print "Enter your Spotify API client ID: "
        client_id = $stdin.gets.chomp

        print "Enter your Spotify API client secret: "
        client_secret = $stdin.gets.chomp
        {
          'client_id' => client_id,
          'client_secret' => client_secret
        }
      end
    end
  end
end
