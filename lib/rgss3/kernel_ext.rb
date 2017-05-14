# frozen_string_literal: true
module ::Kernel

  def rgss_main#(&block)
    begin
      yield
    rescue RGSSReset
      retry
    end
  end

  def rgss_stop
    loop { Graphics.update }
  end

  def load_data(filename)
    # RGSSAD.files {|a|
    #   if a.filename == filename
    #     return Marshal.load(a)
    #   end
    # }
    File.open(filename, "rb") { |f|
      Marshal.load(f)
    }
  end

  def save_data(obj, filename)
    File.open(filename, "wb") do |f|
      Marshal.dump(obj, f)
    end
  end

  def msgbox(*args)
  end

  def msgbox_p(*args)
  end
end
