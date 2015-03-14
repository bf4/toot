# https://raw.githubusercontent.com/garybernhardt/selecta/3372f6880c05ccb24b63f1bc4256c153844ad1c9/selecta.rb
require_relative "ansi"
class Screen
  KEY_CTRL_C = ?\C-c
  FOOTER_SIZE = 3
  def self.with_screen
    screen = self.new
    screen.configure_tty
    begin
      yield screen
    ensure
      screen.restore_tty
      puts
    end
  end

  def initialize
    @original_stty_state = command("stty -g")
    @status_line = height - FOOTER_SIZE
    @highlight = false
  end


  def status(summary_message, quit_command)
    write_unrestricted(@status_line + 1 , 0, "-" * width)
    write_unrestricted(@status_line + 2, 0, summary_message)
    write_unrestricted(@status_line + 3, 0, quit_command)
  end

  def configure_tty
    # raw: Disable input and output processing
    # -echo: Don't echo keys back
    # cbreak: Set up lots of standard stuff, including INTR signal on ^C
    # dsusp undef: Unmap delayed suspend (^Y by default)
    command("stty raw -echo cbreak dsusp undef")
    ANSI.reset!
  end

  def restore_tty
    command("stty #{@original_stty_state}")
    puts
  end

  def suspend
    restore_tty
    begin
      yield
      configure_tty
    rescue
      restore_tty
    end
  end

  def with_cursor_hidden(&block)
    ANSI.hide_cursor!
    begin
      block.call
    ensure
      ANSI.show_cursor!
    end
  end

  def height
    size[0]
  end

  # 72?
  def usable_height
    @status_line
  end

  def width
    size[1]
  end

  def size
    height, width = $stdout.winsize
    [height, width]
  end

  def move_cursor(line, column)
    ANSI.setpos!(line, column)
  end

  def write_line(line, text)
    write(line, 0, text)
  end

  def write_lines(line, texts)
    texts.each_with_index do |text, index|
      write(line + index, 0, text)
    end
  end

  def write(line, column, text)
    # Discard writes outside the main screen area
    write_unrestricted(line, column, text) if line < height
  end

  def write_unrestricted(line, column, text)
    text = Text[:default, text] unless text.is_a? Text
    write_text_object(line, column,text)
  end

  def write_text_object(line, column, text)
    # Blank the line before drawing to it
    ANSI.setpos!(line, 0)
    ANSI.addstr!(" " * width)

    highlight = false
    text.components.each do |component|
      if component.is_a? String
        ANSI.setpos!(line, column)
        ANSI.addstr!(component)
        column += component.length
      elsif component == :highlight
        highlight = true
      else
        color = component
        set_color(component, highlight)
      end
    end
  end

  def set_color(color, highlight)
    ANSI.color!(color, highlight ? :blue : :default)
  end

  def command(command)
    result = `#{command}`
    raise "Command failed: #{command.inspect}" unless $?.success?
    result
  end
end

