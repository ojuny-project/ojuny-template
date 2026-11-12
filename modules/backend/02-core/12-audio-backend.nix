{ self, inputs, ... }: {

  flake.modules.nixos.desktop-audio-backend =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.ojuny.audio;
    in
    {
      options.ojuny.audio = {
        enable = lib.mkEnableOption "PipeWire audio";

        sampleRate = lib.mkOption {
          type = lib.types.enum [
            44100
            48000
            88200
            96000
          ];
          default = 48000;
          description = "Default PipeWire clock rate.";
        };

        quantum = lib.mkOption {
          type = lib.types.ints.between 32 2048;
          default = 1024;
          description = "Default PipeWire quantum in frames. Lower values reduce latency at the cost of CPU and xrun risk.";
        };

        jack = lib.mkEnableOption "PipeWire JACK compatibility";
      };

      config = lib.mkIf cfg.enable {
        services.pulseaudio.enable = false;

        services.pipewire = {
          enable = true;

          audio.enable = true;

          alsa.enable = true;
          alsa.support32Bit = true;

          pulse.enable = true;

          jack.enable = cfg.jack;

          wireplumber.enable = true;

          extraConfig.pipewire."10-ojuny-clock" = {
            "context.properties" = {
              "default.clock.rate" = cfg.sampleRate;
              "default.clock.allowed-rates" = [ cfg.sampleRate ];
              "default.clock.quantum" = cfg.quantum;
              "default.clock.min-quantum" = 32;
              "default.clock.max-quantum" = 2048;
            };
          };
        };

        security.rtkit.enable = true;

        # The Sounds page switches the shell from its bundled cues to the
        # system theme. DMS reads the theme name from gsettings, so the theme
        # and its default name have to exist in the system profile.
        programs.dconf.enable = lib.mkDefault true;

        programs.dconf.profiles.user.databases = [
          {
            settings."org/gnome/desktop/sound" = {
              theme-name = "freedesktop";
              event-sounds = true;
            };
          }
        ];

        environment.systemPackages = with pkgs; [
          alsa-utils
          pavucontrol
          sound-theme-freedesktop
        ];
      };
    };

}
