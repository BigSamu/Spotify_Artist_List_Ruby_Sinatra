require 'json'                      # JSON parsing and serialization

# Config and Settings
module Settings

  credentials_file = File.read('credentials.json')
  credentials = JSON.parse(credentials_file)

  CLIENT_ID = credentials['client_id']
  CLIENT_SECRET = credentials['client_secret']
  SPOTIFY_AUTH_URL = 'https://accounts.spotify.com/api/token'
  SPOTIFY_ARTIST_URL = 'https://api.spotify.com/v1/artists'

  # Other configuration constants...
end
