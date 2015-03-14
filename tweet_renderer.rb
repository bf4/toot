class TweetRenderer
  def initialize(tweet)
    @tweet = tweet
  end

  def render
    first = [@tweet.username.rjust(15) + " " + @tweet.lines.first]
    rest  = @tweet.lines[1..-1].map do |line|
      " " * 16 + line
    end
    first + rest
  end

end
