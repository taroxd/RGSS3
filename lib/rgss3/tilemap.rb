class Tilemap
  
  TILESIZE = 32

  attr_accessor :bitmaps
  attr_reader   :map_data
  attr_accessor :flash_data
  attr_accessor :flags
  attr_accessor :viewport
  attr_accessor :visible
  attr_reader   :ox
  attr_reader   :oy
  
  def initialize(viewport = nil)
    @bitmaps = []
    @viewport = viewport
    @visible = true
    @ox = 0
    @oy = 0
    @animated_layer = []
    @layers = [Plane.new, Plane.new, Plane.new]
    @anim_count = 0
    @disposed = false
    @layers[0].z = 0
    @layers[0].viewport = @viewport
    @layers[1].z = 100
    @layers[1].viewport = @viewport
    @layers[2].z = 200
    @layers[2].viewport = @viewport
  end

  def dispose
    for layer in @layers
      layer.bitmap.dispose
      layer.dispose
    end
    for layer in @animated_layer
      layer.dispose
    end
    @disposed = true
  end

  def disposed?
    @disposed
  end
  
  def update
    @anim_count = (@anim_count + 1) % (@animated_layer.size * 30)
    @layers[0].bitmap = @animated_layer[@anim_count/30]
  end
  
  def refresh
    return if @map_data.nil? || @flags.nil?
    for layer in @layers
      layer.bitmap.dispose if layer.bitmap
    end
    draw_animated_layer
    draw_upper_layers
  end
  
  def draw_animated_layer
    bitmap = Bitmap.new(@map_data.xsize * TILESIZE, @map_data.ysize * TILESIZE)
    if need_animated_layer?
      @animated_layer = [bitmap, bitmap.clone, bitmap.clone]
    else
      @animated_layer = [bitmap]
    end
    @layers[0].bitmap = @animated_layer[0]
    for x in 0..@map_data.xsize - 1
      for y in 0..@map_data.ysize - 1
        draw_A1tile(x,y,@map_data[x,y,0],true) if @map_data[x,y,0].between?(2048,2815)
        draw_A2tile(x,y,@map_data[x,y,0]) if @map_data[x,y,0].between?(2816,4351)
        draw_A3tile(x,y,@map_data[x,y,0]) if @map_data[x,y,0].between?(4352,5887)
        draw_A4tile(x,y,@map_data[x,y,0]) if @map_data[x,y,0].between?(5888,8191)
        draw_A5tile(x,y,@map_data[x,y,0]) if @map_data[x,y,0].between?(1536,1663)
      end
    end
    for x in 0..@map_data.xsize - 1
      for y in 0..@map_data.ysize - 1
        draw_A1tile(x,y,@map_data[x,y,1],true) if @map_data[x,y,1].between?(2048,2815)
        draw_A2tile(x,y,@map_data[x,y,1]) if @map_data[x,y,1].between?(2816,4351)
      end
    end
  end
  
  def bitmap_for_autotile(autotile)
    return 0 if autotile.between?(0,15)
    return 1 if autotile.between?(16,47)
    return 2 if autotile.between?(48,79)
    return 3 if autotile.between?(80,127)
  end
  
  A1 = [
    [13,14,17,18], [2,14,17,18],  [13,3,17,18],  [2,3,17,18],
    [13,14,17,7],  [2,14,17,7],   [13,3,17,7],   [2,3,17,7],
    [13,14,6,18],  [2,14,6,18],   [13,3,6,18],   [2,3,6,18],
    [13,14,6,7],   [2,14,6,7],    [13,3,6,7],    [2,3,6,7],
    [12,14,16,18], [12,3,16,18],  [12,14,16,7],  [12,3,16,7],
    [9,10,17,18],  [9,10,17,7],   [9,10,6,18],   [9,10,6,7],
    [13,15,17,19], [13,15,6,19],  [2,15,17,19],  [2,15,6,19],
    [13,14,21,22], [2,14,21,22],  [13,3,21,22],  [2,3,21,22],
    [12,15,16,19], [9,10,21,22],  [8,9,12,13],   [8,9,12,7],
    [10,11,14,15], [10,11,6,15],  [18,19,22,23], [2,19,22,23],
    [16,17,20,21], [16,3,20,21],  [8,11,12,15],  [8,9,20,21],
    [16,19,20,23], [10,11,22,23], [8,11,20,23],  [0,1,4,5]
  ]
  
  A1POS = [
  [0,0],[0,TILESIZE*3],[TILESIZE*6,0],[TILESIZE*6,TILESIZE*3],
  [TILESIZE*8,0],[TILESIZE*14,0],[TILESIZE*8,TILESIZE*3],[TILESIZE*14,TILESIZE*3],
  [0,TILESIZE*6],[TILESIZE*6,TILESIZE*6],[0,TILESIZE*9],[TILESIZE*6,TILESIZE*9],
  [TILESIZE*8,TILESIZE*6],[TILESIZE*14,TILESIZE*6],[TILESIZE*8,TILESIZE*9],[TILESIZE*14,TILESIZE*9]
  ]
  
  def draw_A1tile(x,y,id,animated = false)
    autotile = (id - 2048) / 48
    return draw_waterfalltile(x,y,id) if [5,7,9,11,13,15].include?(autotile)
    index = (id - 2048) % 48
    case bitmap_for_autotile(autotile)
    when 0
      x2 = A1POS[autotile][0]
      y2 = A1POS[autotile][1]
    when 1
      x2 = (TILESIZE * 2) * ((autotile - 16) % 8)
      y2 = (TILESIZE * 3) * ((autotile - 16) / 8)
    when 2
      x2 = (TILESIZE * 2) * ((autotile - 48) % 8)
      y2 = (TILESIZE * 2) * ((autotile - 48) / 8)
    when 3
      x2 = (TILESIZE * 2) * ((autotile - 80) % 8)
      y2 = (TILESIZE * 3) * ((((autotile - 80) / 8)+1)/2) + (TILESIZE * 2) * (((autotile - 80) / 8)/2)
    end
    rect = Rect.new(0,0,TILESIZE/2,TILESIZE/2)
    for layer in @animated_layer
      for i in 0..3
        rect.x = x2 + (TILESIZE/2) * (A1[index][i] % 4)
        rect.y = y2 + (TILESIZE/2) * (A1[index][i] / 4)
        case i
        when 0
          layer.blt(x * TILESIZE, y * TILESIZE,@bitmaps[bitmap_for_autotile(autotile)],rect)
        when 1
          layer.blt(x * TILESIZE + (TILESIZE/2), y * TILESIZE,@bitmaps[bitmap_for_autotile(autotile)],rect)
        when 2
          layer.blt(x * TILESIZE, y * TILESIZE + (TILESIZE/2),@bitmaps[bitmap_for_autotile(autotile)],rect)
        when 3
          layer.blt(x * TILESIZE + (TILESIZE/2), y * TILESIZE + (TILESIZE/2),@bitmaps[bitmap_for_autotile(autotile)],rect)
        end
      end
      x2 += TILESIZE * 2 if animated && ![2,3].include?(autotile)
    end
  end
  
  A1E = [
  [0,1,6,7],[0,1,4,5],[2,3,6,7],[1,2,5,6]
  ]
  
  def draw_waterfalltile(x,y,id)
    autotile = (id - 2048) / 48
    index = (id - 2048) % 48
    x2 = A1POS[autotile][0]
    y2 = A1POS[autotile][1]
    rect = Rect.new(0,0,TILESIZE/2,TILESIZE/2)
    for layer in @animated_layer
      for i in 0..3
        rect.x = x2 + (TILESIZE/2) * (A1E[index][i] % 4)
        rect.y = y2 + (TILESIZE/2) * (A1E[index][i] / 4)
        case i
        when 0
          layer.blt(x * TILESIZE, y * TILESIZE,@bitmaps[bitmap_for_autotile(autotile)],rect)
        when 1
          layer.blt(x * TILESIZE + (TILESIZE/2), y * TILESIZE,@bitmaps[0],rect)
        when 2
          layer.blt(x * TILESIZE, y * TILESIZE + (TILESIZE/2),@bitmaps[0],rect)
        when 3
          layer.blt(x * TILESIZE + (TILESIZE/2), y * TILESIZE + (TILESIZE/2),@bitmaps[0],rect)
        end
      end
      y2 += TILESIZE
    end
  end
  
  def draw_A2tile(x,y,id)
    draw_A1tile(x,y,id)
  end
  
  A3 = [
    [5,6,9,10],    [4,5,8,9],    [1,2,5,6],   [0,1,4,5],
    [6,7,10,11],   [4,7,8,11],   [2,3,6,7],   [0,3,4,7],
    [9,10,13,14],  [8,9,12,13],  [1,2,13,14], [0,1,12,13],
    [10,11,14,15], [8,11,12,13], [2,3,14,15], [0,3,12,15]
  ]
  
  def draw_A3tile(x,y,id)
    autotile = (id - 2048) / 48
    index = (id - 2048) % 48
    case bitmap_for_autotile(autotile)
    when 0
      x2 = (TILESIZE * 2) * ((autotile) % 8)
      y2 = (TILESIZE * 3) * ((autotile) / 8)
    when 1
      x2 = (TILESIZE * 2) * ((autotile - 16) % 8)
      y2 = (TILESIZE * 3) * ((autotile - 16) / 8)
    when 2
      x2 = (TILESIZE * 2) * ((autotile - 48) % 8)
      y2 = (TILESIZE * 2) * ((autotile - 48) / 8)
    when 3
      x2 = (TILESIZE * 2) * ((autotile - 80) % 8)
      y2 = (TILESIZE * 3) * ((((autotile - 80) / 8)+1)/2) + (TILESIZE * 2) * (((autotile - 80) / 8)/2)
    end
    rect = Rect.new(0,0,TILESIZE/2,TILESIZE/2)
    for layer in @animated_layer
      for i in 0..3
        if A3[index].nil?
          rect.x = x2 + (TILESIZE/2) * (A1[index][i] % 4)
          rect.y = y2 + (TILESIZE/2) * (A1[index][i] / 4)
        else
          rect.x = x2 + (TILESIZE/2) * (A3[index][i] % 4)
          rect.y = y2 + (TILESIZE/2) * (A3[index][i] / 4)
        end
        case i
        when 0
          layer.blt(x * TILESIZE, y * TILESIZE,@bitmaps[bitmap_for_autotile(autotile)],rect)
        when 1
          layer.blt(x * TILESIZE + (TILESIZE/2), y * TILESIZE,@bitmaps[bitmap_for_autotile(autotile)],rect)
        when 2
          layer.blt(x * TILESIZE, y * TILESIZE + (TILESIZE/2),@bitmaps[bitmap_for_autotile(autotile)],rect)
        when 3
          layer.blt(x * TILESIZE + (TILESIZE/2), y * TILESIZE + (TILESIZE/2),@bitmaps[bitmap_for_autotile(autotile)],rect)
        end
      end
    end
  end
  
  def draw_A4tile(x,y,id)
    autotile = (id - 2048) / 48
    case autotile
    when 80..87
      draw_A1tile(x,y,id)
    when 96..103
      draw_A1tile(x,y,id)
    when 112..119
      draw_A1tile(x,y,id)
    else
      draw_A3tile(x,y,id)
    end
  end
  
  def draw_A5tile(x,y,id)
    id -= 1536
    rect = Rect.new(TILESIZE * (id % 8),TILESIZE * ((id % 128) / 8),TILESIZE,TILESIZE)
    for layer in @animated_layer
      layer.blt(x * TILESIZE, y * TILESIZE,@bitmaps[4],rect)
    end
  end
  
  def need_animated_layer?
    for x in 0..@map_data.xsize - 1
      for y in 0..@map_data.ysize - 1
        if @map_data[x,y,0].between?(2048, 2815)
          return true
        end
      end
    end
    return false
  end
  
  def draw_upper_layers
    bitmap = Bitmap.new(@map_data.xsize * TILESIZE, @map_data.ysize * TILESIZE)
    @layers[1].bitmap = bitmap
    @layers[2].bitmap = bitmap.clone
    rect = Rect.new(0,0,TILESIZE,TILESIZE)
    for x in 0..@map_data.xsize - 1
      for y in 0..@map_data.ysize - 1
        n = @map_data[x,y,2] % 256
        rect.x = TILESIZE * ((n % 8) + (8 * (n / 128)))
        rect.y = TILESIZE * ((n % 128) / 8)
        if @flags[@map_data[x,y,2]] & 0x10 == 0
          @layers[1].bitmap.blt(x * TILESIZE, y * TILESIZE,@bitmaps[5+@map_data[x,y,2]/256],rect)
        else
          @layers[2].bitmap.blt(x * TILESIZE, y * TILESIZE,@bitmaps[5+@map_data[x,y,2]/256],rect)
        end
      end
    end
  end
  
  def map_data=(data)
    return if @map_data == data
    @map_data = data
    refresh
  end
  
  def flags=(data)
    @flags = data
    refresh
  end
  
  def ox=(value)
    @ox = value
    for layer in @layers
      layer.ox = @ox
    end
  end
  
  def oy=(value)
    @oy = value
    for layer in @layers
      layer.oy = @oy
    end
  end
end