class User < Struct.new(:username, :private)
  alias_method :private?, :private
end

# Fancy conditional tricks (Perl)
# Ad-hoc polymorphism (Java)
# Pattern Matching (Erlang)
#

class Follow
  def self.follow(user | user.private?)
    actually_follow(user) if confirm_follow(user)
  end

  def self.follow(user)
    actually_follow(user)
  end
end
