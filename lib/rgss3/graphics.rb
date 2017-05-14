# frozen_string_literal: true
require 'set'
module Graphics

  class << self
    attr_accessor :frame_count
    attr_reader :brightness, :frame_rate
    attr_reader :needs_redraw
  end

  @brightness = 255
  @frame_count = 0
  @frozen = false
  @draw_color = Gosu::Color.rgba(0, 0, 0, 0)
  @containers = Set.new

  def self.update
    @needs_redraw = true unless @frozen
    @frame_count += 1
    Fiber.yield
  end

  def self.wait(duration)
    @needs_redraw = true unless @frozen
    # no need to redraw during wait
    duration.times do
      @frame_count += 1
      Fiber.yield
    end
  end

  def self.fadeout(duration)
    @brightness = 0
  end

  def self.fadein(duration)
    @brightness = 255
  end

  def self.freeze
    @frozen = true
  end

  def self.transition(duration = 10, filename = "", vague = 40)
    @frozen = false
    @brightness = 255
  end

  def self.snap_to_bitmap
    Bitmap.new(width, height)
  end

  def self.frame_reset
    Fiber.yield
  end

  def self.width
    RGSS3.window.width
  end

  def self.height
    RGSS3.window.height
  end

  def self.resize_screen(width, height)
    reform_window(width: width, height: height)
  end

  def self.gosu_window
    RGSS3.window
  end

  def self.frame_rate
    RGSS3.window.frame_rate
  end

  def self.brightness=(value)
    @brightness = [[255, value].min, 0].max
    @draw_color.alpha = 255 - @brightness
  end

  def self.frame_rate=(value)
    @frame_rate = [[120, value].min, 10].max
    reform_window(
      width: width,
      height: height,
      fullscreen: RGSS3.window.fullscreen?,
      frame_rate: @frame_rate,
      title: RGSS3.window.caption)
  end

  def self.play_movie(filename)
  end

  def self.add_container(container)
    @containers.add(container)
  end

  def self.remove_container(container)
    @containers.delete(container)
  end

  def self.draw
    @needs_redraw = false
    @containers.each(&:do_draw)
    if @brightness < 255
      Gosu.draw_rect(0, 0, width, height, @draw_color, 2147483647)
    end
  end

  def self.reform_window(
    width: RGSS3.window.width,
    height: RGSS3.window.height,
    full_screen: RGSS3.window.fullscreen?,
    frame_rate: @frame_rate,
    title: RGSS3.window.caption,
    rtp: nil)

    RGSS3.window.close
    RGSS3.window = RGSS3::GameWindow.new(
      width: width,
      height: height,
      fullscreen: fullscreen,
      frame_rate: frame_rate,
      title: title,
      rtp: rtp)
    RGSS3.window.show
  end
end
