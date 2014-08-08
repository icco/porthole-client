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
  google_secrets = Oj.load(File.read(File.expand_path("~/Dropbox/ThePortholeAgency.json")))
  google_secrets["p12_key"] = File.expand_path("~/Dropbox/ThePortholeAgency.p12")

  api_client_options = {
    :application_name => "porthole",
    :application_version => "0.0.1"
  }

  client = Google::APIClient.new(api_client_options)
  client.authorization = Signet::OAuth2::Client.new({
    :audience => 'https://accounts.google.com/o/oauth2/token',
    :auth_provider_x509_cert_url => 'https://www.googleapis.com/oauth2/v1/certs',
    :client_x509_cert_url => "https://www.googleapis.com/robot/v1/metadata/x509/#{google_secrets["client_email"]}",
    :issuer => google_secrets["client_email"],
    :scope => google_api_scopes,
    :signing_key => ::Google::APIClient::KeyUtils.load_from_pkcs12(google_secrets["p12_key"], 'notasecret'),
    :token_credential_uri => 'https://accounts.google.com/o/oauth2/token',
  })
  client.authorization.fetch_access_token!
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

  puts "======== INSERT ATTEMPT"
  p request(client, youtube.live_broadcasts.insert, params)
end

main
