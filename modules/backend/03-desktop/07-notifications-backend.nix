{ self, inputs, ... }:

let
  popupPositions = {
    "top-right" = 0;
    "top-left" = 2;
    "top-center" = -1;
    "bottom-center" = 5;
    "bottom-right" = 3;
    "bottom-left" = 1;
  };
in
{
  flake.modules.nixos.desktop-notifications-backend =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      options.ojuny.dux.notificationPopupPosition = lib.mkOption {
        type = lib.types.enum (lib.attrNames popupPositions);
        default = "top-right";
      };

      options.ojuny.apps.kalarm.enable = lib.mkEnableOption "KAlarm scheduled notices";

      config = {
        environment.systemPackages = lib.optional config.ojuny.apps.kalarm.enable pkgs.kdePackages.kalarm;

        desktop.ojuny.mango.execOnce =
          lib.optional config.ojuny.apps.kalarm.enable "${pkgs.kdePackages.kalarm}/bin/kalarm --tray";

        desktop.ojuny.dux.settings.notificationPopupPosition =
          popupPositions.${config.ojuny.dux.notificationPopupPosition};
      };
    };
}
