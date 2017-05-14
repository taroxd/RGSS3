# frozen_string_literal: true
class Window

  attr_reader :z, :ox, :oy
  attr_reader :viewport
  attr_accessor :visible
  attr_accessor :tone
  attr_accessor :windowskin
  attr_reader :contents
  attr_accessor :cursor_rect
  attr_accessor :active
  attr_reader :visible
  attr_accessor :arrows_visible
  attr_accessor :pause
  attr_reader :x
  attr_reader :y
  attr_accessor :width
  attr_accessor :height
  attr_reader :padding
  attr_accessor :padding_bottom
  attr_reader :back_opacity
  attr_reader :contents_opacity
  attr_reader :openness
  attr_reader :opacity

  def initialize(*args)
    @contents_sprite = Sprite.new
    self.contents = Bitmap.new(1, 1)
    @opacity = 255
    @cursor_rect = Rect.new
    @padding = 8
    @padding_bottom = 8
    @pause = false
    @arrows_visible = true
    @active = true
    @openness = 255
    @visible = true
    @z = 100
    @ox = 0
    @oy = 0
    @tone = Tone.new
    @back_opacity = 192
    @contents_opacity = 255
    case args.size
    when 0
      self.x = 0
      self.y = 0
      @width = 0
      @height = 0
    when 4
      self.x, self.y, @width, @height = args
    end
  end

  def update
  end

  def move(x, y, width, height)
    self.x = x
    self.y = y
    @width = width
    @height = height
  end

  def padding=(value)
    @padding = @padding_bottom = value
  end

  def open?
    @openness == 255
  end

  def close?
    @openness == 0
  end

  def openness=(value)
    @openness = [[value, 0].max, 255].min
    update_contents_opacity
  end

  def opacity=(value)
    @opacity = [[value, 0].max, 255].min
    update_contents_opacity
  end

  def x=(value)
    @contents_sprite.x = @padding + value
    @x = value
  end

  def y=(value)
    @contents_sprite.y = @padding + value
    @y = value
  end

  def z=(value)
    each_internal_sprite { |s| s.z = value }
    @z = value
  end

  def ox=(value)
    each_internal_sprite { |s| s.ox = value }
    @ox = value
  end

  def oy=(value)
    each_internal_sprite { |s| s.oy = value }
    @oy = value
  end

  def visible=(value)
    each_internal_sprite { |s| s.visible = value }
    @visible = value
  end

  def back_opacity=(value)
    @back_opacity = [[value, 0].max, 255].min
  end

  def contents_opacity=(value)
    @contents_opacity = [[value, 0].max, 255].min
    update_contents_opacity
  end

  def viewport=(value)
    each_internal_sprite { |s| s.viewport = value }
    @viewport = value
  end

  def contents=(value)
    @contents = value
    @contents_sprite.bitmap = value
  end

  def dispose
    each_internal_sprite(&:dispose)
    @disposed = true
  end

  def disposed?
    @disposed
  end

  private

  def update_contents_opacity
    @contents_sprite.opacity = @contents_opacity * @opacity * @openness / 255 / 255
  end

  def each_internal_sprite
    yield @contents_sprite
  end
end
