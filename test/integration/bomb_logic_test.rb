require 'integration_test_helper'


class BombLogicTest < ActionDispatch::IntegrationTest
  fixtures :all

  setup do
    Devise::Oauth.short_circuit_authorizers!
    Devise::Oauth.stub!(:facebook) do |b|
      b.post('/oauth/access_token') { [200, {}, ACCESS_TOKEN.to_json] }
      b.post('https://graph.facebook.com/me?') { [200, {}, FACEBOOK_INFO.to_json] }
    end

  end

  teardown do
    Devise::Oauth.unshort_circuit_authorizers!
    Devise::Oauth.reset_stubs!
  end

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

  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
  test "drop bomb logic" do
    get "/"
    assert_response :success
  end

  test "auth from Facebook" do
    Devise::Oauth.stub!(:facebook) do |b|
      b.post('/oauth/access_token') { [200, {}, ACCESS_TOKEN.to_json] }
      b.get('https://graph.facebook.com/me?') { [200, {}, {}.to_json] }
    end

    #assert_difference "User.count", 1 do
    #visit '/'
    #click_link 'Sign in with Facebook'
    #end
    #puts "fdhsajkfdhslka: #{page.body}"
    #assert page.has_content?('Successfully authorized from Facebook account')
    #puts @user.email
  end
  
end
