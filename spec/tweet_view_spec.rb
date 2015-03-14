require_relative "../tweet_view"
require_relative "../tweet"

RSpec.describe TweetView do
  it "renders tweets" do
    tweet = Tweet.new(1, "garybernhardt", "#lolruby\n#lolpython")
    screen = double(:screen)
    expect(screen).to receive(:write_text).with(0, 0, "  garybernhardt ")
    expect(screen).to receive(:write_text).with(0, 16, "#lolruby")
    expect(screen).to receive(:write_text).with(1, 16, "#lolpython")
    TweetView.new(tweet, screen).render
  end
end
