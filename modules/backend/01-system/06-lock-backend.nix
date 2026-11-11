{ self, inputs, ... }: {

  flake.modules.nixos.system-lock-backend =
    {
      config,
      lib,
      pkgs,
      ...
    }:

    let
      u2fModes = {
        "security-key-only" = "or";
        "second-factor" = "and";
      };
    in
    {

      options.ojuny.dux.u2fMode = lib.mkOption {
        type = lib.types.enum (lib.attrNames u2fModes);
        default = "security-key-only";
        description = "DMS u2fMode.";
      };

      options.ojuny.authentication.fingerprint.enable = lib.mkEnableOption "fingerprint authentication";

      config = {

        desktop.ojuny.dux.settings.enableFprint = config.ojuny.authentication.fingerprint.enable;

        desktop.ojuny.dux.settings.u2fMode = u2fModes.${config.ojuny.dux.u2fMode};

        services.fprintd.enable = config.ojuny.authentication.fingerprint.enable;

        environment.systemPackages = lib.mkIf config.ojuny.authentication.fingerprint.enable [
          pkgs.fprintd
          pkgs.libfprint
          (pkgs.writeShellApplication {
            name = "ojuny-fingerprint-detect";
            runtimeInputs = [ pkgs.coreutils pkgs.fprintd ];
            text = ''
              exec fprintd-list "$(id -un)"
            '';
          })
        ];

        security.pam.services = lib.mkIf config.ojuny.authentication.fingerprint.enable {
          login.fprintAuth = true;
          greetd.fprintAuth = true;
          sudo.fprintAuth = true;
          "polkit-1".fprintAuth = true;
          dankshell.fprintAuth = true;
        };

      };
    };

}
