require 'test_helper'

class Game2ControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
  end

  test "should get getEvents" do
    get :getEvents
    assert_response :success
  end

  test "should get fireEvent" do
    get :fireEvent
    assert_response :success
  end

end
