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
  google_secrets = Google::APIClient::ClientSecrets.load(File.expand_path("~/ThePortholeAgency.json"))

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

# Example response: {"kind"=>"youtube#liveBroadcast",
# "etag"=>"\"gMjDJfS6nsym0T-NKCXALC_u_rM/8HKEGQDcNVgV0oNpG7Jl4TXPDKk\"",
# "id"=>"nkSj0Aw6yrU",
# "snippet"=>{"publishedAt"=>"2014-08-08T14:14:43.000Z",
# "channelId"=>"UCh4CJdC3mXyimvshLxNuFDg",
# "title"=>"Nat Test Broadcast",
# "description"=>"",
# "thumbnails"=>{"default"=>{"url"=>"https://yt3.ggpht.com/-gmxpk_n-oJE/AAAAAAAAAAI/AAAAAAAAAAA/ZxZoWM_nzdA/s120-c-k-no/photo.jpg",
# "width"=>120,
# "height"=>90},
# "medium"=>{"url"=>"https://yt3.ggpht.com/-gmxpk_n-oJE/AAAAAAAAAAI/AAAAAAAAAAA/ZxZoWM_nzdA/s480-c-k-no/photo.jpg",
# "width"=>320,
# "height"=>180},
# "high"=>{"url"=>"https://yt3.ggpht.com/-gmxpk_n-oJE/AAAAAAAAAAI/AAAAAAAAAAA/ZxZoWM_nzdA/s480-c-k-no/photo.jpg",
# "width"=>480,
# "height"=>360}},
# "scheduledStartTime"=>"2014-08-08T15:14:43.000Z"},
# "status"=>{"lifeCycleStatus"=>"created",
# "privacyStatus"=>"unlisted",
# "recordingStatus"=>"notRecording"}}
def build_event client, youtube
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
  response, code = request(client, youtube.live_broadcasts.insert, params, body)
  if code == 200
    return response
  else
    p code
    p response
    return nil
  end
end

# Example response: {"kind"=>"youtube#liveStream",
# "etag"=>"\"gMjDJfS6nsym0T-NKCXALC_u_rM/H7Qp4YfqRZKgl0KjCz8sKhebKxg\"",
# "id"=>"h4CJdC3mXyimvshLxNuFDg1407508700253501",
# "snippet"=>{"publishedAt"=>"2014-08-08T14:38:20.000Z",
# "channelId"=>"UCh4CJdC3mXyimvshLxNuFDg",
# "title"=>"Nat Test Broadcast Stream",
# "description"=>""},
# "cdn"=>{"format"=>"1080p",
# "ingestionType"=>"rtmp",
# "ingestionInfo"=>{"streamName"=>"nat.tgbd-jpm5-rehs-6q70",
# "ingestionAddress"=>"rtmp://a.rtmp.youtube.com/live2",
# "backupIngestionAddress"=>"rtmp://b.rtmp.youtube.com/live2?backup=1"}}}
def build_stream client, youtube
  params = {
    :part => "snippet,cdn",
  }
  body = {
    snippet: {
      title: "Nat Test Broadcast Stream",
    },
    cdn: {
      format: "1080p",
      ingestionType: "rtmp",
    }
  }

  puts "======== INSERT ATTEMPT"
  response, code = request(client, youtube.live_streams.insert, params, body)
  if code == 200
    return response
  else
    p code
    p response
    return nil
  end
end

def main
  client, youtube = build_client
  puts "Valid youtube requests: #{youtube.singleton_methods.inspect}"

  broadcast_response = build_event client, youtube
  puts "Broadcast ID: #{broadcast_response["id"]}"

  stream_response = build_stream client, youtube
  url = "#{stream_response["cdn"]["ingestionInfo"]["ingestionAddress"]}/#{stream_response["cdn"]["ingestionInfo"]["streamName"]}"
  puts "Stream ID: #{stream_response["id"]}"
  puts "Stream URL: #{url}"
  puts "Command: sudo mencoder tv:// -tv device=/dev/video0:fps=8:width=1920:height=1080 -nosound -lavcopts vcodec=flv:vbitrate=4500:keyint=40 -ovc lavc -o #{url}"
  puts "https://www.youtube.com/my_live_events"
end

main
