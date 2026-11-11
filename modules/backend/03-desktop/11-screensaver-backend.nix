{ self, inputs, ... }: {

  flake.modules.nixos.desktop-screensaver-backend =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.ojuny.screensaver;
    in
    {
      options.ojuny.screensaver = {
        enable = lib.mkEnableOption "the ASCII screensaver";
        idleSeconds = lib.mkOption {
          type = lib.types.int;
          default = 120;
        };
        terminal = lib.mkOption {
          type = lib.types.str;
          default = "foot --app-id=org.ojuny.screensaver";
        };
        command = lib.mkOption {
          type = lib.types.str;
          default = "${pkgs.cmatrix}/bin/cmatrix -b";
        };
      };

      config = {
        environment.systemPackages = lib.mkIf cfg.enable (
          with pkgs;
          [
            cmatrix
            foot
            swayidle
            (writeShellScriptBin "ojuny-screensaver" ''
              set -euo pipefail
              pid_file="''${XDG_RUNTIME_DIR:-/tmp}/ojuny-screensaver.pid"
              case "''${1:-start}" in
                start)
                  [ -f "$pid_file" ] && exit 0
                  ${cfg.terminal} ${lib.getExe pkgs.bash} -c ${lib.escapeShellArg cfg.command} &
                  echo "$!" > "$pid_file"
                  ;;
                stop)
                  [ -f "$pid_file" ] || exit 0
                  kill "$(cat "$pid_file")" 2>/dev/null || true
                  rm -f "$pid_file"
                  ;;
              esac
            '')
          ]
        );

        desktop.ojuny.mango.rules.window_rule = lib.mkIf cfg.enable [
          {
            app_id = "org.ojuny.screensaver";
            is_fullscreen = 1;
            is_floating = 1;
            no_animation = 1;
            focused_opacity = 1.0;
            unfocused_opacity = 1.0;
          }
        ];

        desktop.ojuny.mango.execOnce = lib.mkIf cfg.enable [
          "${pkgs.swayidle}/bin/swayidle -w timeout ${toString cfg.idleSeconds} 'ojuny-screensaver start' resume 'ojuny-screensaver stop'"
        ];
      };
    };

  flake.modules.homeManager.desktop-screensaver =
    {
      lib,
      osConfig ? { },
      ...
    }:
    {
      config = lib.mkIf (osConfig.ojuny.screensaver.enable or false) {
        programs.foot.enable = true;
      };
    };
}
