{ ... }: {

  flake.modules.nixos.desktop-menu-backend =
    { config, lib, ... }:
    let
      toggleCommand =
        if config.ojuny.menu.toggleTarget == "winmenu" then
          "ojuny-WinMenu"
        else
          "dms ipc call dankMenu toggle root";
    in
    {

    options.ojuny.menu.toggleTarget = lib.mkOption {
      type = lib.types.enum [ "ojuny" "winmenu" ];
      default = "ojuny";
      description = "Menu opened by SUPER+X and SUPER+Escape.";
    };

    config = {

    desktop.ojuny.mango.binds.common.menuToggle = {
      modifier = [ "SUPER" ];
      keys = [ "X" ];
      dispatcher = "spawn";
      args = toggleCommand;
      description = "Toggle menu";
      group = "Applications";
      subcat = "Launch";
    };

    desktop.ojuny.mango.binds.common.menuToggleAlt = {
      modifier = [ "SUPER" ];
      keys = [ "Escape" ];
      dispatcher = "spawn";
      args = toggleCommand;
      description = "Toggle menu";
      group = "Applications";
      subcat = "Launch";
    };

    };
  };

}
