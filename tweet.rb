class Tweet
  attr_reader :username, :text
  def initialize(line, username, text)
    @line = line
    @username = username
    @text = text
  end


  def lines
    @text.split("\n")
  end
end
