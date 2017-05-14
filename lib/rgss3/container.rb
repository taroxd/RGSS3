# frozen_string_literal: true
module RGSS3
  # common methods for Plane, Sprite and Window
  module Container

    attr_reader :opacity
    attr_accessor :z, :ox, :oy
    attr_accessor :viewport, :visible
    attr_accessor :tone

    def initialize
      @visible = true
      @z = 0
      @ox = 0
      @oy = 0
      @opacity = 255
      @tone = Tone.new
      Graphics.add_container(self)
    end

    def initialize_copy
      copy = super
      Graphics.add_container(copy)
      copy
    end

    def dispose
      @disposed = true
      Graphics.remove_container(self)
    end

    def disposed?
      @disposed
    end

    def opacity=(int)
      @opacity = [[int, 255].min, 0].max
    end

    def draw
    end
  end
end
