
require File.dirname(__FILE__) + '/../test_helper'

class GroupTest < Test::Unit::TestCase

  fixtures :users, :groups

  def test_implicit_group

    u = User.new
    u.name = "nemo"
    
    l = Group.find_groups(u)
    assert_equal l, [ "user_nemo" ]
  end

  def test_alice

    assert_equal Group.find_groups(users(:alice)), [ "sales", "user_alice" ]
  end
end
