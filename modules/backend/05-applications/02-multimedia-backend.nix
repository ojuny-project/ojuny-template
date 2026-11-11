{ ... }: {

  flake.modules.nixos.applications-multimedia-backend =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      viewerDesktop =
        {
          none = "satty.desktop";
          imv = "imv.desktop";
          qimgv = "qimgv.desktop";
          gwenview = "org.kde.gwenview.desktop";
        }
        .${config.ojuny.apps.multimedia.imageViewer} or null;

      playerDesktop =
        {
          mpv = "mpv.desktop";
          vlc = "vlc.desktop";
          haruna = "org.kde.haruna.desktop";
        }
        .${config.ojuny.apps.multimedia.player} or null;

      imageMimeTypes = [
        "image/png"
        "image/jpeg"
        "image/gif"
        "image/webp"
        "image/avif"
        "image/bmp"
        "image/tiff"
        "image/svg+xml"
        "image/heic"
        "image/heif"
        "image/jxl"
      ];

      videoMimeTypes = [
        "video/mp4"
        "video/x-matroska"
        "video/webm"
        "video/avi"
        "video/mpeg"
        "video/quicktime"
        "video/x-msvideo"
        "video/ogg"
        "video/x-flv"
        "video/3gpp"
        "video/x-ms-wmv"
        "video/mp2t"
      ];

      audioMimeTypes = [
        "audio/mpeg"
        "audio/x-flac"
        "audio/flac"
        "audio/wav"
        "audio/x-wav"
        "audio/ogg"
        "audio/aac"
        "audio/mp4"
        "audio/x-m4a"
        "audio/opus"
        "audio/webm"
        "audio/x-ms-wma"
        "audio/x-aiff"
        "audio/midi"
      ];

      imageDefaults = lib.mkIf (viewerDesktop != null) (
        lib.genAttrs imageMimeTypes (_: lib.mkDefault viewerDesktop)
      );

      videoDefaults = lib.mkIf (playerDesktop != null) (
        lib.genAttrs videoMimeTypes (_: lib.mkDefault playerDesktop)
      );

      audioDefaults = lib.mkIf (playerDesktop != null) (
        lib.genAttrs audioMimeTypes (_: lib.mkDefault playerDesktop)
      );
    in
    {
      options.ojuny.apps.multimedia = {
        player = lib.mkOption {
          type = lib.types.enum [
            "none"
            "mpv"
            "vlc"
            "haruna"
          ];
          default = "mpv";
          description = "Media player installed for local video and audio files.";
        };

        imageViewer = lib.mkOption {
          type = lib.types.enum [
            "none"
            "imv"
            "qimgv"
            "gwenview"
          ];
          default = "imv";
          description = "Image viewer installed for common image formats.";
        };

        obs = lib.mkEnableOption "OBS Studio";
        audacity = lib.mkEnableOption "Audacity";
        gimp = lib.mkEnableOption "GIMP";

        krita = lib.mkEnableOption "Krita";
        kdenlive = lib.mkEnableOption "Kdenlive";
        blender = lib.mkEnableOption "Blender";

        calculator = lib.mkOption {
          type = lib.types.enum [
            "none"
            "gnome-calculator"
            "qalculate-gtk"
          ];
          default = "none";
          description = "Calculator installed for quick arithmetic. No file type is associated with it.";
        };
      };

      config = {
        xdg.mime.defaultApplications = lib.mkMerge [
          imageDefaults
          videoDefaults
          audioDefaults
          (lib.mkIf config.ojuny.apps.multimedia.blender {
            "application/x-blender" = lib.mkDefault "blender.desktop";
            "model/obj" = lib.mkDefault "blender.desktop";
            "model/stl" = lib.mkDefault "blender.desktop";
            "model/gltf+json" = lib.mkDefault "blender.desktop";
            "model/gltf-binary" = lib.mkDefault "blender.desktop";
          })
          (lib.mkIf config.ojuny.apps.multimedia.krita {
            "application/x-krita" = lib.mkDefault "krita.desktop";
            "image/openraster" = lib.mkDefault "krita.desktop";
          })
          (lib.mkIf config.ojuny.apps.multimedia.gimp {
            "image/x-xcf" = lib.mkDefault "gimp.desktop";
            "image/x-compressed-xcf" = lib.mkDefault "gimp.desktop";
          })
          (lib.mkIf (config.ojuny.apps.multimedia.krita && !config.ojuny.apps.multimedia.gimp) {
            "image/vnd.adobe.photoshop" = lib.mkDefault "krita.desktop";
            "image/x-psd" = lib.mkDefault "krita.desktop";
          })
          (lib.mkIf (config.ojuny.apps.multimedia.gimp && !config.ojuny.apps.multimedia.krita) {
            "image/vnd.adobe.photoshop" = lib.mkDefault "gimp.desktop";
            "image/x-psd" = lib.mkDefault "gimp.desktop";
          })
        ];
      };
    };

  flake.modules.nixos.applications-multimedia-apps =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      gpu = config.ojuny.gpu or "none";
      nvidia = builtins.elem gpu [
        "nvidia"
        "hybrid-intel-nvidia"
        "hybrid-amd-nvidia"
      ];
      obsPackage = if nvidia then pkgs.obs-studio.override { cudaSupport = true; } else pkgs.obs-studio;
      viewerPackage =
        {
          imv = pkgs.imv;
          qimgv = pkgs.qimgv;
          gwenview = pkgs.kdePackages.gwenview;
        }
        .${config.ojuny.apps.multimedia.imageViewer} or null;
    in
    {
      environment.systemPackages =
        lib.optionals (config.ojuny.apps.multimedia.player == "mpv") [ pkgs.mpv ]
        ++ lib.optionals (config.ojuny.apps.multimedia.player == "vlc") [ pkgs.vlc ]
        ++ lib.optionals (config.ojuny.apps.multimedia.player == "haruna") [ pkgs.haruna ]
        ++ lib.optional (viewerPackage != null) viewerPackage
        ++ lib.optionals config.ojuny.apps.multimedia.obs [ obsPackage ]
        ++ lib.optionals config.ojuny.apps.multimedia.audacity [ pkgs.audacity ]
        ++ lib.optionals config.ojuny.apps.multimedia.gimp [ pkgs.gimp ]
        ++ lib.optionals config.ojuny.apps.multimedia.krita [ pkgs.krita ]
        ++ lib.optionals config.ojuny.apps.multimedia.kdenlive [ pkgs.kdenlive ]
        ++ lib.optionals config.ojuny.apps.multimedia.blender [ pkgs.blender ]
        ++ lib.optionals (config.ojuny.apps.multimedia.calculator == "gnome-calculator") [
          pkgs.gnome-calculator
        ]
        ++ lib.optionals (config.ojuny.apps.multimedia.calculator == "qalculate-gtk") [
          pkgs.qalculate-gtk
        ];
    };

  flake.modules.homeManager.applications-multimedia-player =
    {
      config,
      lib,
      pkgs,
      osConfig ? { },
      ...
    }:
    let
      player = osConfig.ojuny.apps.multimedia.player or "none";
    in
    {
      config = lib.mkIf (player == "mpv") {
        programs.mpv.enable = true;
        programs.mpv.package = pkgs.mpv;
        stylix.targets.mpv.enable = config.stylix.enable;
      };
    };

}
