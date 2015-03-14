# BF
require "json"
class Database

  def self.default
    new(LevelDB::DB.new("tweets.db"))
  end

  def initialize(engine)
    @engine = engine
  end

  def timeline
    @engine.map { |tid,serialized_details|
      details = deserialize(serialized_details)
      Tweet.new(tid, details["username"], details["text"])
    } || [ Tweet.new(0, "dummy", "dummy tweet")]
  end

  def write_timeline(tweets)
    tweets.each do |tweet|
      @engine.put(tweet.tid, serialize("username".freeze => tweet.username, "text".freeze => tweet.text))
    end
  end


  private

  def serialize(hash)
    JSON.dump(hash)
  end

  def deserialize(serialized_hash)
    JSON.load(serialized_hash)
  end
end
