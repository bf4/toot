require_relative "../tweet_renderer"
require_relative "../tweet"

RSpec.describe TweetRenderer do
  let(:tweet_not_in_list) { Tweet.new(0, "garybernhardt", "something") }

  it "renders tweets" do
    tweet = Tweet.new(1, "garybernhardt", "#lolruby")
    lines = TweetRenderer.new([tweet], tweet_not_in_list, 1).render
    expect(lines).to match [
      Text[:green, "   garybernhardt", " ", :default, "#lolruby"]
    ]
  end


  it "renders multi-line tweets" do
    tweet = Tweet.new(1, "garybernhardt", "#lolpython\n#lolruby")
    lines = TweetRenderer.new([tweet], tweet_not_in_list, 2).render
    expect(lines).to match [
      Text[:green, "   garybernhardt", " ", :default, "#lolpython"],
      Text[" " * 17, :default, "#lolruby"]
    ]
  end

  it "highlights the selected tweet" do
    tweet = Tweet.new(1, "garybernhardt", "#lolruby")
    lines = TweetRenderer.new([tweet], tweet, 1).render
    expect(lines.first.components.first).to eq(:highlight)
  end

  it "renders multiple tweets" do
    tweet1 = Tweet.new(1, "garybernhardt", "#lolruby")
    tweet2 = Tweet.new(2, "garybernhardt", "#lolpython")
    lines = TweetRenderer.new([tweet1, tweet2], tweet_not_in_list, 2).render
    expect(lines).to match [
      Text[:green, "   garybernhardt", " ", :default, "#lolruby"],
      Text[:green, "   garybernhardt", " ", :default, "#lolpython"],
    ]
  end

  it "renders whitespace when there aren't enough tweets" do
    tweet = Tweet.new(1, "garybernhardt", "#lolruby")
    lines = TweetRenderer.new([tweet], tweet_not_in_list, 2).render
    expect(lines).to match [
      Text[:green, "   garybernhardt", " ", :default, "#lolruby"],
      Text[:default]
    ]
  end

  it "doesn't render off the edge of the screen" do
    tweet = Tweet.new(1, "garybernhardt", "#lolpython\n#lolruby")
    lines = TweetRenderer.new([tweet], tweet_not_in_list, 1).render
    expect(lines).to match [
      Text[:green, "   garybernhardt", " ", :default, "#lolpython"],
    ]
  end

  it "renders no tweets" do
    lines = TweetRenderer.new([], tweet_not_in_list, 1).render
    expect(lines).to match [
      Text[:default],
    ]
  end
end
