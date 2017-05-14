# frozen_string_literal: true
require_relative 'container'
module RGSS3
  # common methods for Plane and Sprite
  module SpriteContainer
    include Container

    attr_accessor :zoom_x, :zoom_y
    attr_accessor :bitmap
    attr_accessor :color, :blend_type

    BLEND = {0 => :default, 1 => :additive, 2 => :subtractive}

    def initialize(viewport = nil)
      @viewport = viewport
      @zoom_x = @zoom_y = 1.0
      @blend_type = 0
      @color = Color.new
      super()
    end

    def dispose
      @bitmap = nil
      super
    end
  end
end
