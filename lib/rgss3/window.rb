require_relative 'container'
class Window

  include RGSS3::Container

  attr_accessor :windowskin
  attr_accessor :contents
  attr_accessor :cursor_rect
  attr_accessor :active
  attr_accessor :visible
  attr_accessor :arrows_visible
  attr_accessor :pause
  attr_accessor :x
  attr_accessor :y
  attr_accessor :width
  attr_accessor :height
  attr_accessor :padding
  attr_accessor :padding_bottom
  attr_accessor :opacity
  attr_accessor :back_opacity
  attr_accessor :contents_opacity
  attr_accessor :openness

  def initialize(*args)
    case args.size
    when 0
      @x = 0
      @y = 0
      @width = 0
      @height = 0
    when 4
      @x, @y, @width, @height = args
    end
    super()
  end

  def update
  end

  def move(x, y, width, height)
    @x = x
    @y = y
    @width = width
    @height = height
  end

  def open?
    openness == 255
  end

  def close?
    openness == 0
  end

  def draw
    # TODO
  end
end
