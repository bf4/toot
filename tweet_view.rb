class TweetView
  def initialize(tweet, screen)
    @tweet = tweet
    @screen = screen
  end

  def render
    @screen.write_text(0, 0, @tweet.username.rjust(15) + " ")
    @screen.write_text(0, 16, @tweet.text)
  end
end
