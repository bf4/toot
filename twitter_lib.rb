require "dotenv"
Dotenv.load


require "delegate"
class TwitterLib
  Twitter = ::Twitter

  CLIENTS = {
    :rest => Twitter::REST::Client,
    :stream => Twitter::Streaming::Client,
  }

  class TimelineQueue < SimpleDelegator
    attr_writer :max_items


    def max_items
      @max_items or self.max_items = 100
    end

    def prepend(tweet)
      pop if size > max_items
      unshift tweet
    end


    def append(tweet)
      shift if size > max_items
      push tweet
    end
  end

  attr_reader :client

  def initialize(client_type=:rest)
    @client_type = client_type
    @client = new_client(@client_type)
  end

  def self.authenticate
    @authenticated_lib ||= new(:stream)
  end

  def self.authenticated_client
    authenticate.client
  end

  def self.update(text)
    authenticated_client.update(text)
  end

  def self.timeline_tweets
    @timeline_queue ||=
      begin
        timeline_queue = TimelineQueue.new([])
        Thread.new { authenticate.timeline_tweets(timeline_queue) }
        timeline_queue
      end
    @timeline_queue.to_a
  end

  # REST
  # https://github.com/sferik/twitter/blob/master/lib/twitter/rest/favorites.rb
  # https://github.com/sferik/twitter/blob/master/lib/twitter/rest/undocumented.rb
  # https://github.com/sferik/twitter/wiki/apps

  # http://rdoc.info/gems/twitter/Twitter/REST/Timelines#user_timeline-instance_method
  # Options Hash (options):
  #   :since_id (Integer) — Returns results with an ID greater than (that is, more recent than) the specified ID.
  #   :max_id (Integer) — Returns results with an ID less than (that is, older than) or equal to the specified ID.
  #   :count (Integer) — Specifies the number of records to retrieve. Must be less than or equal to 200.
  #   :trim_user (Boolean, String, Integer) — Each tweet returned in a timeline will include a user object with only the author's numerical ID when set to true, 't' or 1.
  #   :exclude_replies (Boolean, String, Integer) — This parameter will prevent replies from appearing in the returned timeline. Using exclude_replies with the count parameter will mean you will receive up-to count tweets - this is because the count parameter retrieves that many tweets before filtering out retweets and replies.
  #   :contributor_details (Boolean, String, Integer) — Specifies that the contributors element should be enhanced to include the screen_name of the contributor.
  #   :include_rts (Boolean, String, Integer) — Specifies that the timeline should include native retweets in addition to regular tweets. Note: If you're using the trim_user parameter in conjunction with include_rts, the retweets will no longer contain a full user object.
  def timeline_tweets(timeline_queue)
    handle_errors do
      _timeline_tweets(timeline_queue)
    end
  end

  def _timeline_tweets(timeline_queue)
    if :rest == @client_type
      options = {
        :count => timeline_queue.max_items,
      }
      newest_tweet = timeline_queue.last
      newest_id = newest_tweet && newest_tweet.tid
      options.update(
        :since_id => newest_id,
      ) if newest_id
      client.home_timeline(options).each do |tweet_entity|
        next if tweet_entity.is_a?(Twitter::NullObject)
        timeline_queue.append tweet_entity_to_tweet(tweet_entity)
      end
    else
      client.user do |object|
        case object
        when Twitter::Tweet
          timeline_queue.append tweet_entity_to_tweet(object)
        when Twitter::DirectMessage
        when Twitter::Streaming::DeletedTweet
        when Twitter::Streaming::Event
        when Twitter::Streaming::FriendList
        when Twitter::Streaming::StallWarning
        else
          # unknown object
        end
      end
      timeline_queue
    end
  end

  # http://rdoc.info/gems/twitter/Twitter/Tweet
  # class TweetEntity
  #   :id
  #   :uri, :full_text, :favorited?
  #   :in_reply_to_tweet_id
  #   :in_reply_to_user_id
  #   :in_reply_to_screen_name
  #   :lang
  #   :retweet_count
  #   :retweeted?
  #   :created_at
  #   :uris
  #   :hashtags
  #   :attrs
  #   :user.id/name
  # end
  URI_REGEX = URI::Parser.new.make_regexp(['http', 'https'])
  def tweet_entity_to_tweet(tweet_entity)
    # procedure to replace short urls in tweets with original url
    full_text = tweet_entity.full_text
    full_text_urls = tweet_entity.attrs[:entities][:urls]
    full_text_expanded_urls_mapping =  Hash[full_text_urls.map{|m| m.values_at(:url, :expanded_url)}]
    full_text = full_text.gsub(URI_REGEX, full_text_expanded_urls_mapping)

    Tweet.new(tweet_entity.id, tweet_entity.user.screen_name, full_text)
  end

  # TODO: handle api failures more gracefully
  def handle_errors(tries = 3, &block)
    block.call
  rescue Twitter::Error, EOFError
    tries -= 1
    retry if tries > 0
    message = %w(class message backtrace).map{|arg| "#{arg}: #{$!.public_send(arg)}"}.join(", ")
    STDERR.puts "[#{Time.now.iso8601}] #{message}"
    raise
  end

  private

  def new_client(client_type)
    CLIENTS.fetch(client_type).new do |config|
      config.consumer_key        = ENV["TWITTER_CONSUMER_KEY"]
      config.consumer_secret     = ENV["TWITTER_CONSUMER_SECRET"]
      config.access_token        = ENV["TWITTER_ACCESS_TOKEN"]
      config.access_token_secret = ENV["TWITTER_ACCESS_SECRET"]
    end
  end
end
