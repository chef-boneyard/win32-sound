require_relative 'windows/functions'
require_relative 'windows/structs'

# The Win32 module serves as a namespace only.
module Win32

  # The Sound class encapsulates various methods for playing sound as well
  # as querying or configuring sound related properties.
  class Sound
    include Windows::SoundStructs
    extend Windows::SoundFunctions

    # The version of the win32-sound library
    VERSION = '0.6.0'

    private

    LOW_FREQUENCY   = 37
    HIGH_FREQUENCY  = 32767
    MAX_VOLUME      = 0xFFFF
    WAVE_FORMAT_PCM = 1     # Waveform-audio data is PCM.
    WAVE_MAPPER     = -1    # Used by waveOutOpen.  The function selects
                            # a waveform-audio output device capable of
                            # playing the given format.

    public

    SYNC            = 0x00000000 # play synchronously (default)
    ASYNC           = 0x00000001 # play asynchronously
    NODEFAULT       = 0x00000002 # silence (!default) if sound not found
    MEMORY          = 0x00000004 # pszSound points to a memory file
    LOOP            = 0x00000008 # loop the sound until next sndPlaySound
    NOSTOP          = 0x00000010 # don't stop any currently playing sound
    NOWAIT          = 8192       # don't wait if the driver is busy
    ALIAS           = 65536      # name is a registry alias
    ALIAS_ID        = 1114112    # alias is a predefined ID
    FILENAME        = 131072     # name is file name
    RESOURCE        = 262148     # name is resource name or atom
    PURGE           = 0x00000040 # purge non-static events for task
    APPLICATION     = 0x00000080 # look for app specific association

    # Plays a frequency for a specified duration at a given volume.
    # Defaults are 440Hz, 1 second, full volume.
    #
    # The result is a single channel, 44100Hz sampled, 16 bit sine wave.
    # If multiple instances are plays in simultaneous threads, they
    # will be started and played at the same time.
    #
    # ex.: threads = []
    #      [440, 660].each do |freq|
    #        threads << Thread.new { Win32::Sound.play_freq(freq) }
    #      end
    #      threads.each { |th| th.join }
    #
    # The first frequency in this array (440) will wait until the
    # thread for 660 finished calculating its PCM array and they
    # will both start streaming at the same time.
    #
    # If immediate_playback is set to false, the thread will calculate
    # all pending PCM arrays and wait to be woken up again.  This
    # if useful for time-sensitive playback of notes in succession.
    #
    def self.play_freq(frequency = 440, duration = 1000, volume = 1, immediate_playback = true)

      if frequency > HIGH_FREQUENCY || frequency < LOW_FREQUENCY
        raise ArgumentError, 'invalid frequency'
      end

      if duration < 0 || duration > 5000
        raise ArgumentError, 'invalid duration'
      end

      if volume.abs > 1
        warn("WARNING: Volume greater than 1 will cause audio clipping.")
      end

      stream(immediate_playback) do |wfx|
        data = generate_pcm_integer_array_for_freq(frequency, duration, volume)
        data_buffer = FFI::MemoryPointer.new(:int, data.size)
        data_buffer.write_array_of_int data
        buffer_length = wfx[:nAvgBytesPerSec]*duration/1000
        WAVEHDR.new(data_buffer, buffer_length)
      end

    end

    # Returns an array of all the available sound devices; their names contain
    # the type of the device and a zero-based ID number. Possible return values
    # are WAVEOUT, WAVEIN, MIDIOUT, MIDIIN, AUX or MIXER.
    #
    def self.devices
      devs = []

      begin
        0.upto(waveOutGetNumDevs()){ |i| devs << "WAVEOUT#{i}" }
        0.upto(waveInGetNumDevs()){ |i| devs << "WAVEIN#{i}" }
        0.upto(midiOutGetNumDevs()){ |i| devs << "MIDIOUT#{i}" }
        0.upto(midiInGetNumDevs()){ |i| devs << "MIDIIN#{i}" }
        0.upto(auxGetNumDevs()){ |i| devs << "AUX#{i}" }
        0.upto(mixerGetNumDevs()){ |i| devs << "MIXER#{i}" }
      rescue Exception
        raise SystemCallError, FFI.errno, "GetNumDevs"
      end

      devs
    end

    # Generates simple tones on the speaker. The function is synchronous; it
    # does not return control to its caller until the sound finishes.
    #
    # The frequency (in Hertz) must be between 37 and 32767.
    # The duration is in milliseconds.
    #
    def self.beep(frequency, duration)
      if frequency > HIGH_FREQUENCY || frequency < LOW_FREQUENCY
        raise ArgumentError, 'invalid frequency'
      end

      if 0 == Beep(frequency, duration)
        raise SystemCallError, FFI.errno, "Beep"
      end

      self
    end

    # Stops any currently playing waveform sound. If +purge+ is set to
    # true, then *all* sounds are stopped. The default is false.
    #
    def self.stop(purge = false)
      if purge && purge != 0
        flags = PURGE
      else
        flags = 0
      end

      unless PlaySound(nil, 0, flags)
        raise SystemCallError, FFI.errno, "PlaySound"
      end

      self
    end

    # Plays the specified sound. The sound can be a wave file or a system
    # sound, when used in conjunction with the ALIAS flag.
    #
    # Valid flags:
    #
    # Sound::ALIAS
    #   The sound parameter is a system-event alias in the registry or the
    #   WIN.INI file. If the registry contains no such name, it plays the
    #   system default sound unless the NODEFAULT value is also specified.
    #   Do not use with FILENAME.
    #
    # Sound::APPLICATION
    #   The sound is played using an application-specific association.
    #
    # Sound::ASYNC
    #   The sound is played asynchronously and the function returns
    #   immediately after beginning the sound.
    #
    # Sound::FILENAME
    #   The sound parameter is the name of a WAV file.  Do not use with
    #   ALIAS.
    #
    # Sound::LOOP
    #   The sound plays repeatedly until Sound.stop() is called. You must
    #   also specify the ASYNC flag to loop sounds.
    #
    # Sound::MEMORY
    #   The sound points to an image of a waveform sound in memory.
    #
    # Sound::NODEFAULT
    #   If the sound cannot be found, the function returns silently without
    #   playing the default sound.
    #
    # Sound::NOSTOP
    #   If a sound is currently playing, the function immediately returns
    #   false without playing the requested sound.
    #
    # Sound::NOWAIT
    #   If the driver is busy, return immediately without playing the sound.
    #
    # Sound::PURGE
    #   Stop playing all instances of the specified sound.
    #
    # Sound::SYNC
    #   The sound is played synchronously and the function does not return
    #   until the sound ends.
    #
    # Examples:
    #
    #    require 'win32/sound'
    #    include Win32
    #
    #    # Play a wave file once
    #    Sound.play('some_file.wav')
    #
    #    # Play a wave file in an asynchronous loop for 2 seconds
    #    Sound.play('some_file.wav', Sound::ASYNC | Sound::LOOP)
    #    sleep 2
    #    Sound.stop
    #
    def self.play(sound, flags = 0)
      unless PlaySound(sound, 0, flags)
        raise SystemCallError, FFI.errno, "PlaySound"
      end

      self
    end

    # Sets the volume for the left and right channel. If the +right_channel+
    # is omitted, the volume is set for *both* channels.
    #
    # You may optionally pass a single Integer rather than an Array, in which
    # case it is assumed you are setting both channels to the same value.
    #
    def self.set_wave_volume(left_channel, right_channel = nil)
      right_channel ||= left_channel

      lvolume = left_channel > MAX_VOLUME ? MAX_VOLUME : left_channel
      rvolume = right_channel > MAX_VOLUME ? MAX_VOLUME : right_channel

      volume = lvolume | rvolume << 16

      if waveOutSetVolume(-1, volume) != 0
        raise SystemCallError, FFI.errno, "waveOutSetVolume"
      end

      self
    end

    # Returns a 2-element array that contains the volume for the left channel
    # and right channel, respectively.
    #
    def self.wave_volume
      ptr = FFI::MemoryPointer.new(:ulong)

      if waveOutGetVolume(-1, ptr) != 0
        raise SystemCallError, FFI.errno, "waveOutGetVolume"
      end

      volume = ptr.read_long

      [low_word(volume), high_word(volume)]
    end

    class << self
      alias get_wave_volume wave_volume
    end

    private

    def self.low_word(num)
      num & 0xFFFF
    end

    def self.high_word(num)
      num >> 16
    end

    # Sets up a ready-made waveOut stream to push a PCM integer array to.
    # It expects a block to be associated with the method call to which
    # it will yield an instance of WAVEFORMATEX that the block uses
    # to prepare a WAVEHDR to return to the function.
    #
    # The WAVEHDR can contain either a self-made PCM integer array
    # or an array from a wav file or some other audio file converted
    # to PCM.
    #
    # This function will take the entire PCM array and create one
    # giant buffer, so it is not intended for audio streams larger
    # than 5 seconds.
    #
    # In order to play larger audio files, you will have to use the waveOut
    # functions and structs to set up a double buffer to incrementally
    # push PCM data to.
    #
    def self.stream(immediate_playback)
      hWaveOut = HWAVEOUT.new
      wfx = WAVEFORMATEX.new

      wfx[:wFormatTag] = WAVE_FORMAT_PCM
      wfx[:nChannels] = 1
      wfx[:nSamplesPerSec] = 44100
      wfx[:wBitsPerSample] = 16
      wfx[:cbSize] = 0
      wfx[:nBlockAlign] = (wfx[:wBitsPerSample] >> 3) * wfx[:nChannels]
      wfx[:nAvgBytesPerSec] = wfx[:nBlockAlign] * wfx[:nSamplesPerSec]

      if ((error_code = waveOutOpen(hWaveOut.pointer, WAVE_MAPPER, wfx.pointer, 0, 0, 0)) != 0)
        raise SystemCallError.new('waveOutOpen', FFI.errno)
      end

      header = yield(wfx)

      if ((error_code = waveOutPrepareHeader(hWaveOut[:i], header.pointer, header.size)) != 0)
        raise SystemCallError.new('waveOutPrepareHeader', FFI.errno)
      end

      unless immediate_playback
        Thread.stop
        Thread.current[:sleep_time] ||= 0
        sleep Thread.current[:sleep_time]
      end
      Thread.pass

      if (waveOutWrite(hWaveOut[:i], header.pointer, header.size) != 0)
        raise SystemCallError.new('waveOutWrite', FFI.errno)
      end

      while (waveOutUnprepareHeader(hWaveOut[:i], header.pointer, header.size) == 33)
        sleep 0.1
      end

      if ((error_code = waveOutClose(hWaveOut[:i])) != 0)
        raise SystemCallError.new('waveOutClose', FFI.errno)
      end

      self
    end

    # Generates an array of PCM integers to play a particular frequency
    # It also ramps up and down the volume in the first and last
    # 200 milliseconds to prevent audio clicking.
    #
    def self.generate_pcm_integer_array_for_freq(freq, duration, volume)
      data = []
      ramp = 200.0
      samples = (44100/2*duration/1000.0).floor

      samples.times do |sample|

        angle = (2.0*Math::PI*freq) * sample/samples * duration/1000
        factor = Math.sin(angle)
        x = 32768.0*factor*volume

        if sample < ramp
          x *= sample/ramp
        end
        if samples - sample < ramp
          x *= (samples - sample)/ramp
        end

        data << x.floor
      end

      data
    end
  end # Sound
end # Win32
