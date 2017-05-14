# frozen_string_literal: true
module Audio

  def self.setup_midi
  end

  def self.bgm_play(filename, volume = 100, pitch = 100, pos = 0)
    bgm_stop
    @bgm = new_sample(filename).play(volume / 100.0, pitch / 100.0, true)
    @bgm_volume = volume / 100.0
  end

  def self.bgm_stop
    @bgm.stop if @bgm
  end

  def self.bgm_fade(time)
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

  def self.bgm_pos
    0 # Incapable of integration at the time
  end

  def self.bgs_play(filename, volume = 100, pitch = 100, pos = 0)
    bgs_stop
    @bgs = new_sample.play(volume / 100.0, pitch / 100.0, true)
    @bgs_volume = volume / 100.0
  end

  def self.bgs_stop
    @bgs.stop if @bgs
  end

  def self.bgs_fade(time)
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

  def self.bgs_pos
    0 # Incapable of integration at the time
  end

  def self.me_play(filename, volume = 100, pitch = 100)
    me_stop
    @bgm.pause if @bgm
    @me = new_sample.play(volume / 100.0, pitch / 100.0, false)
    @me_volume = volume / 100.0
  end

  def self.me_stop
    @me.stop if @me
    @bgm.resume if @bgm && @bgm.paused?
  end

  def self.me_fade(time)
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

  def self.se_play(filename, volume = 100, pitch = 100)
    new_sample(filename).play(volume / 100.0, pitch / 100.0, false)
  end

  def self.se_stop
  end

  private

  def self.new_sample(filename)
    filename = RGSS3::RTP.find!(filename, ['', '.ogg', '.wav', '.mp3', '.midi'])
    Gosu::Sample.new(filename)
  end
end
