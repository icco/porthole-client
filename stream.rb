#! /usr/bin/env ruby

require 'bundler/setup'
Bundler.require(:default)

require 'google/api_client'
require 'google/api_client/client_secrets'

YOUTUBE_READ_WRITE_SCOPE = "https://www.googleapis.com/auth/youtube"
YOUTUBE_API_SERVICE_NAME = "youtube"
YOUTUBE_API_VERSION = "v3"

def build_client
  google_api_scopes = [YOUTUBE_READ_WRITE_SCOPE]
  google_secrets = Google::APIClient::ClientSecrets.load(File.expand_path("~/Dropbox/ThePortholeAgency.json"))

  api_client_options = {
    :application_name => "porthole",
    :application_version => "0.0.1"
  }

  client = Google::APIClient.new(api_client_options)
  flow = Google::APIClient::InstalledAppFlow.new(
    :client_id => client_secrets.client_id,
    :client_secret => client_secrets.client_secret,
    :scope => google_api_scopes
  )
  client.authorization = flow.authorize
  youtube = client.discovered_api(YOUTUBE_API_SERVICE_NAME, YOUTUBE_API_VERSION)

  return [client, youtube]
end

def request(client, api_method, parameters = {}, body_object = nil)
  client_parms = {
    :api_method => api_method,
    :parameters => parameters,
  }
  client_parms[:body_object] = body_object if body_object

  result = client.execute(client_parms)

  # Returns an array of body and status code
  return [result.body.nil? || result.body.empty? ? nil : Oj.load(result.body), result.status]
end

def main
  client, youtube = build_client
  p youtube

  puts "======== INSERT"
  p request(client, youtube.livebroadcast.insert)
end

main
