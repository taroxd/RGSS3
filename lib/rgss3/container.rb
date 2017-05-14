# frozen_string_literal: true
module RGSS3
  # common methods for Plane, Sprite
  module Container

    attr_accessor :z, :ox, :oy
    attr_accessor :viewport, :visible
    attr_accessor :tone
    attr_accessor :zoom_x, :zoom_y
    attr_accessor :bitmap
    attr_accessor :color, :blend_type
    attr_reader :opacity

    BLEND = {0 => :default, 1 => :additive, 2 => :subtractive}

    def initialize(viewport = nil)
      @visible = true
      @z = 0
      @ox = 0
      @oy = 0
      @tone = Tone.new
      @viewport = viewport
      @zoom_x = @zoom_y = 1.0
      @blend_type = 0
      @color = Color.new
      @opacity = 255
      Graphics.add_container(self)
    end

    def initialize_copy
      copy = super
      Graphics.add_container(copy)
      copy
    end

    def dispose
      @disposed = true
      @bitmap = nil
      Graphics.remove_container(self)
    end

    def disposed?
      @disposed
    end

    def opacity=(value)
      @opacity = [[value, 0].max, 255].mins
    end

    # overwrite
    def draw
    end

    # this method is used internally by Graphics
    def do_draw
      return if !@visible || @opacity == 0 || @bitmap.nil? || @bitmap.disposed?
      draw
    end
  end
end
