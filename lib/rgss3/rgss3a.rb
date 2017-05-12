module RGSSAD

  @@files = []
  @@xor = 0xDEADCAFE
  @@rgss3a_xor = 0
  @@orig_xor = 0
  ENC_FILE = Dir["Game.rgss{ad,2a,3a}"][0] || ""
  RGSSAD_File = Struct.new('RGSSAD_File', :filename, :filename_size, :file, :file_size)

  public

  def self.decrypt
    return unless File.exists?(ENC_FILE)
    @@files.clear
    rgssad = ''
    File.open(ENC_FILE, 'rb') {|file|
      file.read(8)
      @@orig_xor = file.read(4).unpack('L*') * 9 + 3 if ENC_FILE == "Game.rgss3a"
      rgssad = file.read
    }
    rgssad = self.parse_rgssad(rgssad, true)
    offset = 0
    while rgssad[offset] != nil
      file = RGSSAD_File.new
      file.filename_size = rgssad[offset, 4].unpack('L')[0]
      offset += 4
      file.filename = rgssad[offset, file.filename_size]
      offset += file.filename_size
      file.file_size = rgssad[offset, 4].unpack('L')[0]
      offset += 4
      file.file = rgssad[offset, file.file_size]
      @@files << file
      offset += file.file_size
    end
  end

  def self.files
    @@files
  end

  def self.add_file(file_contents, filename)
    file = RGSSAD_File.new
    file.filename = filename
    file.filename_size = filename.size
    file.file = file_contents
    file.file_size = file_contents.size
    @@files.delete_if {|f| f.filename == file.filename}
    @@files << file
    @@files.sort! {|a,b| a.filename <=> b.filename}
  end

  def self.encrypt
    return if @@files.empty? && !File.exists?(ENC_FILE)
    rgssad = ''
    @@files.each do |file|
      rgssad << [file.filename_size].pack('L')
      rgssad << file.filename
      rgssad << [file.file_size].pack('L')
      rgssad << file.file
    end
    File.open(ENC_FILE, 'wb') do |file|
      file.print("RGSSAD\0\1")
      file.print(self.parse_rgssad(rgssad, false))
    end
  end

  private

  def self.next_key
    if ENC_FILE == "Game.rgss3a"
      @@rgss3a_xor = (@@rgss3a_xor * 7 + 3) & 0xFFFFFFFF
    else
      @@xor = (@@xor * 7 + 3) & 0xFFFFFFFF
    end
  end

  def self.used_xor
    ENC_FILE == "Game.rgss3a" ? @@rgss3a_xor : @@xor
  end

  def self.parse_rgssad(string, decrypt)
    @@xor = 0xDEADCAFE
    @@rgss3a_xor = @@orig_xor
    new_string = ''
    offset = 0
    remember_offsets = []
    remember_keys = []
    remember_size = []
    while string[offset] != nil
      namesize = string[offset, 4].unpack('L')[0]
      new_string << [namesize ^ used_xor].pack('L')
      namesize ^= used_xor if decrypt
      offset += 4
      self.next_key
      filename = string[offset, namesize]
      namesize.times do |i|
        filename.setbyte(i, filename.getbyte(i) ^ used_xor & 0xFF)
        self.next_key
      end
      new_string << filename
      offset += namesize
      datasize = string[offset, 4].unpack('L')[0]
      new_string << [datasize ^ used_xor].pack('L')
      datasize ^= used_xor if decrypt
      remember_size << datasize
      offset += 4
      self.next_key
      data = string[offset, datasize]
      new_string << data
      remember_offsets << offset
      remember_keys << used_xor
      offset += datasize
    end
    remember_offsets.size.times do |i|
      offset = remember_offsets[i]
      used_xor = remember_keys[i]
      size = remember_size[i]
      data = new_string[offset, size]
      data = data.ljust(size + (4 - size % 4)) if size % 4 != 0
      s = ''
      data.unpack('L' * (data.size / 4)).each do |j|
        s << ([j ^ used_xor].pack('L'))
        self.next_key
      end
      new_string[offset, size] = s.slice(0, size)
    end
    return new_string
  end
end
