{ inputs, ... }: {

  flake.modules.nixos.desktop-bar-backend =
    { config, lib, ... }:

    {
      options.ojuny.dux.barPreset = lib.mkOption {
        type = lib.types.enum [
          "default"
          "taskbar"
          "status"
          "sidebar-left"
          "sidebar-right"
          "caelestia"
          "goth"
          "simple-island"
          "simple-bar"
          "custom"
          "none"
        ];
        default = "default";
        description = "Active bar preset. Apply with Save and Rebuild.";
      };

      options.ojuny.dux.customBar = lib.mkOption {
        type = lib.types.toml;
        default = inputs.ojuny-desktop.barPresets.customBase;
        description = "Editable settings for the custom bar preset.";
      };

      config = {

        desktop.ojuny.dux.barPreset = config.ojuny.dux.barPreset;

        desktop.ojuny.dux.barPresets = lib.recursiveUpdate inputs.ojuny-desktop.barPresets.presets {
          default.leftWidgets.dankCalendarAgenda = {
            enabled = config.desktop.ojuny.dux.plugins.dankCalendarAgenda.enable;
            _order = 35;
          };
          taskbar.rightWidgets.worldClock = {
            enabled = false;
            _order = 35;
          };
          status.rightWidgets.worldClock = {
            enabled = config.desktop.ojuny.dux.plugins.worldClock.enable;
            _order = 35;
          };
        };

        desktop.ojuny.dux.barConfigs.custom = config.ojuny.dux.customBar // {
          enabled = config.ojuny.dux.barPreset == "custom";
          visible = config.ojuny.dux.barPreset == "custom";
        };

      };
    };
}
