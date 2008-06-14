require File.dirname(__FILE__) + '/../test_helper'

class LaunchPermissionTest < Test::Unit::TestCase
  fixtures :launch_permissions

  def test_may_view

    lp1 = launch_permissions(:lp1)

    assert LaunchPermission.may_view(lp1.url)
    assert LaunchPermission.may_view("public"+lp1.url)
    assert (not LaunchPermission.may_view('http://whatever'))
  end
end
