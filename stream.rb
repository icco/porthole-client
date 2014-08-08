#! /usr/bin/env ruby

require 'bundler/setup'
Bundler.require(:default)

require 'google/api_client'
require 'google/api_client/client_secrets'
require 'google/api_client/auth/installed_app'

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
    :client_id => google_secrets.client_id,
    :client_secret => google_secrets.client_secret,
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
  puts "Valid youtube requests: #{youtube.singleton_methods.inspect}"
  params = {
    :part => "snippet,status",
  }
  body = {
    snippet: {
      title: "Nat Test Broadcast",
      scheduledStartTime: Chronic.parse("in one hour").iso8601
    },
    status: {
      privacyStatus: "unlisted"
    }
  }

  puts "======== INSERT ATTEMPT"
  p request(client, youtube.live_broadcasts.insert, params, body)
end

main
