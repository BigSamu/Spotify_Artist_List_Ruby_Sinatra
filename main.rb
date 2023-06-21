require "sinatra"
require "sinatra/async"
require "erb"
require "rest-client"
require "json"
require "time"
require 'rack/cors'

# Config and Settings
set :public_folder, File.dirname(__FILE__)
URL_PREFIX = 'https://www.buda.com/api/v2'

configure do
  register Sinatra::Async
end

use Rack::Cors do
  allow do
    origins '*'
    resource '*', headers: :any, methods: [:get, :post, :options]
  end
end

# Routes
get '/' do
  erb :index
end

aget '/max_transactions' do
  Fiber.new do
    maxTransactions = [];
    markets = get_markets()
    markets.each do |eachMarket|
      timestamp_24hrs_ago = get_timestamp_24hrs_ago()
      tradesForMarket = get_trades_for_market(
        eachMarket["id"],
        timestamp_24hrs_ago
      )

      tradeEntriesForMarket = tradesForMarket["entries"]

      maxTransactionOfMarket = {
        "market"=> tradesForMarket["market_id"],
        "amount"=> 0,
        "price"=> 0,
        "maxTransaction"=> 0,
        "timestamp"=> 0,
        "direction"=> '',
        };

        tradeEntriesForMarket.each do |entry|
          transaction = (entry[1].to_f*entry[2].to_f).round(2) # amount*price
          # puts transaction
          if(transaction>maxTransactionOfMarket["maxTransaction"])
            maxTransactionOfMarket["maxTransaction"] = transaction
            maxTransactionOfMarket["timestamp"] = entry[0]
            maxTransactionOfMarket["amount"] = entry[1].to_f.round(2)
            maxTransactionOfMarket["price"] = entry[2].to_f.round(2)
            maxTransactionOfMarket["direction"] = entry[3]
          end

        end
        maxTransactions.push(maxTransactionOfMarket);
      end
      content_type :json
      body maxTransactions.to_json
    end.resume

  end

  def get_markets()
    response = RestClient.get("#{URL_PREFIX}/markets")
    response_parsed = JSON.parse(response.body)
    markets = response_parsed["markets"]
    return markets
  end

  def get_trades_for_market(market_id,timestamp)
    response = RestClient.get("#{URL_PREFIX}/markets/#{market_id}/trades?timestamp=#{timestamp}")
    response_parsed = JSON.parse(response.body)
    trades = response_parsed["trades"]
    return trades
  end

  def get_timestamp_24hrs_ago()
    return (Time.now.to_i   - 24 * 60 * 60)*1000;
  end
