require_relative "../tweet_renderer"
require_relative "../tweet"

RSpec.describe TweetRenderer do
  it "renders tweets" do
    tweet = Tweet.new(1, "garybernhardt", "#lolruby\n#lolpython")
    expect(TweetRenderer.new(tweet).render).to match [
      "  garybernhardt #lolruby",
      "                #lolpython",
    ]
  end
end
