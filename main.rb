require 'sinatra'                   # Sinatra framework
require 'sinatra/async'             # Asynchronous support for Sinatra
require 'erb'                       # ERB templating engine
require 'rest-client'               # HTTP client for making API requests
require 'json'                      # JSON parsing and serialization
require 'time'                      # Time-related utilities
require 'rack/cors'                 # Rack middleware for handling CORS
require_relative 'config/settings'  # Import the settings module
require_relative 'config/auth'      # Import the authentication module

class MyApp < Sinatra::Base

  configure do
    set :bind, '0.0.0.0'
    set :port, 8080
    set :root, File.dirname(__FILE__)
    set :public_folder, 'public'
    register Sinatra::Async
  end

  use Rack::Cors do
    allow do
      origins '*'
      resource '*', headers: :any, methods: [:get, :post, :options]
    end
  end


  # Route for printing the access token
  get '/' do
    erb :index
  end

  # Route for getting the artists' information
  aget '/get_artists_list' do
    artists_ids = JSON.parse(File.read('data.json'))
    access_token = Auth::Token.get_access_token

    artists_info = artists_ids.map do |artist_id|
      Fiber.new do
        artist_info = fetch_artist_info(artist_id, access_token)
        Fiber.yield artist_info
      end.resume
    end
    content_type :json
    body artists_info.sort_by{ |artist| artist[:name] }.to_json
  end

  # Helper method to fetch artist information from the API
  def fetch_artist_info(artist_id, access_token)
    url = "#{Settings::SPOTIFY_ARTIST_URL}/#{artist_id}"
    headers = { 'Authorization' => "Bearer #{access_token}" }

    response = RestClient.get(url, headers)
    artist_data = JSON.parse(response.body)
    top_track = get_top_track(artist_id, access_token)

    {
      name: artist_data['name'],
      popularity: artist_data['popularity'],
      top_song: top_track['name'],
      preview_url: top_track['preview_url']
    }
  end

  # Helper method to get the top song for an artist
  def get_top_track(artist_id, access_token)
    url = "#{Settings::SPOTIFY_ARTIST_URL}/#{artist_id}/top-tracks?country=CL"
    headers = { 'Authorization' => "Bearer #{access_token}" }

    response = RestClient.get(url, headers)
    tracks_data = JSON.parse(response.body)
    tracks = tracks_data['tracks']
    return nil if tracks.empty?

    top_track = tracks.sort_by { |track| [-track['popularity'].to_i, track['name']] }
    top_track.first
  end

  # Other routes and code...

  run! if app_file == $PROGRAM_NAME
end
