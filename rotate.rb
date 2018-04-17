require 'sinatra'
require 'httparty'
require 'dotenv'
require 'nokogiri'

Dotenv.load

class Rotate < Sinatra::Base
  attr_reader :tokens
  
  GFYCAT_API_KEY             = ENV['GFYCAT_API_KEY']
  GFYCAT_API_SECRET          = ENV['GFYCAT_API_SECRET']
  GFYCAT_USERNAME            = ENV['GFYCAT_USERNAME']
  GFYCAT_PASSWORD            = ENV['GFYCAT_PASSWORD']
  GFYCAT_BASE_URL            = ENV['GFYCAT_BASE_URL']
  XBOX_GAMERTAG              = ENV['XBOX_GAMERTAG']
  XBOX_DVR_BASE_URL          = ENV['XBOX_DVR_BASE_URL']
  XBOX_ROCKETLEAGUE_TITLE_ID = ENV['XBOX_ROCKETLEAGUE_TITLE_ID']

  def initialize
    @tokens = {}
    super
  end


  get '/' do
    get_xbox_clips
  end

  get '/scrape' do
    scrape_xbox_dvr_clips
  end

  get '/auth-gfycat' do
    get_gfycat_access_token
  end

  get '/auth-xbox' do
    get_xbox_access_token
  end

  helpers do

    def get_xbox_clips
      # TODO Fetch xbox clips from api
    end
    
    def scrape_xbox_dvr_clips
      doc = Nokogiri::HTML(HTTParty.get("#{XBOX_DVR_BASE_URL}/gamer/#{XBOX_GAMERTAG}/videos/#{XBOX_ROCKETLEAGUE_TITLE_ID}"))
      doc.css('.vid-card').each do |card|
        if within_date params[:days_ago], card.css('.extra-row').css('time').text, "%m/%d/%Y"
          card.css('.content-row').each do |clip|
            clip.css('a').each do |link|
              post_gif "#{XBOX_DVR_BASE_URL}#{link['href']}"
            end
          end
        end
      end
    end

    def post_gif source_url
      headers = {
        "Authorization" => "Bearer #{@tokens[:gfycat]}",
        "Content-Type"  => "application/json"
      }
      
      payload = {
        fetchUrl: source_url,
        tags: ["#{XBOX_GAMERTAG}", "RocketLeague"]
      }

      response = HTTParty.post "#{GFYCAT_BASE_URL}/gfycats", headers: headers, body: payload.to_json
      
      if response.code == 200
        return [200, "Successfully Uploaded."]
      else
        return [500, "Error."]
      end
    end

    def get_gfycat_access_token
      payload = {
        grant_type: "password",
        client_id:  GFYCAT_API_KEY,
        client_secret: GFYCAT_API_SECRET,
        username: GFYCAT_USERNAME,
        password: GFYCAT_PASSWORD
      }

      response = HTTParty.post "#{GFYCAT_BASE_URL}/oauth/token", body: payload.to_json

      if response.code == 200
        @tokens[:gfycat] = response['access_token']
        return [200, "Successfully Authenticated."]
      else
        return [500, "Error."]
      end
    end

    def within_date days_ago, date, format
      Date.today - days_ago.to_i <= Date.strptime(date, "%m/%d/%Y")
    end

  end

end

run Rotate.run!