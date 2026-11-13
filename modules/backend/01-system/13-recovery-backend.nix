{ self, inputs, ... }: {

  flake.modules.nixos.system-recovery-backend =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.ojuny.recovery;

      bootMountPoint = config.boot.loader.efi.efiSysMountPoint;
      recoveryDir = "${bootMountPoint}/EFI/ojuny/recovery";
      recoveryFile = "${recoveryDir}/ojuny-recovery.efi";
      manifest = "/var/lib/ojuny/recovery.json";

      ukify = self.packages.${pkgs.system}.ojuny-ukify;

      recovery = pkgs.writeShellApplication {
        name = "ojuny-recovery";
        runtimeInputs = with pkgs; [
          coreutils
          findutils
          gawk
          gnugrep
          gnused
          jq
          sbctl
          util-linux
        ];
        text = builtins.readFile ./recovery-uki.sh;
      };

      cleanup = pkgs.writeShellApplication {
        name = "ojuny-recovery-cleanup";
        runtimeInputs = with pkgs; [
          coreutils
          efibootmgr
          gawk
          gnugrep
          gnused
          sbctl
        ];
        text = builtins.readFile ./recovery-cleanup.sh;
      };

      pkiBundle =
        if config.boot.lanzaboote.pkiBundle == null then
          "/var/lib/sbctl"
        else
          toString config.boot.lanzaboote.pkiBundle;
    in
    {
      options.ojuny.recovery.enable = lib.mkEnableOption "the recovery UKI";

      config = lib.mkMerge [
        (lib.mkIf cfg.enable {
          systemd.services.ojuny-recovery = {
            description = "Build and install the Ojuny recovery UKI";
            wantedBy = [ "multi-user.target" ];
            after = [ "local-fs.target" ];
            before = [ "shutdown.target" ];
            unitConfig.ConditionPathExists = "/sys/firmware/efi";
            unitConfig.ConditionPathIsMountPoint = bootMountPoint;
            environment = {
              OJUNY_BOOT_MOUNT = bootMountPoint;
              OJUNY_RECOVERY_DIR = recoveryDir;
              OJUNY_RECOVERY_FILE = recoveryFile;
              OJUNY_MANIFEST = manifest;
              OJUNY_PKI_BUNDLE = pkiBundle;
              OJUNY_UKIFY = "${ukify}/bin/ukify";
            };
            serviceConfig = {
              Type = "oneshot";
              RemainAfterExit = true;
              ExecStart = "${recovery}/bin/ojuny-recovery";
            };
          };

          system.activationScripts.ojuny-recovery = {
            deps = [ "specialfs" ];
            text = ''
              if [ -d /sys/firmware/efi ]; then
                OJUNY_BOOT_MOUNT=${lib.escapeShellArg bootMountPoint} \
                OJUNY_RECOVERY_DIR=${lib.escapeShellArg recoveryDir} \
                OJUNY_RECOVERY_FILE=${lib.escapeShellArg recoveryFile} \
                OJUNY_MANIFEST=${lib.escapeShellArg manifest} \
                OJUNY_PKI_BUNDLE=${lib.escapeShellArg pkiBundle} \
                OJUNY_UKIFY=${lib.escapeShellArg "${ukify}/bin/ukify"} \
                ${recovery}/bin/ojuny-recovery || true
              fi
            '';
          };
        })
        (lib.mkIf (!cfg.enable) {
          systemd.services.ojuny-recovery-cleanup = {
            description = "Remove the Ojuny recovery UKI";
            wantedBy = [ "multi-user.target" ];
            after = [ "local-fs.target" ];
            before = [ "shutdown.target" ];
            unitConfig.ConditionPathExists = "/sys/firmware/efi";
            environment = {
              OJUNY_RECOVERY_DIR = recoveryDir;
              OJUNY_MANIFEST = manifest;
              OJUNY_SBCTL_CONF = "/var/lib/ojuny/sbctl.conf";
            };
            serviceConfig = {
              Type = "oneshot";
              RemainAfterExit = true;
              ExecStart = "${cleanup}/bin/ojuny-recovery-cleanup";
            };
          };
        })
      ];
    };

}
