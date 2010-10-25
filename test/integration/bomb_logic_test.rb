require 'integration_test_helper'


class BombLogicTest < ActionDispatch::IntegrationTest
  fixtures :all

  setup do
    Devise::Oauth.short_circuit_authorizers!
    Devise::Oauth.stub!(:facebook) do |b|
      b.post('/login/oauth/access_token') { [200, {}, ACCESS_TOKEN.to_json] }
      b.post('/api/v2/json/user/show') { [200, {}, FACEBOOK_INFO.to_json] }
    end

  end

  teardown do
    Devise::Oauth.unshort_circuit_authorizers!
    Devise::Oauth.reset_stubs!
  end

  ACCESS_TOKEN = {
    :access_token => "facebooktoken"
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
    assert_difference "User.count", 1 do
      visit '/'
      click_link 'Sign in with Facebook'
    end
    assert page.has_content?('Successfully authorized from Facebook account')
  end
  
end
