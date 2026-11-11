/*
  @menu
  displayname = "Audio";
  icon = "audio-card-symbolic";
  order = 25;
  description = "PipeWire audio server, clock and JACK compatibility";
  category = "02-Core";
*/

{ self, inputs, ... }: {

  flake.modules.nixos.desktop-audio =
    { ... }:
    {
      imports = [ self.modules.nixos.desktop-audio-backend ];

      config = {

          # @option widget = "switch"; label = "PipeWire audio"; group = "Audio"; groupOrder = 10; order = 10; description = "Run PipeWire as the audio server with ALSA and PulseAudio compatibility.";
          ojuny.audio.enable = true;

          # @option widget = "dropdown"; label = "Sample rate"; group = "Audio"; groupOrder = 10; order = 20; choices = [ "44100" "48000" "88200" "96000" ]; visibleWhen.path = "ojuny.audio.enable"; visibleWhen.equals = true; description = "Default PipeWire clock rate. 48000 is the normal desktop default.";
          ojuny.audio.sampleRate = 48000;

          # @option widget = "spin"; label = "Quantum"; group = "Audio"; groupOrder = 10; order = 30; min = 32; max = 2048; step = 32; visibleWhen.path = "ojuny.audio.enable"; visibleWhen.equals = true; description = "Default PipeWire buffer size in frames. 1024 is safe for desktop use; lower values reduce latency.";
          ojuny.audio.quantum = 1024;

          # @option widget = "switch"; label = "JACK compatibility"; group = "Audio"; groupOrder = 20; order = 10; visibleWhen.path = "ojuny.audio.enable"; visibleWhen.equals = true; description = "Provide the PipeWire JACK emulation layer. Do not enable a separate jackd service.";
          ojuny.audio.jack = false;

      };
    };

}
