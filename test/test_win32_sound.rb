##########################################################################
# test_win32_sound.rb
#
# Test suite for the win32-sound library. You should run this test case
# via the 'rake test' task.
##########################################################################
require 'test-unit'
require 'win32/sound'
include Win32

class TC_Win32_Sound < Test::Unit::TestCase
  def setup
    @wav = "c:\\windows\\media\\chimes.wav"
  end

  test "version constant is set to expected value" do
    assert_equal('0.6.0', Sound::VERSION)
  end

  def test_beep
    assert_respond_to(Sound, :beep)
    assert_nothing_raised{ Sound.beep(55, 100) }
  end

  def test_beep_expected_errors
    assert_raises(ArgumentError){ Sound.beep(0, 100) }
    assert_raises(ArgumentError){ Sound.beep }
    assert_raises(ArgumentError){ Sound.beep(500) }
    assert_raises(ArgumentError){ Sound.beep(500, 500, 5) }
  end

  def test_devices
    assert_respond_to(Sound, :devices)
    assert_nothing_raised{ Sound.devices }
    assert_kind_of(Array,Sound.devices)
  end

  def test_stop
    assert_respond_to(Sound, :stop)
    assert_nothing_raised{ Sound.stop }
    assert_nothing_raised{ Sound.stop(true) }
  end

  def test_get_volume_basic
    assert_respond_to(Sound, :wave_volume)
    assert_respond_to(Sound, :get_wave_volume)
    assert_nothing_raised{ Sound.get_wave_volume }
  end

  def test_get_volume
    assert_kind_of(Array, Sound.get_wave_volume)
    assert_equal(2, Sound.get_wave_volume.length)
  end

  def test_set_volume
    assert_respond_to(Sound, :set_wave_volume)
    assert_nothing_raised{ Sound.set_wave_volume(30000) } # About half
    assert_nothing_raised{ Sound.set_wave_volume(30000, 30000) }
  end

  def test_play
    assert_respond_to(Sound, :play)
    assert_nothing_raised{ Sound.play(@wav) }
  end

  def test_play_alias
    assert_nothing_raised{ Sound.play('SystemAsterisk', Sound::ALIAS) }
  end

  def test_expected_errors
    assert_raises(ArgumentError){ Sound.beep(-1, 1) }
  end

  test "expected constants are defined" do
    assert_not_nil(Sound::ALIAS)
    assert_not_nil(Sound::APPLICATION)
    assert_not_nil(Sound::ASYNC)
    assert_not_nil(Sound::FILENAME)
    assert_not_nil(Sound::LOOP)
    assert_not_nil(Sound::MEMORY)
    assert_not_nil(Sound::NODEFAULT)
    assert_not_nil(Sound::NOSTOP)
    assert_not_nil(Sound::NOWAIT)
    assert_not_nil(Sound::PURGE)
    assert_not_nil(Sound::SYNC)
  end

  test "ffi functions are private" do
    assert_not_respond_to(Sound, :Beep)
    assert_not_respond_to(Sound, :waveOutSetVolume)
    assert_not_respond_to(Sound, :waveOutGetVolume)
    assert_not_respond_to(Sound, :waveOutGetNumDevs)
    assert_not_respond_to(Sound, :waveInGetNumDevs)
    assert_not_respond_to(Sound, :midiInGetNumDevs)
    assert_not_respond_to(Sound, :midiOutGetNumDevs)
    assert_not_respond_to(Sound, :auxGetNumDevs)
    assert_not_respond_to(Sound, :mixerGetNumDevs)
    assert_not_respond_to(Sound, :waveOutOpen)
    assert_not_respond_to(Sound, :waveOutPrepareHeader)
    assert_not_respond_to(Sound, :waveOutWrite)
    assert_not_respond_to(Sound, :waveOutUnprepareHeader)
    assert_not_respond_to(Sound, :waveOutClose)
  end

  def teardown
    @wav = nil
  end
end
