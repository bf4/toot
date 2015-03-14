require_relative "../timeline"
require_relative "../tweet"

RSpec.describe Timeline do
  let(:tweet1) { Tweet.new(1, "user1", "text1") }
  let(:tweet2) { Tweet.new(2, "user2", "text2") }
  let(:timeline) { Timeline.new([tweet1]) }

  it "holds tweets" do
    expect(timeline.tweets.first).to eq(tweet1)
  end

  it "adds tweets" do
    expect(timeline.add([tweet2]).tweets).to eq([tweet2, tweet1])
  end

  it "doesn't add duplicate tweets" do
    expect(timeline.add([tweet1]).tweets).to eq([tweet1])
  end

  it "adds tweets with duplicate content but different IDs" do
    tweet1_copy = Tweet.new("new-id1", tweet1.username, tweet1.text)
    expect(timeline.add([tweet1_copy]).tweets).to eq([tweet1_copy, tweet1])
  end
end
