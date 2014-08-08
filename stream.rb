require 'bundler/setup'


def build_client
  google_api_scope_url = "https://www.googleapis.com/auth/youtube"
  google_secrets = Google::APIClient::ClientSecrets.load(File.expand_path("~/Dropbox/ThePortholeAgency.json"))

  api_client_options = {
    :application_name => "porthole",
    :application_version => "0.0.1"
  }

  client = ::Google::APIClient.new(api_client_options)
  client.authorization = Signet::OAuth2::Client.new({
    :audience => 'https://accounts.google.com/o/oauth2/token',
    :auth_provider_x509_cert_url => 'https://www.googleapis.com/oauth2/v1/certs',
    :client_x509_cert_url => "https://www.googleapis.com/robot/v1/metadata/x509/#{google_client_email}",
    :issuer => google_client_email,
    :scope => google_api_scope_url,
    :signing_key => ::Google::APIClient::KeyUtils.load_from_pkcs12(google_key, 'notasecret'),
    :token_credential_uri => 'https://accounts.google.com/o/oauth2/token',
  })
  client.authorization.fetch_access_token!

  return client
end

def request(client, api_method, parameters, body_object = nil)
  client_parms = {
    :api_method => api_method,
    :parameters => parameters,
  }
  client_parms[:body_object] = body_object if body_object

  result = client.execute(client_parms)

  # Returns an array of body and status code
  return [result.body.nil? || result.body.empty? ? nil : Oj.load(result.body), result.status]
end
