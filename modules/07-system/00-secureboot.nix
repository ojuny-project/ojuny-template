/*
  @menu
  displayname = "Secure Boot";
  icon = "security-high-symbolic";
  order = 80;
  description = "Optional UEFI Secure Boot setup with Lanzaboote";
  category = "07-System";
*/

{ self, inputs, ... }: {

  flake.modules.nixos.system-secureboot =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      bootMountPoint =
        if config.boot.loader.systemd-boot.xbootldrMountPoint != null then
          config.boot.loader.systemd-boot.xbootldrMountPoint
        else
          config.boot.loader.efi.efiSysMountPoint;

      lanzabooteCleanup = pkgs.writeShellApplication {
        name = "ojuny-lanzaboote-cleanup";
        runtimeInputs = [ pkgs.coreutils ];
        text = builtins.readFile ../backend/01-system/lanzaboote-cleanup.sh;
      };
    in
    {
      imports = [ inputs.lanzaboote.nixosModules.lanzaboote ];

      # @option widget = "secureboot"; label = "Secure Boot";
      boot.lanzaboote.enable = false;

      boot.lanzaboote.pkiBundle = "/var/lib/sbctl";

      # @option widget = "switch"; label = "Other systems"; group = "Boot entries"; groupOrder = 10; order = 10; description = "Install a rEFInd helper on the boot partition and add an Other systems entry. The helper scans internal drives at every boot. Off by default. The installer enables it when another internal system is found.";
      ojuny.multiboot.enable = false;

      # @option widget = "switch"; label = "Enable recovery UKI"; group = "Boot entries"; groupOrder = 10; order = 20; description = "Build a signed recovery UKI and add an Ojuny Recovery firmware entry. It boots the installed system without systemd-boot or rEFInd.";
      ojuny.recovery.enable = true;

      environment.systemPackages = [ pkgs.sbctl ];

      systemd.services.ojuny-lanzaboote-cleanup = lib.mkIf (!config.boot.lanzaboote.enable) {
        description = "Remove stale Lanzaboote boot payloads";
        wantedBy = [ "multi-user.target" ];
        after = [ "local-fs.target" ];
        before = [ "shutdown.target" ];
        unitConfig.ConditionPathExists = "/sys/firmware/efi";
        unitConfig.ConditionPathIsMountPoint = bootMountPoint;
        environment.OJUNY_BOOT_MOUNT = bootMountPoint;
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          ExecStart = "${lanzabooteCleanup}/bin/ojuny-lanzaboote-cleanup";
        };
      };

      # Keep the condition on boot.lanzaboote.enable alone. Reading
      # config.boot.loader.grub.enable here recurses through systemd-boot's
      # own default that disables GRUB.
      boot.loader.systemd-boot.enable = lib.mkIf config.boot.lanzaboote.enable (lib.mkForce false);

      boot.loader.grub.enable = lib.mkIf config.boot.lanzaboote.enable (lib.mkForce false);

      assertions = [
        {
          assertion = !(config.boot.lanzaboote.enable && config.boot.loader.grub.enable);
          message = ''
            Secure Boot requires UEFI firmware and systemd-boot, but this install
            uses GRUB. Reinstall in UEFI mode with systemd-boot, or leave
            boot.lanzaboote.enable disabled.
          '';
        }
      ];
    };

}
