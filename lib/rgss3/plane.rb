# frozen_string_literal: true
require_relative 'sprite_container'
class Plane
  include RGSS3::SpriteContainer
  def draw
    return if !@visible || @opacity == 0 || @bitmap.nil? && @bitmap.disposed?
    @bitmap.gosu_image.draw(-@ox, -@oy, @z, 1, 1, 0xff_ffffff, BLEND[@blend_type])
  end
end
