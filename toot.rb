require "cgi"
require "tempfile"
require "thread"
require "io/console"
require "values"
require "twitter"
require "leveldb"

require_relative "screen"
require_relative "cursor"
require_relative "tweet"
require_relative "database"
require_relative "timeline"
require_relative "twitter_lib"
require_relative "selectable_queue"
require_relative "tweet_renderer"

class World < Value.new(:timeline)
end

class Toot
  def initialize(screen)
    @screen = screen
  end

  def run
    TwitterLib.authenticate

    database = Database.default
    timeline = Timeline.new(database.timeline)
    timeline_queue = SelectableQueue.new
    start_timeline_stream(timeline, timeline_queue)
    world = World.new(timeline)

    view = TimelineView.new(@screen)

    EventLoop.new(database, world, timeline_queue, view).run
  end

  # hits the network
  def start_timeline_stream(timeline, timeline_queue)
    timeline_stream = TimelineStream.new(timeline, timeline_queue)
    Thread.new { timeline_stream.run }
  end

  class EventLoop
    def initialize(database, world, timeline_queue, view)
      @database = database
      @world = world
      @timeline_queue = timeline_queue
      @view = view
    end

    def run
      loop do
        @view.display(@world)
        read, _, _ = select([$stdin, @timeline_queue], nil, nil)
        handle_stdin if read.include?($stdin)
        handle_timeline if read.include?(@timeline_queue)
      end
    end

    def handle_stdin
      @view.key($stdin.getc)
    end

    def handle_timeline
      timeline = @timeline_queue.pop
      @database.write_timeline(timeline.tweets)
      @world = World.new(timeline)
    end
  end
end

class TimelineStream
  def initialize(timeline, queue)
    @timeline = timeline
    @queue = queue
  end

  def run
    loop do
      @timeline = @timeline.add(TwitterLib.timeline_tweets)
      @queue << @timeline
      sleep(10)
    end
  end
end

module View
  def height
    @screen.usable_height
  end
end

class TimelineView
  include View

  def initialize(screen)
    @screen = screen
    @cursor = Cursor.new([])
  end

  def display(world)
    tweets = world.timeline.tweets
    @cursor = @cursor.with_tweets(tweets)
    draw_tweets
    @screen.status("#{tweets.count} toots", "q=Quit")
  end


  def draw_tweets
    # row = 0
    # leftover from when replacing tweet view with tweet renderer 
    # def draw_tweets
    #   row = 0
    #   @cursor.starting_at_index(@cursor.selection_index).each do |tweet|
    #     TweetView.new(@screen, @cursor, tweet, row).display
    #     row += tweet.line_count
    #     break if row > height
    #   end
    #
    #   blank_lines_from_row(row)
    # end
    #
    # def blank_lines_from_row(start_row)
    #   if start_row < height
    #     (start_row..height).each do |row|
    #       @screen.write(row, 0, "")
    #     end
    #   end
    # end
    #
    tweets = @cursor.starting_at_index(@cursor.selection_index)
    lines = TweetRenderer.new(tweets, @cursor.selection, height).render
    @screen.write_lines(0, lines)
  end

  def key(key)
    case key
    when ?c then ComposeView.new(@screen).compose
    when ?j then @cursor = @cursor.down
    when ?k then @cursor = @cursor.up
    when ?d then @cursor = @cursor.down(jump_size)
    when ?u then @cursor = @cursor.up(jump_size)
    when ?q then raise SystemExit
    when Screen::KEY_CTRL_C then raise SystemExit
    end
  end

  def jump_size
    height / 2
  end
end

class ComposeView
  def initialize(screen)
    @screen = screen
  end

  def compose
    file = Tempfile.open("compose-tweet")
    begin
      file.close
      @screen.suspend do
        system("vi #{file.path}")
      end
      file.open
      text = file.read
      unless text.empty?
        TwitterLib.update(text)
      end
    end
  ensure
    file.close
    file.unlink
  end
end

if $0 == __FILE__
  Thread.abort_on_exception = true

  # world = World.blank(options)
  Screen.with_screen do |screen|
    # start_line = screen.height - 10
    # while not world.done?
    #   render(world, screen, start_line)
    #   world = handle_key(world)
    # end
    Toot.new(screen).run
    # screen.move_cursor(screen.height - 1, 0)
  end
  # puts world.selection

end
