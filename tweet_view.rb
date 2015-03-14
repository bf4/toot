class TweetView
  def initialize(tweet, screen)
    @tweet = tweet
    @screen = screen
  end

  def render
    @screen.write_text(0, 0, @tweet.username.rjust(15) + " ")
    @tweet.lines.each_with_index do |line, index|
      @screen.write_text(index, 16, line)
    end
  end
end
