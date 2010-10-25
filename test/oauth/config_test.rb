require 'test_helper'

class OauthConfigTest < ActiveSupport::TestCase
  ACCESS_TOKEN = {
    :access_token => "plato"
  }
  FACEBOOK_INFO = {
    :user => {
      :name  => 'Peter Schlichting2',
      :email => 'pjschlic2@gmail.com',
      :id => 1924170
    }
  }



  setup { @config = Devise.oauth_configs[:facebook] }
  teardown { Devise::Oauth.reset_stubs! }

  test "stored OAuth2::Client" do
    assert_kind_of OAuth2::Client, @config.client
  end

  test "build authorize url" do
    url = @config.authorize_url(:redirect_uri => "foo")
    assert_match "https://graph.facebook.com/oauth/authorize?", url
    assert_match "scope=email", url
    assert_match "client_id=", url
    assert_match "type=web_server", url
    assert_match "redirect_uri=foo", url
  end

  test "retrieves access token object by code" do
    Devise::Oauth.stub!(:facebook) do |b|
      b.post('/oauth/access_token') { [200, {}, ACCESS_TOKEN.to_json] }
      b.get('/me?access_token=plato') { [200, {}, {}.to_json] }
    end

    access_token = @config.access_token_by_code("12345")
    assert_kind_of OAuth2::AccessToken, access_token
    assert_equal "{}", access_token.get("/me")
  end

  test "retrieves access token object by token" do
    Devise::Oauth.stub!(:facebook) do |b|
      b.get('/me?access_token=plato') { [200, {}, {}.to_json] }
    end

    access_token = @config.access_token_by_token("plato")
    assert_kind_of OAuth2::AccessToken, access_token
    assert_equal "{}", access_token.get("/me")
  end
end
