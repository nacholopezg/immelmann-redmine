require File.expand_path('../../test_helper', __FILE__)

class UserTest < ActiveSupport::TestCase
  fixtures :users

  def user
    users(:users_001)
  end

  def test_user_voter
    assert User.voter?, "User must be a voter, but it isn't it"
  end
end