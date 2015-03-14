require_relative "../cursor"
require_relative "../tweet"

RSpec.describe Cursor do

  describe "soemthing" do
    # tweet = double(Tweet)
    # expect(Cursor.new([tweet]).empty?).to eq(false)
    describe "#selection" do
      it "errors if there is no selection" do
        cursor = Cursor.new([])
        expect { cursor.selection }.to raise_error(IndexError)
      end
    end
  end

  describe "slicing" do
    let(:tweet1) { Tweet.new("id1", "garybernhardt", "line1\nline2") }
    let(:tweet2) { Tweet.new("id2", "garybernhardt", "line3") }
    let(:tweet3) { Tweet.new("id3", "garybernhardt", "not in the list") }
    let(:cursor) { Cursor.new([tweet1, tweet2]) }

    it "returns tweets starting at a given tweet" do
      expect { cursor.starting_at(tweet3) }.to raise_error(IndexError)
      expect(cursor.starting_at(tweet1)).to eq([tweet1, tweet2])
      expect(cursor.starting_at(tweet2)).to eq([tweet2])
    end

    it "returns tweets starting at a given index" do
      expect { cursor.starting_at_index(-1) }.to raise_error(IndexError)
      expect(cursor.starting_at_index(nil)).to eq([])
      expect(cursor.starting_at_index(0)).to eq([tweet1, tweet2])
      expect(cursor.starting_at_index(1)).to eq([tweet2])
      expect { cursor.starting_at_index(2) }.to raise_error(IndexError)
    end
  end

  describe "lines of text" do
    let(:tweet1) { Tweet.new("id1", "garybernhardt", "line0\nline1") }
    let(:tweet2) { Tweet.new("id2", "garybernhardt", "line2\nline3\nline4") }
    let(:tweet3) { Tweet.new("id3", "garybernhardt", "line5") }
    let(:cursor) { Cursor.new([tweet1, tweet2, tweet3]) }
  end

end
