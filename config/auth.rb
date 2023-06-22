module Auth
  class Token
    def self.get_access_token
      if Settings::CLIENT_ID.nil? || Settings::CLIENT_SECRET.nil?
        prompt_user_for_credentials()
      end

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

    private

    def self.prompt_user_for_credentials
      print "Enter your Spotify API client ID: "
      client_id = $stdin.gets.chomp

      print "Enter your Spotify API client secret: "
      client_secret = $stdin.gets.chomp

      Settings.module_eval do
        remove_const('CLIENT_ID') if defined?(CLIENT_ID)
        remove_const('CLIENT_SECRET') if defined?(CLIENT_SECRET)

        const_set('CLIENT_ID', client_id)
        const_set('CLIENT_SECRET', client_secret)
      end
    end
  end
end
