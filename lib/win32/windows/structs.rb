require 'ffi'

module Windows
  module SoundStructs
    extend FFI::Library

    class HWAVEOUT < FFI::Struct
      layout :i, :int
    end

    # Define WAVEFORMATEX which defines the format (PCM in this case)
    # and various properties like sampling rate, number of channels, etc.
    class WAVEFORMATEX < FFI::Struct
      layout(
        :wFormatTag,      :ushort,
        :nChannels,       :ushort,
        :nSamplesPerSec,  :ulong,
        :nAvgBytesPerSec, :ulong,
        :nBlockAlign,     :ushort,
        :wBitsPerSample,  :ushort,
        :cbSize,          :ushort
      )
    end

    #define WAVEHDR which is a header to a block of audio
    #lpData is a pointer to the block of native memory that,
    # in this case, is an integer array of PCM data

    class WAVEHDR < FFI::Struct
      layout(
        :lpData,          :pointer,
        :dwBufferLength,  :ulong,
        :dwBytesRecorded, :ulong,
        :dwUser,          :ulong,
        :dwFlags,         :ulong,
        :dwLoops,         :ulong,
        :lpNext,          :pointer,
        :reserved,        :ulong
      )
    end
  end # SoundStructs
end # Windows
