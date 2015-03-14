require_relative "text"

# Replaced TweetView
class TweetRenderer
  module Colorize
    def self.tweet_text(line)
      Text[:default, line]
    end
  end
  USERNAME_GUTTER = 17

  def initialize(tweets, selected_tweet, screen_height)
    @tweets = tweets
    @selected_tweet = selected_tweet
    @screen_height = screen_height
  end

  def render
    fill_to_screen(clamp_to_screen(lines_for_tweets))
  end

  def lines_for_tweets
    @tweets.flat_map do |tweet|
      text_for_tweet(tweet)
    end
  end

  def clamp_to_screen(lines)
    lines[0, @screen_height]
  end

  def fill_to_screen(lines)
    remaining_rows = @screen_height - lines.count
    blank_lines = [Text[:default]] * remaining_rows
    lines + blank_lines
  end

  def text_for_tweet(tweet)
    username_text = Text[:green,
                         tweet.username.rjust(USERNAME_GUTTER - 1),
                         " "]

    lines = tweet.lines.each_with_index.map do |line, index|
      first = (index == 0)
      left_gutter = first ? username_text : Text[" " * USERNAME_GUTTER]
      text = Colorize.tweet_text(line)
      left_gutter + text
    end

    if tweet == @selected_tweet
      lines = lines.map { |line| Text[:highlight] + line }
    end

    lines
  end
end
