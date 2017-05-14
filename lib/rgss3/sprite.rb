# frozen_string_literal: true
require_relative 'container'
class Sprite

  include RGSS3::Container

  attr_reader :bush_opacity
  attr_accessor :x, :y
  attr_accessor :src_rect
  attr_accessor :wave_amp, :wave_length, :wave_speed, :wave_phase
  attr_accessor :angle, :mirror
  attr_accessor :bush_depth

  def initialize(viewport = nil)
    @x = 0
    @y = 0
    @angle = 0
    @mirror = false
    @bush_depth = 0
    @bush_opacity = 128
    @wave_speed = 360
    @src_rect = Rect.new
    super
  end

  def flash(color, duration)
  end

  def update
  end

  def width
    @src_rect.width
  end

  def height
    @src_rect.height
  end

  def bush_opacity=(int)
    @bush_opacity = [[int, 255].min, 0].max
  end

  def bitmap=(bitmap)
    super(bitmap)
    @src_rect = Rect.new(0, 0, bitmap.width, bitmap.height)
  end

  def draw
    if viewport
      x = @x + viewport.rect.x
      y = @y + viewport.rect.y
      w = [width - viewport.ox, viewport.rect.x + viewport.rect.width - x].min
      h = [height - viewport.oy, viewport.rect.y + viewport.rect.height - y].min
      return if w <= 0 || h <= 0
      z = @z + (viewport.z << 12)
      src_x = @src_rect.x + viewport.ox
      src_y = @src_rect.y + viewport.oy
    else
      x = @x
      y = @y
      z = @z
      src_x, src_y, w, h = *@src_rect
    end
    image = bitmap.gosu_image.subimage(src_x, src_y, w, h)
    return unless image
    image.draw_rot(
      x,
      y,
      z,
      @angle,
      ox.fdiv(width),
      oy.fdiv(height),
      @zoom_x * (@mirror ? -1 : 1),
      @zoom_y,
      0xff_ffffff,
      BLEND[@blend_type])
  end
end
