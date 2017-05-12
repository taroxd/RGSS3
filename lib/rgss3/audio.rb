module Audio

  module_function

  def setup_midi
  end

  def bgm_play(filename, volume = 100, pitch = 100, pos = 0)
    bgm_stop
    @bgm = Gosu::Sample.new(filename).play(volume / 100.0, pitch / 100.0, true)
    @bgm_volume = volume / 100.0
  end

  def bgm_stop
    @bgm.stop if @bgm
  end

  def bgm_fade(time)
    bgm_stop
    # return unless @bgm
    # Thread.new {
    #   incs = @bgm_volume / time
    #   until @bgm_volume <= 0
    #     @bgm_volume -= incs
    #     @bgm.volume -= incs
    #     sleep 0.01
    #   end
    #   bgm_stop
    # }
  end

  def bgm_pos
    0 # Incapable of integration at the time
  end

  def bgs_play(filename, volume = 100, pitch = 100, pos = 0)
    bgs_stop
    @bgs = Gosu::Sample.new(filename).play(volume / 100.0, pitch / 100.0, true)
    @bgs_volume = volume / 100.0
  end

  def bgs_stop
    @bgs.stop if @bgs
  end

  def bgs_fade(time)
    bgs_stop
    # return unless @bgs
    # Thread.new {
    #   incs = @bgs_volume / time
    #   until @bgs_volume <= 0
    #     @bgs_volume -= incs
    #     @bgs.volume -= incs
    #     sleep 0.01
    #   end
    #   bgs_stop
    # }
  end

  def bgs_pos
    0 # Incapable of integration at the time
  end

  def me_play(filename, volume = 100, pitch = 100)
    me_stop
    @bgm.pause if @bgm
    @me = Gosu::Sample.new(filename).play(volume / 100.0, pitch / 100.0, false)
    @me_volume = volume / 100.0
  end

  def me_stop
    @me.stop if @me
    @bgm.resume if @bgm && @bgm.paused?
  end

  def me_fade(time)
    me_stop
    # return unless @me
    # Thread.new {
    #   incs = @me_volume / time
    #   until @me_volume <= 0
    #     @me_volume -= incs
    #     @me.volume -= incs
    #     sleep 0.01
    #   end
    #   me_stop
    # }
  end

  def se_play(filename, volume = 100, pitch = 100)
    Gosu::Sample.new(filename).play(volume / 100.0, pitch / 100.0, false)
  end

  def se_stop
  end
end
