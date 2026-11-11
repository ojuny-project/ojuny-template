{ self, inputs, ... }: {

  flake.modules.nixos.desktop-gestures-backend =
    { config, lib, ... }:

    let
      # mango stores booleans as the integers 0 and 1, so this is exposed as a
      # switch under ojuny.mango.* and written back as 0/1 below.
      flagDefaults = {
        gesture_live = true;
      };

      # Every mango swipe gesture: 3- or 4-finger, four directions — 8 total.
      # The attr name is the label shown as the row key in the settings table;
      # it supplies this row's defaults (enable/dispatcher/args/keys/description).
      gestureDefaults = {
        "3-finger left swipe" = {
          keys = [ "left" "3" ];
          dispatcher = "viewtoright";
          args = "0";
          description = "3-finger left";
          enableDefault = true;
        };
        "3-finger right swipe" = {
          keys = [ "right" "3" ];
          dispatcher = "viewtoleft";
          args = "0";
          description = "3-finger right";
          enableDefault = true;
        };
        "3-finger down swipe" = {
          keys = [ "down" "3" ];
          dispatcher = "spawn";
          args = "dms ipc call spotlight toggle";
          description = "3-finger down";
          enableDefault = true;
        };
        "3-finger up swipe" = {
          keys = [ "up" "3" ];
          dispatcher = "spawn";
          args = "dms ipc call dankMenu toggle root";
          description = "3-finger up";
          enableDefault = true;
        };
        "4-finger left swipe" = {
          keys = [ "left" "4" ];
          dispatcher = "viewnext_have_client";
          args = "0";
          description = "4-finger left";
          enableDefault = false;
        };
        "4-finger right swipe" = {
          keys = [ "right" "4" ];
          dispatcher = "viewprev_have_client";
          args = "0";
          description = "4-finger right";
          enableDefault = false;
        };
        "4-finger down swipe" = {
          keys = [ "down" "4" ];
          dispatcher = "toggleoverview";
          args = "0";
          description = "4-finger down";
          enableDefault = false;
        };
        "4-finger up swipe" = {
          keys = [ "up" "4" ];
          dispatcher = "toggleoverview";
          args = "0";
          description = "4-finger up";
          enableDefault = false;
        };
      };
    in
    {

      options.ojuny.mango.flag = lib.mapAttrs (
        name: default:
        lib.mkOption {
          type = lib.types.bool;
          inherit default;
          description = "mango global ${name}, stored as 0/1.";
        }
      ) flagDefaults;

      # One option set, one table row per gesture. enable/dispatcher/args are
      # all user-settable. Unknown keys (row adds/renames) take inert defaults.
      options.ojuny.mango.gesture = lib.mkOption {
        type = lib.types.attrsOf (lib.types.submodule (
          { name, ... }:
          let
            spec = gestureDefaults.${name} or {
              enableDefault = false;
              dispatcher = "";
              args = "";
            };
          in
          {
            options = {
              enable = lib.mkOption {
                type = lib.types.bool;
                default = spec.enableDefault;
                description = "Enable this swipe gesture.";
              };
              dispatcher = lib.mkOption {
                type = lib.types.str;
                default = spec.dispatcher;
                description = "mango dispatcher this gesture runs.";
              };
              args = lib.mkOption {
                type = lib.types.str;
                default = spec.args;
                description = "Dispatcher arguments, comma-joined into the bind value.";
              };
            };
          }
        ));
        default = { };
      };

      config = {

        # Derived mango integer (no @option, hidden in the GUI).
        desktop.ojuny.mango.global.gesture_live = if config.ojuny.mango.flag.gesture_live then 1 else 0;

        # Derived gesture binds for the eight known gestures, gated on enable;
        # dispatcher/args come from the editable table above (no @option).
        desktop.ojuny.mango.gesturebind.default =
          lib.mapAttrs
            (name: _: {
              modifier = [ "none" ];
              keys = gestureDefaults.${name}.keys;
              dispatcher = config.ojuny.mango.gesture.${name}.dispatcher;
              args = config.ojuny.mango.gesture.${name}.args;
              description = gestureDefaults.${name}.description;
            })
            (lib.filterAttrs (name: _: config.ojuny.mango.gesture.${name}.enable) gestureDefaults);

      };
    };

}
