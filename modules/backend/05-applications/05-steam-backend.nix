{ ... }: {

  flake.modules.nixos.applications-steam-backend =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      adwaitaForSteam = pkgs.fetchFromGitHub {
        owner = "tkashkin";
        repo = "Adwaita-for-Steam";
        rev = "e119cbdcdec6cd868a9c4afa47e6a5d6d348f342";
        hash = "sha256-BflUVdtuAEDhtoEkF9w0JntaKVUNud3prxMGDST+Tkk=";
      };

      steamTheme = pkgs.writeShellApplication {
        name = "ojuny-steam-theme";
        runtimeInputs = [ pkgs.coreutils pkgs.jq ];
        text = builtins.readFile ../../../scripts/ojuny-steam-theme.sh;
      };

      steam-gamescope = pkgs.writeShellScriptBin "steam-gamescope" ''
        if [ -z "''${XDG_SESSION_ID:-}" ]; then
          echo "steam-gamescope: XDG_SESSION_ID is not set" >&2
          exit 1
        fi
        deadline=$((SECONDS + 15))
        while [ "$(${config.systemd.package}/bin/loginctl show-session "$XDG_SESSION_ID" -p Active --value 2>/dev/null)" != "yes" ]; do
          if [ "$SECONDS" -ge "$deadline" ]; then
            echo "steam-gamescope: session $XDG_SESSION_ID did not become active" >&2
            exit 1
          fi
          sleep 0.2
        done
        exec gamescope --steam -- ${config.programs.steam.package}/bin/steam -tenfoot -pipewire-dmabuf
      '';

      gamescopeSessionFile =
        (pkgs.writeTextDir "share/wayland-sessions/steam.desktop" ''
          [Desktop Entry]
          Name=Steam
          Comment=A digital distribution platform
          DesktopNames=gamescope;Steam;
          Exec=${steam-gamescope}/bin/steam-gamescope
          Type=Application
        '').overrideAttrs
          (_: {
            passthru.providedSessions = [ "steam" ];
          });
    in
    {

      options.ojuny.steam = {
        compat = lib.mkEnableOption "Wine, winetricks, protontricks and gamescope";

        gamescopeSession = lib.mkEnableOption "the gamescope Steam session";

        protonGE = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Add Proton GE to Steam's compatibility tools.";
        };

        dxvkSarek = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "Add DW-Proton, which bundles DXVK-Sarek, to Steam's compatibility tools for older Vulkan 1.1 and 1.2 GPUs.";
        };

        extest = lib.mkEnableOption "the extest library for Steam Input on Wayland";

        autostart = lib.mkEnableOption "starting Steam at login";

        theme = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Install Millennium and the bundled Adwaita-for-Steam theme.";
        };

        themeName = lib.mkOption {
          type = lib.types.strMatching "[A-Za-z0-9._-]+";
          default = "Adwaita";
          description = "Millennium theme directory and active theme key.";
        };
      };

      options.ojuny.hardware.xpadneo = lib.mkEnableOption "the xpadneo driver for Xbox One and Series wireless controllers";

      config = {
        programs.steam.package =
          lib.mkIf config.ojuny.steam.theme (
            let
              stylixColor = name:
                let value = config.lib.stylix.colors.${name};
                in if lib.hasPrefix "#" value then value else "#" + value;
              steamStylixCss = pkgs.writeText "ojuny-steam-stylix.css" ''
                :root {
                  --adw-color-scheme: dark !important;
                  --adw-accent-bg-light: ${stylixColor "base0D"} !important;
                  --adw-accent-bg-dark: ${stylixColor "base0D"} !important;
                  --adw-accent-fg: ${stylixColor "base00"} !important;
                  --adw-destructive-bg-light: ${stylixColor "base08"} !important;
                  --adw-destructive-bg-dark: ${stylixColor "base08"} !important;
                  --adw-success-bg-light: ${stylixColor "base0B"} !important;
                  --adw-success-bg-dark: ${stylixColor "base0B"} !important;
                  --adw-warning-bg-light: ${stylixColor "base0A"} !important;
                  --adw-warning-bg-dark: ${stylixColor "base0A"} !important;
                  --adw-error-bg-light: ${stylixColor "base08"} !important;
                  --adw-error-bg-dark: ${stylixColor "base08"} !important;
                  --adw-window-bg: ${stylixColor "base00"} !important;
                  --adw-window-fg: ${stylixColor "base05"} !important;
                  --adw-view-bg: ${stylixColor "base01"} !important;
                  --adw-view-fg: ${stylixColor "base05"} !important;
                  --adw-headerbar-bg: ${stylixColor "base01"} !important;
                  --adw-headerbar-fg: ${stylixColor "base05"} !important;
                  --adw-headerbar-backdrop: ${stylixColor "base00"} !important;
                  --adw-sidebar-bg: ${stylixColor "base01"} !important;
                  --adw-sidebar-fg: ${stylixColor "base05"} !important;
                  --adw-sidebar-backdrop: ${stylixColor "base00"} !important;
                  --adw-secondary-sidebar-bg: ${stylixColor "base01"} !important;
                  --adw-secondary-sidebar-fg: ${stylixColor "base05"} !important;
                  --adw-secondary-sidebar-backdrop: ${stylixColor "base00"} !important;
                  --adw-card-bg: ${stylixColor "base01"} !important;
                  --adw-card-fg: ${stylixColor "base05"} !important;
                  --adw-dialog-bg: ${stylixColor "base02"} !important;
                  --adw-dialog-fg: ${stylixColor "base05"} !important;
                  --adw-popover-bg: ${stylixColor "base02"} !important;
                  --adw-popover-fg: ${stylixColor "base05"} !important;
                  --adw-thumbnail-bg: ${stylixColor "base01"} !important;
                  --adw-thumbnail-fg: ${stylixColor "base05"} !important;
                  --adw-shade: rgba(0, 0, 0, 0.36) !important;
                  --adw-banner: ${stylixColor "base03"} !important;
                  --adw-user-offline: ${stylixColor "base03"} !important;
                  --adw-user-online: ${stylixColor "base0B"} !important;
                  --adw-user-ingame: ${stylixColor "base0A"} !important;
                }
              '';
            in
            pkgs.steamWithMillennium.override {
              extraProfile = ''
                ${steamTheme}/bin/ojuny-steam-theme ${adwaitaForSteam} ${lib.escapeShellArg config.ojuny.steam.themeName} ${steamStylixCss}
              '';
            }
          );

        programs.steam.extest.enable = config.ojuny.steam.extest;

        # Derived, no @option: feeds Steam's compatibility tool list.
        programs.steam.extraCompatPackages =
          lib.optionals config.ojuny.steam.protonGE [ pkgs.proton-ge-bin ]
          ++ lib.optionals config.ojuny.steam.dxvkSarek [ pkgs.dwproton-bin ];

        programs.gamescope.enable = lib.mkIf (
          config.ojuny.steam.compat || config.ojuny.steam.gamescopeSession
        ) true;

        services.displayManager.sessionPackages = lib.optionals config.ojuny.steam.gamescopeSession [
          gamescopeSessionFile
        ];

        hardware.xpadneo.enable = config.ojuny.hardware.xpadneo;

        environment.systemPackages = lib.mkIf config.ojuny.steam.compat [
          pkgs.wineWow64Packages.stable
          pkgs.winetricks
          pkgs.protontricks
        ];
      };

    };

}
