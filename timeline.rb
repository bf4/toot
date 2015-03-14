# A list of tweets, newest first
class Timeline
  attr_reader :tweets

  def initialize(tweets)
    @tweets = tweets
  end

  def add(tweets)
    existing_ids = @tweets.map(&:tid).to_set
    new_tweets = tweets.reject { |tweet| existing_ids.include?(tweet.tid) }
    Timeline.new(new_tweets + @tweets)
  end
end
