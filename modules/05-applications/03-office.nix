/*
  @menu
  displayname = "Office";
  icon = "x-office-document-symbolic";
  order = 30;
  description = "Office suite, document tools and ArtCraft apps";
  category = "05-Applications";
*/

{ self, inputs, ... }: {

  flake.modules.nixos.applications-office =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      imports = [
        inputs.craftapps.nixosModules.default
        self.modules.nixos.applications-office-apps
        self.modules.nixos.applications-office-mime
        self.modules.nixos.applications-office-backend
      ];

      options.ojuny.apps.office.enable = lib.mkEnableOption "the LibreOffice office suite";

      options.ojuny.apps.office.craftAll = lib.mkEnableOption "every ArtCraft app at once";

      config = {
        # @option widget = "switch"; label = "LibreOffice"; group = "Office suite"; groupOrder = 10; order = 1;
        ojuny.apps.office.enable = false;

        # Craft apps (ArtCraft suite). The core enable is derived from the app
        # switches below, so it never appears as a control of its own.
        # @option widget = "switch"; label = "Link system fonts"; group = "Craft apps"; hidden = true;
        programs.craftapps.linkFonts = true;

        # @option widget = "switch"; label = "All craft apps"; group = "Craft apps"; groupOrder = 20; order = 1; description = "Install every ArtCraft app; the switches below still exclude individual apps.";
        ojuny.apps.office.craftAll = false;

        # Derived, no @option: the upstream apps default to `enableAll`.
        programs.craftapps.enableAll = config.ojuny.apps.office.craftAll;

        # @option widget = "horizontal-submodule"; label = "Craft apps"; group = "Craft apps"; groupOrder = 20;
        programs.craftapps.apps = {
          # @option widget = "switch"; label = "Photocraft"; group = "Craft apps";
          photocraft.enable = false;
          # @option widget = "switch"; label = "Vectorcraft"; group = "Craft apps";
          vectorcraft.enable = false;
          # @option widget = "switch"; label = "Lightcraft"; group = "Craft apps";
          lightcraft.enable = false;
          # @option widget = "switch"; label = "PDFcraft"; group = "Craft apps";
          pdfcraft.enable = false;
          # @option widget = "switch"; label = "Effectcraft"; group = "Craft apps";
          effectcraft.enable = false;
          # @option widget = "switch"; label = "Designcraft"; group = "Craft apps";
          designcraft.enable = false;
          # @option widget = "switch"; label = "Filmcraft"; group = "Craft apps";
          filmcraft.enable = false;
          # @option widget = "switch"; label = "Gridcraft"; group = "Craft apps";
          gridcraft.enable = false;
          # @option widget = "switch"; label = "Soundcraft"; group = "Craft apps";
          soundcraft.enable = false;
          # @option widget = "switch"; label = "Cadcraft"; group = "Craft apps";
          cadcraft.enable = false;
          # @option widget = "switch"; label = "Wordcraft"; group = "Craft apps";
          wordcraft.enable = false;
          # @option widget = "switch"; label = "Deckcraft"; group = "Craft apps";
          deckcraft.enable = false;
        };

        # Derived, no @option: the upstream module only installs while the core
        # is on, and the core turns itself on when any app is selected.
        programs.craftapps.enable =
          config.programs.craftapps.apps.photocraft.enable
          || config.programs.craftapps.apps.vectorcraft.enable
          || config.programs.craftapps.apps.lightcraft.enable
          || config.programs.craftapps.apps.pdfcraft.enable
          || config.programs.craftapps.apps.effectcraft.enable
          || config.programs.craftapps.apps.designcraft.enable
          || config.programs.craftapps.apps.filmcraft.enable
          || config.programs.craftapps.apps.gridcraft.enable
          || config.programs.craftapps.apps.soundcraft.enable
          || config.programs.craftapps.apps.cadcraft.enable
          || config.programs.craftapps.apps.wordcraft.enable
          || config.programs.craftapps.apps.deckcraft.enable;
      };
    };

  # Document-format associations. Gated on LibreOffice so a disabled suite
  # never writes defaults that point at desktop files it does not install.
  flake.modules.nixos.applications-office-mime =
    {
      config,
      lib,
      ...
    }:
    {
      config = lib.mkIf config.ojuny.apps.office.enable {
        # @option widget = "dropdown"; label = "OpenDocument text"; group = "Default applications"; groupOrder = 15; choices = [ "libreoffice-writer.desktop" "libreoffice-calc.desktop" "libreoffice-impress.desktop" "libreoffice-draw.desktop" ]; visibleWhen.path = "ojuny.apps.office.enable"; visibleWhen.equals = true; applyCommand = "xdg-mime default %%val%% application/vnd.oasis.opendocument.text";
        xdg.mime.defaultApplications."application/vnd.oasis.opendocument.text" =
          "libreoffice-writer.desktop";

        # @option widget = "dropdown"; label = "Word documents"; group = "Default applications"; groupOrder = 15; choices = [ "libreoffice-writer.desktop" "libreoffice-calc.desktop" "libreoffice-impress.desktop" "libreoffice-draw.desktop" ]; visibleWhen.path = "ojuny.apps.office.enable"; visibleWhen.equals = true; applyCommand = "xdg-mime default %%val%% application/vnd.openxmlformats-officedocument.wordprocessingml.document";
        xdg.mime.defaultApplications."application/vnd.openxmlformats-officedocument.wordprocessingml.document" =
          "libreoffice-writer.desktop";

        # @option widget = "dropdown"; label = "Spreadsheets"; group = "Default applications"; groupOrder = 15; choices = [ "libreoffice-writer.desktop" "libreoffice-calc.desktop" "libreoffice-impress.desktop" "libreoffice-draw.desktop" ]; visibleWhen.path = "ojuny.apps.office.enable"; visibleWhen.equals = true; applyCommand = "xdg-mime default %%val%% application/vnd.oasis.opendocument.spreadsheet";
        xdg.mime.defaultApplications."application/vnd.oasis.opendocument.spreadsheet" =
          "libreoffice-calc.desktop";

        # @option widget = "dropdown"; label = "Presentations"; group = "Default applications"; groupOrder = 15; choices = [ "libreoffice-writer.desktop" "libreoffice-calc.desktop" "libreoffice-impress.desktop" "libreoffice-draw.desktop" ]; visibleWhen.path = "ojuny.apps.office.enable"; visibleWhen.equals = true; applyCommand = "xdg-mime default %%val%% application/vnd.oasis.opendocument.presentation";
        xdg.mime.defaultApplications."application/vnd.oasis.opendocument.presentation" =
          "libreoffice-impress.desktop";

        # @option widget = "dropdown"; label = "Drawings"; group = "Default applications"; groupOrder = 15; choices = [ "libreoffice-writer.desktop" "libreoffice-calc.desktop" "libreoffice-impress.desktop" "libreoffice-draw.desktop" ]; visibleWhen.path = "ojuny.apps.office.enable"; visibleWhen.equals = true; applyCommand = "xdg-mime default %%val%% application/vnd.oasis.opendocument.graphics";
        xdg.mime.defaultApplications."application/vnd.oasis.opendocument.graphics" =
          "libreoffice-draw.desktop";
      };
    };

  flake.modules.nixos.applications-obsidian =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      config = {
        # @option widget = "switch"; label = "Obsidian"; group = "Obsidian"; groupOrder = 10; order = 10; description = "Install Obsidian. Off by default because it is proprietary.";
        ojuny.apps.obsidian.enable = false;

        # @option widget = "list"; label = "Vault names"; group = "Obsidian"; groupOrder = 10; order = 20; visibleWhen.path = "ojuny.apps.obsidian.enable"; visibleWhen.equals = true; description = "Exact vault names to theme. A vault created after the last rebuild is not themed until its name is added.";
        ojuny.apps.obsidian.vaults = [ ];

        environment.systemPackages =
          lib.optionals config.ojuny.apps.obsidian.enable [ pkgs.obsidian ];

        desktop.ojuny.defaultApps =
          lib.optionals config.ojuny.apps.obsidian.enable [ pkgs.obsidian ];
      };
    };

}
