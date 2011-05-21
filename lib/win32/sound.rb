require 'windows/sound'
require 'windows/error'

# The Win32 module serves as a namespace only.
module Win32

  # The Sound class encapsulates various methods for playing sound as well
  # as querying or configuring sound related properties.
  class Sound

    # The Win32::Sound::Error class is typically raised if any of the
    # Win32::Sound methods fail.
    class Error < StandardError; end

    include Windows::Sound
    include Windows::Error
    extend Windows::Sound
    extend Windows::Error

    # The version of the win32-sound library
    VERSION = '0.4.3'

    LOW_FREQUENCY  = 37
    HIGH_FREQUENCY = 32767
    MAX_VOLUME     = 0xFFFF

    SYNC           = SND_SYNC        # play synchronously (default)
    ASYNC          = SND_ASYNC       # play asynchronously
    NODEFAULT      = SND_NODEFAULT   # silence (!default) if sound not found
    MEMORY         = SND_MEMORY      # pszSound points to a memory file
    LOOP           = SND_LOOP        # loop the sound until next sndPlaySound
    NOSTOP         = SND_NOSTOP      # don't stop any currently playing sound
    NOWAIT         = SND_NOWAIT      # don't wait if the driver is busy
    ALIAS          = SND_ALIAS       # name is a registry alias
    ALIAS_ID       = SND_ALIAS_ID    # alias is a predefined ID
    FILENAME       = SND_FILENAME    # name is file name
    RESOURCE       = SND_RESOURCE    # name is resource name or atom
    PURGE          = SND_PURGE       # purge non-static events for task
    APPLICATION    = SND_APPLICATION # look for app specific association

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
        raise Error, get_last_error
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
        raise Error, 'invalid frequency'
      end

      if 0 == Beep(frequency, duration)
        raise Error, get_last_error
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

      unless PlaySound(0, 0, flags)
        raise Error, get_last_error
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
        raise Error, get_last_error
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
        raise Error, get_last_error
      end

      self
    end

    # Returns a 2-element array that contains the volume for the left channel
    # and right channel, respectively.
    def self.wave_volume
      volume = [0].pack('L')
      if waveOutGetVolume(-1, volume) != 0
        raise Error, get_last_error
      end
      volume = volume.unpack('L').first
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
  end
end
