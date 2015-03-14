class User < Struct.new(:username, :private)
  alias_method :private?, :private
end

class Follow
  def self.follow(user)
    if user.private?
      actually_follow(user) if confirm_follow(user)
    else
      actually_follow(user)
    end
  end
end
