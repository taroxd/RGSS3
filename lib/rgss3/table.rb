class Table

  attr_accessor :data
  attr_reader :xsize, :ysize, :zsize

  def initialize(x, y = 0, z = 0)
    init_attr(x, y, z)
    @data = Array.new(@xsize * @ysize * @zsize, 0)
  end

  def [](x, y = 0, z = 0)
    @data[x + y * @xsize + z * @xsize * @ysize]
  end

  def resize(x, y = 0, z = 0)
    new_table = Table.new(x, y, z)
    x.times do |i|
      [y, 1].max.times do |j|
        [z, 1].max.times do |k|
          new_table[i, j, k] = self[i, j, k] || 0
        end
      end
    end
    @data = new_table.data
    init_attr(x, y, z)
  end


  def []=(x, y = 0, z = 0, v)
    @data[x + y * @xsize + z * @xsize * @ysize] = v
  end

  def _dump(d = 0)
    s = [@dim, @xsize, @ysize, @zsize, @xsize * @ysize * @zsize].pack('LLLLL')
    a = []
    ta = []
    @data.each do |d|
      if d.is_a?(Fixnum) && (d < 32768 && d >= 0)
        s << [d].pack("S")
      else
        s << [ta].pack("S#{ta.size}")
        ni = a.size
        a << d
        s << [0x8000|ni].pack("S")
      end
    end
    if a.size > 0
      s << Marshal.dump(a)
    end
    s
  end

  def self._load(s)
    size, nx, ny, nz, items = *s[0, 20].unpack('LLLLL')
    t = Table.new(*[nx, ny, nz].first(size))
    d = s[20, items * 2].unpack("S#{items}")
    tail_offset = 20 + items * 2
    if s.length > tail_offset
      a = Marshal.load(s[tail_offset..-1])
      d.collect! do |i|
        if i & 0x8000 == 0x8000
          a[i&~0x8000]
        else
          i
        end
      end
    end
    t.data = d
    t
  end

  private

  def init_attr(x, y, z)
    @dim = 1 + (y > 0 ? 1 : 0) + (z > 0 ? 1 : 0)
    @xsize = x
    @ysize = [y, 1].max
    @zsize = [z, 1].max
  end
end
