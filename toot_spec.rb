require_relative "toot"

RSpec.describe Follow do
  context "when the user is public" do
    it "follows immediately" do
      user = User.new("garybernhardt", false)
      expect(Follow).to receive(:actually_follow).with(user)
      Follow.follow(user)
    end
  end

  context "when the user is private" do
    let(:user) { User.new("garybernhardt", true) }

    it "does not follow if the user declines the prompt" do
      allow(Follow).to receive(:confirm_follow).with(user) { false }
      expect(Follow).not_to receive(:actually_follow)
      Follow.follow(user)
    end

    it "follows if the user accepts the prompt" do
      allow(Follow).to receive(:confirm_follow).with(user) { true }
      expect(Follow).to receive(:actually_follow).with(user)
      Follow.follow(user)
    end
  end
end
