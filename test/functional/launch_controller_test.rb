require File.dirname(__FILE__) + '/../test_helper'
require 'launch_controller'

# Re-raise errors caught by the controller.
class LaunchController; def rescue_action(e) raise e end; end

class LaunchControllerTest < Test::Unit::TestCase

  #fixtures :users

  def setup

    @controller = LaunchController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_nada
    assert true
  end
end
