# frozen_string_literal: true
module RGSS3
  module RTP
    class << self
      # The RTP path
      attr_accessor :path
    end

    # find file in current directory and RTP directory
    def self.find(basename, extnames)
      basename = basename.to_str
      extnames.each do |ext|
        filename = basename + ext
        if File.exist?(filename)
          return filename
        elsif @path && File.exist?(filename = File.absolute_path(filename, @path))
          return filename
        end
      end
      nil
    end

    # same as find, except that find! raise error when not found
    def self.find!(basename, extnames)
      result = find(basename, extnames)
      if result
        result
      else
        raise "File not found: #{basename}"
      end
    end
  end
end
