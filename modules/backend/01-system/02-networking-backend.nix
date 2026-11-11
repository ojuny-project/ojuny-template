{ self, inputs, ... }: {

  flake.modules.nixos.system-networking-backend =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.ojuny.vpn.wireguard;
      primaryUser =
        if config.users.users ? user then
          config.users.users.user
        else
          lib.findFirst (user: user.isNormalUser or false) null (lib.attrValues config.users.users);
      primaryUserName = primaryUser.name or "user";
      primaryHome = primaryUser.home or "/home/${primaryUserName}";
      watchDir = if cfg.directory != "" then cfg.directory else "${primaryHome}/.config/ojuny/wireguard";
      importScript = pkgs.writeShellApplication {
        name = "ojuny-wireguard-import";
        runtimeInputs = with pkgs; [
          coreutils
          gnugrep
          gawk
          networkmanager
        ];
        text = builtins.readFile ./wireguard-import.sh;
      };
      importSettings = pkgs.writeText "ojuny-wireguard-settings" "${toString cfg.autoconnect}:${cfg.autoconnectProfile}";
    in
    {
      options.ojuny.network.deploy-rs.enable = lib.mkEnableOption "deploy-rs and remote deployment";

      options.ojuny.networking.hosts = lib.mkOption {
        type = lib.types.listOf (
          lib.types.submodule {
            options = {
              address = lib.mkOption {
                type = lib.types.str;
                default = "";
                description = "IP address the host names resolve to.";
              };
              hostNames = lib.mkOption {
                type = lib.types.str;
                default = "";
                description = "Space-separated host names for the address.";
              };
            };
          }
        );
        default = [ ];
        description = "Static host entries written to networking.hosts.";
      };

      options.ojuny.vpn.wireguard = {
        enable = lib.mkEnableOption "automatic WireGuard profile import";
        directory = lib.mkOption {
          type = lib.types.str;
          default = "";
          description = "Directory watched for WireGuard .conf files. Empty uses ~/.config/ojuny/wireguard for the primary user.";
        };
        autoconnect = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "Connect one managed WireGuard profile at boot.";
        };
        autoconnectProfile = lib.mkOption {
          type = lib.types.str;
          default = "";
          description = "File basename of the profile to connect at boot. Empty uses the first profile.";
        };
      };

      config = {

        systemd.tmpfiles.rules = lib.mkIf cfg.enable [
          "d ${watchDir} 0700 ${primaryUserName} ${primaryUser.group or "users"} -"
        ];

        systemd.services.ojuny-wireguard-import = lib.mkIf cfg.enable {
          description = "Import WireGuard profiles from ${watchDir}";
          after = [ "NetworkManager.service" ];
          wants = [ "NetworkManager.service" ];
          wantedBy = [ "multi-user.target" ];
          restartTriggers = [
            importSettings
            importScript
          ];
          serviceConfig.Type = "oneshot";
          script = "${importScript}/bin/ojuny-wireguard-import ${lib.escapeShellArg watchDir} ${
            if cfg.autoconnect then "1" else "0"
          } ${lib.escapeShellArg cfg.autoconnectProfile}";
        };

        systemd.paths.ojuny-wireguard-import = lib.mkIf cfg.enable {
          wantedBy = [ "multi-user.target" ];
          pathConfig = {
            PathChanged = watchDir;
          };
        };

        # Derived from the table above; no @option.
        networking.hosts = lib.listToAttrs (
          map (entry: {
            name = entry.address;
            value = lib.filter (name: name != "") (lib.splitString " " entry.hostNames);
          }) config.ojuny.networking.hosts
        );

      };

    };

}
