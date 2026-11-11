{ ... }: {

  flake.modules.nixos.applications-steam-backend =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
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
      };

      options.ojuny.hardware.xpadneo = lib.mkEnableOption "the xpadneo driver for Xbox One and Series wireless controllers";

      config = {
        programs.steam.extest.enable = config.ojuny.steam.extest;

        # Derived, no @option: feeds Steam's compatibility tool list.
        programs.steam.extraCompatPackages =
          lib.optionals config.ojuny.steam.protonGE [ pkgs.proton-ge-bin ]
          ++ lib.optionals config.ojuny.steam.dxvkSarek [ pkgs.dwproton-bin ];

        programs.gamescope.enable = lib.mkIf (config.ojuny.steam.compat || config.ojuny.steam.gamescopeSession) true;

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
