/*
  @menu
  displayname = "Mounts";
  icon = "drive-harddisk-symbolic";
  order = 75;
  description = "Additional drives, filesystem tools and external media";
  category = "07-System";
*/

{ self, inputs, ... }: {

  flake.modules.nixos.system-mounts =
    { config, lib, pkgs, ... }:

    {
      options.ojuny.mounts.passwordless = lib.mkEnableOption "passwordless mounting of removable media";

      options.ojuny.mounts.syncWrites = lib.mkEnableOption "synchronous writes on removable media";

      options.ojuny.mounts.disableWriteCache = lib.mkEnableOption "disabling the write cache on external drives";

      config = {
        # @option widget = "mounts"; label = "Additional mounts"; group = "Mounts"; groupOrder = 10; description = "Internal data disks and partitions. The generated nix uses UUIDs. The core filesystems stay in the generated hardware module.";
        fileSystems = { };

        # @option widget = "switch"; label = "Mount removable media automatically"; group = "External media"; groupOrder = 20; description = "Runs devmon, which mounts removable media when it is inserted.";
        services.devmon.enable = true;

        systemd.user.services.devmon.unitConfig.ConditionUser = "!greeter";

        # @option widget = "switch"; label = "Disk service"; group = "External media"; groupOrder = 20; description = "udisks2 handles mounting, unmounting and filesystem operations for removable media.";
        services.udisks2.enable = true;

        # @option widget = "switch"; label = "File browser integration"; group = "External media"; groupOrder = 20; description = "gvfs exposes removable media and network locations to file browsers.";
        services.gvfs.enable = true;

        # @option widget = "switch"; label = "Synchronous writes on removable media"; group = "External media"; groupOrder = 20; description = "Mounts USB filesystems with the sync option, so a returned copy is already written to the device. Slower writes to external media.";
        ojuny.mounts.syncWrites = true;

        # @option widget = "switch"; label = "Disable write cache on external drives"; group = "External media"; groupOrder = 20; description = "Runs hdparm -W0 on USB disks at hotplug, so the drive cache does not hold data. Devices that reject the command keep their cache.";
        ojuny.mounts.disableWriteCache = true;

        # @option widget = "switch"; label = "Mount removable media without a password"; group = "External media"; groupOrder = 20; description = "Adds a polkit rule for active local sessions.";
        ojuny.mounts.passwordless = true;

        # @option widget = "switch"; label = "Periodic TRIM"; group = "Maintenance"; groupOrder = 30; description = "Runs fstrim on a timer. A per-mount discard option is the alternative.";
        services.fstrim.enable = true;

        # @option widget = "switch"; label = "btrfs scrub"; group = "Maintenance"; groupOrder = 30; description = "Runs a scheduled btrfs scrub.";
        services.btrfs.autoScrub.enable = false;

        security.polkit.extraConfig = lib.mkIf config.ojuny.mounts.passwordless ''
          polkit.addRule(function(action, subject) {
            if ((action.id == "org.freedesktop.udisks2.filesystem-mount" ||
                 action.id == "org.freedesktop.udisks2.filesystem-mount-system") &&
                subject.active && subject.local) {
              return polkit.Result.YES;
            }
          });
        '';

        boot.supportedFilesystems = [ "exfat" "ntfs" "f2fs" ];

        environment.systemPackages = with pkgs; [
          btrfs-progs
          cryptsetup
          dosfstools
          e2fsprogs
          exfatprogs
          f2fs-tools
          hdparm
          ntfs3g
          rsync
          util-linux
          xfsprogs
        ];

        services.udev.extraRules =
          lib.optionalString config.ojuny.mounts.syncWrites ''
            ACTION=="add|change", SUBSYSTEM=="block", SUBSYSTEMS=="usb", ENV{ID_FS_USAGE}=="filesystem", ENV{UDISKS_MOUNT_OPTIONS_DEFAULTS}="sync"
          ''
          + lib.optionalString config.ojuny.mounts.disableWriteCache ''
            ACTION=="add|change", SUBSYSTEM=="block", KERNEL=="sd*", ENV{DEVTYPE}=="disk", SUBSYSTEMS=="usb", RUN+="${pkgs.hdparm}/bin/hdparm -q -W0 /dev/%k"
          '';
      };
    };

}
