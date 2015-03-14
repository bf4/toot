class User < Struct.new(:username)
  def follow
    Follow.actually_follow(self)
  end
end

PrivateFollowedUser
PublicFollowedUser
PrivateUnfollowedUser
PublicUnfollowedUser

module PrivateUser
  def follow
    Follow.actually_follow(self) if Follow.confirm_follow(self)
  end
end

# Fancy conditional tricks (Perl)
# Ad-hoc polymorphism (Java)
# Pattern Matching (Erlang)
# Subtype Polymorphism (Java, Smalltalk)

class Follow
  def self.follow(user)
    user.follow
  end
end
