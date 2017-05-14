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
    # window = RGSS3.window
    # @current = window.record(window.width, window.height) do
    #   @containers.each(&:draw)
    # end
    @frame_count += 1

    unless @frozen
      @needs_redraw = true
      # @latest = @current
    end

    Fiber.yield
  end

  # no need to redraw during wait
  def self.wait(duration)
    duration.times do
      @frame_count += 1
      Fiber.yield
    end
  end

  def self.fadeout(duration)
    @brightness = 0
    # Thread.new {
    #   rate = @brightness / duration.to_f
    #   until @brightness <= 0
    #     self.brightness -= rate
    #     sleep 1.0 / frame_rate
    #   end
    #   self.brightness = 0
    # }
  end

  def self.fadein(duration)
    @brightness = 255
    # Thread.new {
    #   rate = 255 / duration.to_f
    #   until @brightness >= 255
    #     self.brightness += rate
    #     sleep 1.0 / frame_rate
    #   end
    #   self.brightness = 255
    # }
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

  def self.resize_screen(w, h)
    reform_window(w, h, RGSS3.window.fullscreen?, RGSS3.update_interval)
  end

  def self.gosu_window
    RGSS3.window
  end

  def self.frame_rate
    RGSS3.window.frame_rate
  end

  def self.brightness=(int)
    @brightness = [[255, int].min, 0].max
    @draw_color.alpha = 255 - @brightness
  end

  def self.frame_rate=(int)
    # @frame_rate = [[120, int].min, 10].max
    #reform_window(width, height, fullscreen?, 1.0 / @frame_rate * 1000)
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
      c = @draw_color
      RGSS3.window.draw_quad(0, 0, c, 0, height, c, width, 0, c, width, height, c, 1)
    end
  end

  # def self.set_fullscreen(bool)
  #   return if bool == fullscreen?
  #   reform_window(width, height, bool, gosu_window.update_interval)
  # end

  def self.reform_window(w, h, f, update_interval)
    Graphics.gosu_window.close
    Graphics.gosu_window = GosuGame.new(w, h, f, update_interval)
    Graphics.gosu_window.show
  end
end
