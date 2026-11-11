{ ... }: {

  flake.modules.nixos.applications-appimage-backend =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.ojuny.appimage;

      commonPackages = with pkgs; [
        icu
        libxcrypt-legacy
        libnotify
        libva
        libva-utils
        libayatana-appindicator
        libappindicator-gtk3
        libxshmfence
      ];

      stylixPackages = lib.optionals config.stylix.enable (
        config.stylix.fonts.packages
        ++ lib.optional (config.stylix.icons.package != null) config.stylix.icons.package
        ++ lib.optional (config.stylix.cursor != null) config.stylix.cursor.package
        ++ [ pkgs.adw-gtk3 ]
      );

      runtimePackages = lib.unique (
        commonPackages ++ config.fonts.packages ++ stylixPackages ++ cfg.extraPackages
      );

      appimageRun = pkgs.appimage-run.override {
        extraPkgs = _: runtimePackages;
      };

      cursorTheme =
        if config.stylix.cursor != null then config.stylix.cursor.name else "default";

      cursorSize =
        if config.stylix.cursor != null then toString config.stylix.cursor.size else "24";

      appimageRunWrapped = pkgs.writeShellApplication {
        name = "appimage-run";
        text = ''
          export XDG_DATA_DIRS="/run/current-system/sw/share:''${XDG_DATA_HOME:-$HOME/.local/share}:$HOME/.nix-profile/share:''${XDG_DATA_DIRS:-/usr/local/share:/usr/share}"
          export XCURSOR_THEME="${cursorTheme}"
          export XCURSOR_SIZE="${cursorSize}"
          exec ${appimageRun}/bin/appimage-run "$@"
        '';
      };

      appimageDesktop = pkgs.makeDesktopItem {
        name = "ojuny-appimage";
        exec = "${appimageRunWrapped}/bin/appimage-run %f";
        desktopName = "AppImage";
        genericName = "AppImage runner";
        noDisplay = true;
        icon = "application-x-executable";
        mimeTypes = [
          "application/vnd.appimage"
          "application/x-iso9660-appimage"
        ];
        categories = [ "Utility" ];
      };
    in
    {
      options.ojuny.appimage = {
        enable = lib.mkEnableOption "AppImage support";

        binfmt = lib.mkEnableOption "binfmt registration for AppImage files";

        extraPackages = lib.mkOption {
          type = lib.types.listOf lib.types.package;
          default = [ ];
          description = "Packages added to the AppImage runtime environment. They are not installed system-wide; they are available only to AppImage applications.";
        };
      };

      config = {
        programs.appimage.enable = cfg.enable;
        programs.appimage.binfmt = cfg.binfmt;
        programs.appimage.package = appimageRunWrapped;

        environment.systemPackages = lib.mkIf cfg.enable [ appimageDesktop ];

        xdg.mime.defaultApplications = lib.mkIf cfg.enable {
          "application/vnd.appimage" = "ojuny-appimage.desktop";
          "application/x-iso9660-appimage" = "ojuny-appimage.desktop";
        };
      };
    };

}
