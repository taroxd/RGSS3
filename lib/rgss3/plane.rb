# frozen_string_literal: true
require_relative 'container'
class Plane
  include RGSS3::Container
  def draw
    bitmap.gosu_image.draw(-@ox, -@oy, @z, 1, 1, 0xff_ffffff, BLEND[@blend_type])
  end
end
