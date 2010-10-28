require 'test_helper'

class GameControllerTest < ActionController::TestCase
  setup do
    @user = users(:one)
    @bomb = bombs(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
  end

  #test "should drop a bomb" do
  #  assert_difference('Bomb.count') do
  #    post :dropBomb, :lat => 1, :lng => 1
  #  end


end
