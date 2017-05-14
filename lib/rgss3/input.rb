# frozen_string_literal: true
# Usage:
# Input.trigger?(2)
# Input.trigger?(:DOWN)
# Input.trigger?(Input::KB_DOWN)
# Input.trigger?(Input::Key[Gosu::KB_DOWN])
module Input

  include Gosu

  KEY_TO_INT = {
    DOWN: 2,
    LEFT: 4,
    RIGHT: 6,
    UP: 8,

    A: 11,
    B: 12,
    C: 13,
    X: 14,
    Y: 15,
    Z: 16,
    L: 17,
    R:  18,

    SHIFT: 21,
    CTRL: 22,
    ALT: 23,

    F5: 25,
    F6: 26,
    F7: 27,
    F8: 28,
    F9: 29
  }

  KEY_TO_INT_PROC = KEY_TO_INT.to_proc

  KEY_TO_INT.each_key do |sym|
    const_set sym, sym
  end

  KEY_MAPPER = {
    KB_ENTER => C,
    KB_LEFT_SHIFT => [SHIFT, A],
    KB_RIGHT_SHIFT => [SHIFT, A],
    KB_LEFT_CONTROL => CTRL,
    KB_RIGHT_CONTROL => CTRL,
    KB_LEFT_ALT => ALT,
    KB_RIGHT_ALT => ALT,
    KB_SPACE => C,
    KB_ESCAPE => B,
    KB_DOWN => DOWN,
    KB_LEFT => LEFT,
    KB_RIGHT => RIGHT,
    KB_UP => UP,
    KB_INSERT => B,
    KB_NUMPAD_0 => B,
    KB_NUMPAD_2 => DOWN,
    KB_NUMPAD_4 => LEFT,
    KB_NUMPAD_6 => RIGHT,
    KB_NUMPAD_8 => UP,
    KB_F5 => F5,
    KB_F6 => F6,
    KB_F7 => F7,
    KB_F8 => F8,
    KB_F9 => F9,
    KB_Z => C,
    KB_X => B,
    KB_A => X,
    KB_S => Y,
    KB_D => Z,
    KB_Q => L,
    KB_W => R
  }.freeze

  REVERSE_KEY_MAPPER = {}

  KEY_MAPPER.each do |kb_key, syms|
    keys = Array(syms).map(&KEY_TO_INT_PROC)
    keys.each do |key|
      REVERSE_KEY_MAPPER[key] ||= []
      REVERSE_KEY_MAPPER[key].push(kb_key)
    end
  end

  REVERSE_KEY_MAPPER.freeze

  # A wrapper for Gosu::KB_****
  # can be used as argument for methods in Input
  Key = Struct.new(:kb_key)

  Gosu.constants.each do |sym|
    if sym[0, 3] == :KB_
      kb_key = Gosu.const_get(sym)
      const_set sym, Key[kb_key].freeze
    end
  end

  # stores pressed times of each key
  @states = Hash.new { |h, k| h[k] = 0 }
  @dir_4_8 = [5, 5]

  def self.update
    @states.each_key do |kb_key|
      @states[kb_key] = RGSS3.window.button_down?(kb_key) ? @states[kb_key] + 1 : 0
    end
    @dir_4_8 = calculate_dir_4_8
  end

  def self.trigger?(key)
    presstime?(key) { |t| t == 1 }
  end

  def self.press?(key)
    presstime?(key, &:positive?)
  end

  def self.repeat?(key)
    presstime?(key) { |t| t == 1 || t > 23 && t % 6 == 0 }
  end

  def self.dir4
    @dir_4_8[0]
  end

  def self.dir8
    @dir_4_8[1]
  end

  private

  def self.presstime?(arg)
    arg = KEY_TO_INT[arg] if arg.is_a?(Symbol)
    arg = REVERSE_KEY_MAPPER[arg] if arg.is_a?(Integer)
    arg = [arg.kb_key] if arg.is_a?(Key)
    return false unless arg
    arg.any? { |kb_key| yield @states[kb_key] }
  end

  def self.calculate_dir_4_8
    min_presstime = Float::INFINITY
    dir4 = 5
    dir8 = [2, 4, 6, 8].inject(5) do |dir, dir_checking|
      presstime = REVERSE_KEY_MAPPER[dir_checking].map(&@states).select(&:positive?).min
      if presstime
        if presstime < min_presstime
          dir4 = dir_checking
          presstime = min_presstime
        end
        dir + dir_checking - 5
      else
        dir
      end
    end
    return 0, 0 if dir8 == 5
    return dir8, dir8 if [2, 4, 6, 8].include?(dir8)
    return dir4, dir8
  end
end
