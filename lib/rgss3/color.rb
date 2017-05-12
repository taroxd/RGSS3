class Color

  attr_accessor :gosu_color

  def initialize(*args)
    case args.size
    when 0
      empty
    when 3, 4
      set(*args)
    else
      raise ArgumentError
    end
  end

  def set(*args)
    case args.size
    when 1
      if args[0].is_a?(Color)
        @gosu_color = args[0].to_gosu
      else
        raise ArgumentError
      end
    when 3
      @gosu_color = Gosu::Color.rgba(*args.map(&:round), 255)
    when 4
      @gosu_color = Gosu::Color.rgba(*args.map(&:round))
    else
      raise ArgumentError
    end
  end

  def red
    @gosu_color.red.to_f
  end

  def blue
    @gosu_color.blue.to_f
  end

  def green
    @gosu_color.green.to_f
  end

  def alpha
    @gosu_color.alpha.to_f
  end

  def red_i
    @gosu_color.red
  end

  def blue_i
    @gosu_color.blue
  end

  def green_i
    @gosu_color.green
  end

  def alpha_i
    @gosu_color.alpha
  end

  def empty
    @gosu_color = Gosu::Color::NONE
  end

  def red=(value)
    @gosu_color.red = value
  end

  def blue=(value)
    @gosu_color.blue = value
  end

  def green=(value)
    @gosu_color.green = value
  end

  def alpha=(value)
    @gosu_color.alpha = value
  end

  def to_a
    [red_i, green_i, blue_i, alpha_i]
  end

  alias_method :rgba, :to_a

  def to_s
    format '(%.6f, %.6f, %.6f, %.6f)', red, green, blue, alpha
  end

  alias_method :inspect, :to_s

  def to_fa
    [red, green, blue, alpha]
  end

  def to_gosu
    @gosu_color.dup
  end

  def to_pixel
    Magick::Pixel.from_color(to_rmagick_color)
  end

  def to_rmagick_color
    "rgba(#{red_i},#{green_i},#{blue_i},#{alpha_i})"
  end

  def _dump(d = 0)
    [red, green, blue, alpha].pack('d4')
  end

  def self._load(s)
    new(*s.unpack('d4'))
  end

  def self.try_convert(color)
    case color
    when Color
      color
    when String
      from_pixel Magick::Pixel.from_color(color)
    when Integer
      from_int(color)
    when Magick::Pixel
      from_pixel(color)
    when Gosu::Color
      from_gosu(color)
    end
  end

  def self.from_pixel(pixel)
    new(*rgba_from_pixel(pixel))
  end

  def self.rgba_from_pixel(pixel)
    # "#RRGGBBAA"
    rgba_hex = pixel.to_color(Magick::AllCompliance, true, 8, true)
    rgba = rgba_hex[1, 8].to_i(16)
    rgba_from_int(rgba)
  end

  def from_int(rgba)
    new(*rgba_from_int(rgba))
  end

  def self.rgba_from_int(rgba)
    (0...4).each_with_object(Array.new(4)) do |i, result|
      result[3 - i] = rgba & 0xff
      rgba >>= 8
    end
  end

  def self.from_gosu(gosu_color)
    color = allocate
    color.gosu_color = gosu_color
    color
  end
end
