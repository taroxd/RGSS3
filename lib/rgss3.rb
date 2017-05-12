require "rgss3/version"

require 'gosu'
require 'zlib'
require 'rmagick'
require 'fiber'

require_relative 'rgss3/game_window'
require_relative 'rgss3/color'
require_relative 'rgss3/audio'
require_relative 'rgss3/bitmap'
require_relative 'rgss3/font'
require_relative 'rgss3/graphics'
require_relative 'rgss3/input'
require_relative 'rgss3/kernel_ext'
require_relative 'rgss3/plane'
require_relative 'rgss3/rect'
require_relative 'rgss3/rgss_error'
require_relative 'rgss3/rgss_reset'
require_relative 'rgss3/rpg'
require_relative 'rgss3/sprite'
require_relative 'rgss3/table'
require_relative 'rgss3/tilemap'
require_relative 'rgss3/tone'
require_relative 'rgss3/viewport'
require_relative 'rgss3/window'

module RGSS3
  class << self
    attr_reader :fiber, :window

    def run(**options, &block)
      @fiber = Fiber.new(&block)
      @window = RGSS3::GameWindow.new(**options)
      @window.show
    end
  end
end

