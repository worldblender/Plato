require 'test_helper'

class BombsControllerTest < ActionController::TestCase
  setup do
    @bomb = bombs(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:bombs)
  end

  test "should show bomb" do
    get :show, :id => @bomb.to_param
    assert_response :success
  end
end
