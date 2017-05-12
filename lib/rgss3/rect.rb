class Rect

  attr_accessor :x, :y, :width, :height

  def initialize(*args)
    case args.size
    when 0
      empty
    when 4
      set(*args)
    else
      raise ArgumentError
    end
  end

  def set(*args)
    case args.size
    when 1
      rect, = args
      @x, @y, @width, @height = *rect
    when 4
      @x, @y, @width, @height = *args
    else
      raise ArgumentError
    end
  end

  def empty
    @x = 0
    @y = 0
    @width = 0
    @height = 0
  end

  def to_a
    [x, y, width, height]
  end

  def ==(other)
    self.class == other.class && x == other.x && y == other.y &&
      width == other.width && height == other.height
  end

  alias_method :eql?, :==

  def hash
    [:rect, *to_a].hash
  end
end
