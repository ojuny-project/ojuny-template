{ self, inputs, ... }: {

  flake.modules.nixos.desktop-monocledeck-backend =
    { config, lib, ... }:
    {
      options.ojuny.mango.flag = {
        monocle_tab_mode = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "mango global monocle_tab_mode, stored as 0/1.";
        };
        monocle_no_border = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "mango global monocle_no_border, stored as 0/1.";
        };
        monocle_no_gap = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "mango global monocle_no_gap, stored as 0/1.";
        };
        monocle_no_radius = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "mango global monocle_no_radius, stored as 0/1.";
        };
        deck_tab_mode = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "mango global deck_tab_mode, stored as 0/1.";
        };
        monocle_right_button_close = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "mango global monocle_right_button_close, stored as 0/1.";
        };
      };

      config = {
        # Derived mango integers (no @option, hidden in the GUI).
        desktop.ojuny.mango.global.monocle_tab_mode =
          if config.ojuny.mango.flag.monocle_tab_mode then 1 else 0;
        desktop.ojuny.mango.global.monocle_no_border =
          if config.ojuny.mango.flag.monocle_no_border then 1 else 0;
        desktop.ojuny.mango.global.monocle_no_gap =
          if config.ojuny.mango.flag.monocle_no_gap then 1 else 0;
        desktop.ojuny.mango.global.monocle_no_radius =
          if config.ojuny.mango.flag.monocle_no_radius then 1 else 0;
        desktop.ojuny.mango.global.deck_tab_mode =
          if config.ojuny.mango.flag.deck_tab_mode then 1 else 0;
        desktop.ojuny.mango.global.monocle_right_button_close =
          if config.ojuny.mango.flag.monocle_right_button_close then 1 else 0;
      };
    };
}
