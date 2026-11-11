{ ... }: {

  flake.modules.nixos.applications-office-backend =
    {
      config,
      lib,
      ...
    }:
    {
      options.ojuny.apps.obsidian = {
        enable = lib.mkEnableOption "the Obsidian note application";

        vaults = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [ ];
          description = "Vault names that receive per-vault Stylix theming.";
        };
      };

      config = lib.mkIf config.ojuny.apps.office.enable {
        xdg.mime.defaultApplications."application/vnd.oasis.opendocument.text-template" =
          "libreoffice-writer.desktop";

        xdg.mime.defaultApplications."application/msword" = "libreoffice-writer.desktop";

        xdg.mime.defaultApplications."application/rtf" = "libreoffice-writer.desktop";

        xdg.mime.defaultApplications."application/vnd.oasis.opendocument.spreadsheet-template" =
          "libreoffice-calc.desktop";

        xdg.mime.defaultApplications."application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" =
          "libreoffice-calc.desktop";

        xdg.mime.defaultApplications."application/vnd.ms-excel" = "libreoffice-calc.desktop";

        xdg.mime.defaultApplications."text/csv" = "libreoffice-calc.desktop";

        xdg.mime.defaultApplications."application/vnd.oasis.opendocument.formula" =
          "libreoffice-calc.desktop";

        xdg.mime.defaultApplications."application/vnd.oasis.opendocument.formula-template" =
          "libreoffice-calc.desktop";

        xdg.mime.defaultApplications."application/vnd.oasis.opendocument.presentation-template" =
          "libreoffice-impress.desktop";

        xdg.mime.defaultApplications."application/vnd.openxmlformats-officedocument.presentationml.presentation" =
          "libreoffice-impress.desktop";

        xdg.mime.defaultApplications."application/vnd.ms-powerpoint" =
          "libreoffice-impress.desktop";

        xdg.mime.defaultApplications."application/vnd.oasis.opendocument.graphics-template" =
          "libreoffice-draw.desktop";
      };
    };

  # LibreOffice is installed conditionally; no @option, so it stays out of a
  # packages widget the GUI would try to render.
  flake.modules.nixos.applications-office-apps =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      environment.systemPackages =
        lib.optionals config.ojuny.apps.office.enable [ pkgs.libreoffice-fresh ]
        ++ lib.optionals config.ojuny.apps.office.enable (with pkgs.hunspellDicts; [
          en_US
          de_DE
        ]);
    };

  # Obsidian reads per-vault appearance files. The Stylix target writes the
  # default appearance and one CSS snippet per vault name. Existing vaults not
  # listed in `ojuny.apps.obsidian.vaults` keep their own settings until their
  # name is added. Vault contents are user data and never enter the Nix store.
  #
  # The Home Manager Obsidian module in the pinned checkout has no
  # `mutableSettings` option, so appearance files for listed vaults remain
  # declarative and can be rewritten on activation.
  flake.modules.homeManager.applications-obsidian =
    {
      config,
      lib,
      pkgs,
      osConfig ? { },
      ...
    }:
    {
      config = {
        programs.obsidian.enable = osConfig.ojuny.apps.obsidian.enable or false;


        stylix.targets.obsidian.vaultNames =
          osConfig.ojuny.apps.obsidian.vaults or [ ];
      };
    };

}
