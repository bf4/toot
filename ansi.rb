# https://raw.githubusercontent.com/garybernhardt/selecta/3372f6880c05ccb24b63f1bc4256c153844ad1c9/selecta.rb
module ANSI
  ESC = 27.chr

  def self.escape(sequence)
    ESC + "[" + sequence
  end

  def self.reset
    escape "2J"
  end

  def self.hide_cursor
    escape "?25l"
  end

  def self.show_cursor
    escape "?25h"
  end

  def self.setpos(line, column)
    escape "#{line + 1};#{column + 1}H"
  end

  def self.addstr(str)
    str
  end

  def self.color(fg, bg=:default)
    normal = "22"
    fg_codes = {
      :black => 30,
      :red => 31,
      :green => 32,
      :yellow => 33,
      :blue => 34,
      :magenta => 35,
      :cyan => 36,
      :white => 37,
      :default => 39,
    }
    bg_codes = {
      :black => 40,
      :red => 41,
      :green => 42,
      :yellow => 43,
      :blue => 44,
      :magenta => 45,
      :cyan => 46,
      :white => 47,
      :default => 49,
    }
    fg_code = fg_codes.fetch(fg)
    bg_code = bg_codes.fetch(bg)
    escape "#{normal};#{fg_code};#{bg_code}m"
  end

  def self.reset!(*args); write reset(*args); end
  def self.setpos!(*args); write setpos(*args); end
  def self.addstr!(*args); write addstr(*args); end
  def self.color!(*args); write color(*args); end
  def self.hide_cursor!(*args); write hide_cursor(*args); end
  def self.show_cursor!(*args); write show_cursor(*args); end

  def self.write(bytes)
    $stdout.write(bytes)
  end
end
