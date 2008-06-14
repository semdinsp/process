
require File.dirname(__FILE__) + '/../test_helper'
require 'wadmin_controller'

# Re-raise errors caught by the controller.
class WadminController; def rescue_action(e) raise e end; end

class WadminControllerTest < Test::Unit::TestCase
  def setup
    @controller = WadminController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
