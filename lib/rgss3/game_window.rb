# frozen_string_literal: true
require 'fiber'
module RGSS3
  class GameWindow < Gosu::Window
    attr_reader :frame_rate
    def initialize(width: 544, height: 416, full_screen: false, frame_rate: 60, title: "Game", rtp: nil)
      @frame_rate = frame_rate
      RTP.path = rtp if rtp
      super(width, height, full_screen, 1000.0 / frame_rate)
      self.caption = title
    end

    def update
      fiber = RGSS3.fiber
      if fiber
        fiber.alive? ? fiber.resume : close
      end
    end

    def draw
      Graphics.draw
    end
  end
end
