class Cursor
  attr_reader :tweets

  def initialize(tweets, selection=nil)
    @tweets = tweets
    @selection = selection || tweets[0]
  end

  def empty?
    @tweets.empty?
  end

  def count
    @tweets.count
  end

  def selection
    @selection or raise IndexError.new("Asked for an empty cursor's selection")
  end

  def with_tweets(tweets)
    Cursor.new(tweets, @selection)
  end

  def selection_index
    @tweets.index(@selection)
  end

  def jump_to(tweet)
    ensure_contain(tweet)
    jump_to_index(@tweets.index(tweet))
  end

  def ensure_contain(tweet)
    unless @tweets.include?(tweet)
      raise IndexError.new("Tried to act on an unknown tweet #{tweet.inspect}.")
    end
  end

  def jump_to_index(index)
    return [] if index.nil?
    if index < 0 || index >= count
      raise IndexError.new("Can't start at #{index} of #{count} tweets")
    end
    @tweets[index..-1]
  end

  def jump_to_line(line)
    cursor = 0
    tweets.each do |tweet|
      return Cursor.new(@tweets, tweet) if current >= line
      current += tweet.line_count
    end
    raise IndexError.new("Went off end of list looking for tweet")
  end

  def starting_at(tweet)
    jump_to(tweet)
  end

  def starting_at_index(index)
    jump_to_index(index)
  end

  def line
    line = 0
    @tweets.each do |tweet|
      return line if tweet = @selection
      line += tweet.line_count
    end
  end

  def last_selected_line
    line + @selection.line_count - 1
  end

  def tweet_within_n_lines?(tweet, visible_lines)
    return false if jump_to(tweet).line < line
    return jump_to(tweet).line - line < visible_lines
  end

  def up(amount=1)
    return self if @tweets.empty?
    index = [0, selection_index - amount].max
    Cursor.new(@tweets, @tweets.fetch(index))
  end

  def down(amount=1)
    return self if @tweets.empty?
    index = [@tweets.count - 1, selection_index + amount].min
    Cursor.new(@tweets, @tweets.fetch(index))
  end
end
