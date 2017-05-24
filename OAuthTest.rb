# OAuth2 Test Using Twitter API
require 'sinatra'
require 'base64'
require 'httparty'

OAuth_URL = "https://api.twitter.com/oauth2/token"
User_search_URL = "https://api.twitter.com/1.1/users/show.json"

get '/' do

  erb :user_form
end

post '/' do

  username = params[:username]
  joindate = get_join_date username

  erb :response, :locals => {'username' => username, 'joindate' => joindate}
end

def get_join_date username

  # Encode consumer key and secret
  auth = []
  File.open("./.auth", "r") do |f|
    f.each_line do |line|
      auth << line
    end
  end
  key = auth[0].chomp
  secret = auth[1].chomp
  credentials = "#{key}:#{secret}"
  encoded_credentials = Base64.urlsafe_encode64(credentials)

  # Obtain a bearer token
  oauth_response = HTTParty.post(OAuth_URL, :body => {:grant_type => "client_credentials"}, :headers => {"Authorization" => "Basic #{encoded_credentials}", "Content-Type" => "application/x-www-form-urlencoded;charset=UTF-8"})
  bearer_token = oauth_response["access_token"]

  #Authenticate using bearer token
  join_date = HTTParty.get(User_search_URL, :query => {"screen_name" => username}, :headers => {"Authorization" => "Bearer #{bearer_token}"})["created_at"]

  join_date
end
