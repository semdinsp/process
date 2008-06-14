require File.dirname(__FILE__) + '/../test_helper'
require 'eadmin_controller'

# Re-raise errors caught by the controller.
class EadminController; def rescue_action(e) raise e end; end

class EadminControllerTest < Test::Unit::TestCase
  def setup
    @controller = EadminController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
