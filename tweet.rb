require "values"

class Tweet < Value.new(:tid, :username, :text)
  def initialize(tid, username, text)
    super(tid.to_i, username, text)
  end

  def line_count
    lines.count
  end

  def lines
    @text.split("\n")
  end
end
