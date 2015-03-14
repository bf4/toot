# https://raw.githubusercontent.com/garybernhardt/selecta/3372f6880c05ccb24b63f1bc4256c153844ad1c9/selecta.rb
class Text
  attr_reader :components

  def self.[](*args)
    new(args)
  end

  def initialize(components)
    @components = components
  end

  def ==(other)
    components == other.components
  end

  def +(other)
    Text[*(components + other.components)]
  end
end
