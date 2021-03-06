# frozen_string_literal: true
class Bitmap

  attr_reader :rect
  attr_accessor :font

  def initialize(*args)
    case args.size
    when 1
      basename, = args
      filename = RGSS3::RTP.find!(basename, ['', '.png', 'jpg'])
      initialize_with_gosu_image Gosu::Image.new(filename)
    when 2
      initialize_with_rmagick_image Magick::Image.new(*args) { self.background_color = 'none' }
    else
      raise ArgumentError
    end
  end

  def initialize_with_gosu_image(gosu_image)
    @gosu_image = gosu_image
    init_other_attr
    set_dirty
  end

  def initialize_with_rmagick_image(rmagick_image)
    self.rmagick_image = rmagick_image
    init_other_attr
  end

  def init_other_attr
    @rect = Rect.new(0, 0, gosu_image.width, gosu_image.height)
    @font = Font.new
  end

  def dispose
    @gosu_image = nil
    @rmagick_image = nil
    @disposed = true
  end

  def disposed?
    @disposed
  end

  def width
    gosu_image.width
  end

  def height
    gosu_image.height
  end

  def blt(x, y, src_bitmap, src_rect, opacity = 255)
    return if opacity == 0
    src = src_bitmap.gosu_image.subimage(*src_rect)
    if opacity != 255
      src = Bitmap.gosu_to_rmagick(src)
      ratio = opacity / 255.0
      Bitmap.pixel_map!(src) do |pixel|
        pixel.opacity *= ratio
        pixel
      end
    end
    gosu_image.insert(src, x, y)
    set_dirty
  end

  def stretch_blt(dest_rect, src_bitmap, src_rect, opacity = 255)
    return if opacity == 0
    src = src_bitmap.gosu_image.subimage(*src_rect)
    src = Bitmap.gosu_to_rmagick(gosu_to_rmagick)
    src.resize!(dest_rect.width, dest_rect.height)
    if opacity != 255
      ratio = opacity / 255.0
      Bitmap.pixel_map!(src) do |pixel|
        pixel.opacity *= ratio
        pixel
      end
    end
    gosu_image.insert(src, dest_rect.x, dest_rect.y)
    set_dirty
  end

  def fill_rect(*args)
    case args.size
    when 2, 5
      if args[0].is_a?(Rect)
        rect, color = args
        x, y, width, height = *rect
      else
        x, y, width, height, color = *args
      end
    else
      raise ArgumentError
    end
    img = Magick::Image.new(width, height) { self.background_color = color.to_rmagick_color }
    gosu_image.insert(img, x, y)
    set_dirty
  end

  def gradient_fill_rect(*args)
    case args.size
    when 3, 4
      rect, start_color, end_color, vertical = args
      x, y, width, height = *rect
    when 6, 7
      x, y, width, height, start_color, end_color, vertical = args
    else
      raise ArgumentError
    end
    start_color = start_color.to_rmagick_color
    end_color = end_color.to_rmagick_color

    if vertical
      x2 = width
      y2 = 0
    else
      x2 = 0
      y2 = height
    end

    fill = Magick::GradientFill.new(0, 0, x2, y2, start_color, end_color)

    img = Magick::Image.new(width, height, fill)
    gosu_image.insert(img, x, y)
    set_dirty
  end

  def clear
    self.rmagick_image = Magick::Image.new(width, height) { self.background_color = 'none' }
  end

  def clear_rect(*args)
    fill_rect(*args, Color.new)
  end

  def get_pixel(x, y)
    Color.from_pixel(rmagick_image.pixel_color(x, y))
  end

  def set_pixel(x, y, color)
    fill_rect(x, y, 1, 1, color)
  end

  def hue_change(hue)
    image = rmagick_image
    Bitmap.pixel_map!(rmagick_image) do |pixel|
      h, *sla = pixel.to_hsla
      h = (h + hue) % 360
      Pixel.from_hsla(h, *sla)
    end
    self.rmagick_image = image
  end

  def blur
  end

  def radial_blur(angle, division)
    blur
  end

  def draw_text(*args)
    case args.size
    when 2, 3
      rect, string, align = args
      x, y, width, height = *rect
    when 5, 6
      x, y, width, height, string, align = args
    else
      raise ArgumentError
    end

    string = string.to_s
    string.gsub!('<', '&lt;')
    string.gsub!('>', '&gt;')
    if @font.bold
      string.prepend("<b>") << "</b>"
    end
    if @font.italic
      string.prepend("<i>") << "</i>"
    end
    text_image = Gosu::Image.from_text(string, @font.size, font: @font.first_existant_name)
    x += (width - text_image.width) * (align || 0) / 2
    y += (height - text_image.height) / 2
    text_image = Bitmap.gosu_to_rmagick(text_image)
    image = text_image.dup
    font_pixel = @font.color.to_pixel
    Bitmap.pixel_map!(image) do |pixel|
      result = font_pixel.dup
      result.opacity = pixel.opacity
      result
    end
    if @font.outline
      font_pixel = @font.out_color.to_pixel
      Bitmap.pixel_map!(text_image) do |pixel|
        result = font_pixel.dup
        result.opacity = pixel.opacity
        result
      end
      image.composite!(text_image, 1, 1, Magick::DstOverCompositeOp)
    end
    # no shadow support for now
    # if @font.shadow
    #   shadow = bigger_image
    #   font_pixel = Magick::Pixel.from_color('rgba(0,0,0,128)')
    #   Bitmap.pixel_map!(shadow) do |pixel|
    #     result = font_pixel.dup
    #     result.opacity = pixel.opacity
    #     result
    #   end
    #   image.composite!(shadow, 0, 0, Magick::DstOverCompositeOp)
    # end
    # @gosu_image.insert(image, x, y)
    self.rmagick_image = rmagick_image.composite!(image, x, y, Magick::OverCompositeOp)
  end

  def text_size(string)
    f = Gosu::Font.new(@font.size, name: @font.first_existant_name)
    Rect.new(0, 0, f.text_width(string.to_s), f.height)
  end

  def self.from_gosu(img)
    bitmap = allocate
    bitmap.initialize_with_gosu_image(img)
    bitmap
  end

  def self.from_rmagick(img)
    bitmap = allocate
    bitmap.initialize_with_rmagick_image(img)
    bitmap
  end

  def self.gosu_to_rmagick(image)
    Magick::Image.from_blob(image.to_blob) {
      self.format = "RGBA"
      self.size = "#{image.width}x#{image.height}"
      self.depth = 8
    }.first
  end

  def self.pixel_map!(rmagick_image, &block)
    return to_enum(__method__, rmagick_image) unless block
    width = rmagick_image.columns
    height = rmagick_image.rows
    pixels = rmagick_image.get_pixels(0, 0, width, height)
    pixels.map!(&block)
    rmagick_image.store_pixels(0, 0, width, height, pixels)
  end

  # If bitmap.rmagick_image is changed, the behaviour is undefined.
  # If you want to change it, call set_dirty or bitmap.rmagick_image = image
  # after the change.
  def rmagick_image
    check_disposed
    if @dirty
      @dirty = false
      @rmagick_image = Bitmap.gosu_to_rmagick(@gosu_image)
    else
      @rmagick_image
    end
  end

  def rmagick_image=(image)
    check_disposed
    @rmagick_image = image
    @gosu_image = Gosu::Image.new(@rmagick_image)
  end

  def gosu_image
    check_disposed
    @gosu_image
  end

  def set_dirty
    @dirty = true
  end

  private

  def check_disposed
    raise RGSSError, "Disposed Bitmap" if @disposed
  end
end
