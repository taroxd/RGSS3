# frozen_string_literal: true
class Window

  attr_accessor :z, :ox, :oy
  attr_accessor :viewport, :visible
  attr_accessor :tone
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
  attr_accessor :back_opacity
  attr_accessor :contents_opacity
  attr_reader :openness
  attr_reader :opacity

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
    @opacity = 255
    @contents = Bitmap.new(1, 1)
    @cursor_rect = Rect.new
    @padding = 12
    @padding_bottom = 8
    @pause = false
    @arrows_visible = true
    @active = true
    @openness = 255
    @visible = true
    @z = 0
    @ox = 0
    @oy = 0
    @tone = Tone.new
    @opacity = 255
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
    @openness == 255
  end

  def close?
    @openness == 0
  end

  def openness=(value)
    @openness = [[value, 0].max, 255].min
  end

  def opacity=(value)
    @opacity = [[value, 255].min, 0].max
  end

  def dispose
    @disposed = true
  end

  def disposed?
    @disposed
  end
end
