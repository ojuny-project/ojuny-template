{ self, inputs, ... }: {

  flake.modules.nixos.desktop-input-backend =
    { config, lib, ... }:
    let
      # mango stores these as 0/1 integers; see the derived assignments at the end.
      flagDefaults = {
        numlock_on = true;
        mouse_natural_scrolling = false;
        mouse_left_handed = false;
        mouse_middle_button_emulation = false;
        disable_trackpad = false;
        tap_to_click = true;
        tap_and_drag = true;
        drag_lock = true;
        trackpad_natural_scrolling = true;
        trackpad_disable_while_typing = true;
        trackpad_left_handed = false;
        trackpad_middle_button_emulation = false;
        touch_enable = true;
        touch_enable_mouse_emulation = true;
        cursor_hide_on_keypress = false;
        drag_tile_to_tile = true;
        drag_tile_small = true;
        drag_warp_cursor = true;
      };

      # mango mode integers, exposed as named choices and mapped back below.
      enumSpecs = {
        mouse_accel_profile = {
          default = "flat";
          choices = {
            "none" = 0;
            "flat" = 1;
            "adaptive" = 2;
          };
        };
        mouse_scroll_method = {
          default = "two-finger";
          choices = {
            "never" = 0;
            "two-finger" = 1;
            "edge" = 2;
            "button" = 4;
          };
        };
        mouse_click_method = {
          default = "button-areas";
          choices = {
            "none" = 0;
            "button-areas" = 1;
            "clickfinger" = 2;
          };
        };
        mouse_send_events_mode = {
          default = "enabled";
          choices = {
            "enabled" = 0;
            "disabled" = 1;
            "disabled-with-external-mouse" = 2;
          };
        };
        trackpad_accel_profile = {
          default = "adaptive";
          choices = {
            "none" = 0;
            "flat" = 1;
            "adaptive" = 2;
          };
        };
        trackpad_scroll_method = {
          default = "two-finger";
          choices = {
            "never" = 0;
            "two-finger" = 1;
            "edge" = 2;
            "button" = 4;
          };
        };
        trackpad_click_method = {
          default = "button-areas";
          choices = {
            "none" = 0;
            "button-areas" = 1;
            "clickfinger" = 2;
          };
        };
        trackpad_send_events_mode = {
          default = "enabled";
          choices = {
            "enabled" = 0;
            "disabled" = 1;
            "disabled-with-external-mouse" = 2;
          };
        };
        button_map = {
          default = "left-middle-right";
          choices = {
            "left-right-middle" = 0;
            "left-middle-right" = 1;
          };
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

      options.ojuny.mango.enum = lib.mapAttrs (
        name: spec:
        lib.mkOption {
          type = lib.types.enum (lib.attrNames spec.choices);
          default = spec.default;
          description = "mango global ${name}.";
        }
      ) enumSpecs;

      config = {
        desktop.ojuny.mango.rules.device_rule = map (
          device:
          lib.filterAttrs (_: value: value != "") {
            inherit (device) name type kb_layout kb_variant kb_options kb_model monitor;
            send_events_mode =
              if device.send_events_mode == "" then "" else lib.toInt device.send_events_mode;
          }
        ) config.ojuny.input.devices;

        services.udev.extraRules = lib.concatStringsSep "\n" (
          let
            calibrated = lib.filter (
              device: device.type == "touch" && device.calibration != ""
            ) config.ojuny.input.devices;

            ruleFor = device:
              let
                match =
                  if device.name == ""
                  then ''ENV{ID_INPUT_TOUCHSCREEN}=="1"''
                  else ''ATTRS{name}=="${device.name}"'';
              in
              ''ACTION!="remove", KERNEL=="event[0-9]*", SUBSYSTEM=="input", ${match}, ENV{LIBINPUT_CALIBRATION_MATRIX}="${device.calibration}"'';

            unnamed = lib.filter (device: device.name == "") calibrated;
            named = lib.filter (device: device.name != "") calibrated;
          in
          map ruleFor (unnamed ++ named)
        );

        assertions = [
          {
            assertion = lib.all (device: device.name != "" || device.type != "") config.ojuny.input.devices;
            message = "ojuny.input.devices: every row needs a name or a type.";
          }
          {
            assertion = lib.all (
              device:
              device.type == ""
              || lib.elem device.type [
                "keyboard"
                "pointer"
                "trackpad"
                "touch"
                "switch"
                "tablet"
                "pad"
              ]
            ) config.ojuny.input.devices;
            message = "ojuny.input.devices: type must be keyboard, pointer, trackpad, touch, switch, tablet or pad.";
          }
          {
            assertion = lib.all (
              device: lib.elem device.send_events_mode [ "" "0" "1" "2" ]
            ) config.ojuny.input.devices;
            message = "ojuny.input.devices: send_events_mode must be empty, 0, 1 or 2.";
          }
          {
            assertion = lib.all (
              device:
              device.calibration == ""
              || builtins.match "-?[0-9]+(\\.[0-9]+)?( -?[0-9]+(\\.[0-9]+)?){5}" device.calibration != null
            ) config.ojuny.input.devices;
            message = "ojuny.input.devices: calibration must be six space-separated numbers.";
          }
          {
            assertion = lib.all (
              device: device.calibration == "" || device.type == "touch"
            ) config.ojuny.input.devices;
            message = "ojuny.input.devices: calibration is only allowed on touch rows.";
          }
          {
            assertion =
              lib.count (device: device.calibration != "" && device.name == "")
                config.ojuny.input.devices
              <= 1;
            message = "ojuny.input.devices: only one unnamed touch row may set calibration; give additional rows a name.";
          }
          {
            assertion = lib.all (
              device: device.calibration == "" || !(lib.hasInfix "\"" device.name)
            ) config.ojuny.input.devices;
            message = "ojuny.input.devices: a calibration row name must not contain a double quote.";
          }
        ];

        # Derived mango integers (no @option, hidden in the GUI).
        desktop.ojuny.mango.global.numlock_on = if config.ojuny.mango.flag.numlock_on then 1 else 0;
        desktop.ojuny.mango.global.mouse_natural_scrolling =
          if config.ojuny.mango.flag.mouse_natural_scrolling then 1 else 0;
        desktop.ojuny.mango.global.mouse_left_handed =
          if config.ojuny.mango.flag.mouse_left_handed then 1 else 0;
        desktop.ojuny.mango.global.mouse_middle_button_emulation =
          if config.ojuny.mango.flag.mouse_middle_button_emulation then 1 else 0;
        desktop.ojuny.mango.global.disable_trackpad =
          if config.ojuny.mango.flag.disable_trackpad then 1 else 0;
        desktop.ojuny.mango.global.tap_to_click = if config.ojuny.mango.flag.tap_to_click then 1 else 0;
        desktop.ojuny.mango.global.tap_and_drag = if config.ojuny.mango.flag.tap_and_drag then 1 else 0;
        desktop.ojuny.mango.global.drag_lock = if config.ojuny.mango.flag.drag_lock then 1 else 0;
        desktop.ojuny.mango.global.trackpad_natural_scrolling =
          if config.ojuny.mango.flag.trackpad_natural_scrolling then 1 else 0;
        desktop.ojuny.mango.global.trackpad_disable_while_typing =
          if config.ojuny.mango.flag.trackpad_disable_while_typing then 1 else 0;
        desktop.ojuny.mango.global.trackpad_left_handed =
          if config.ojuny.mango.flag.trackpad_left_handed then 1 else 0;
        desktop.ojuny.mango.global.trackpad_middle_button_emulation =
          if config.ojuny.mango.flag.trackpad_middle_button_emulation then 1 else 0;
        desktop.ojuny.mango.global.touch_enable = if config.ojuny.mango.flag.touch_enable then 1 else 0;
        desktop.ojuny.mango.global.touch_enable_mouse_emulation =
          if config.ojuny.mango.flag.touch_enable_mouse_emulation then 1 else 0;
        desktop.ojuny.mango.global.cursor_hide_on_keypress =
          if config.ojuny.mango.flag.cursor_hide_on_keypress then 1 else 0;
        desktop.ojuny.mango.global.drag_tile_to_tile =
          if config.ojuny.mango.flag.drag_tile_to_tile then 1 else 0;
        desktop.ojuny.mango.global.drag_tile_small =
          if config.ojuny.mango.flag.drag_tile_small then 1 else 0;
        desktop.ojuny.mango.global.drag_warp_cursor =
          if config.ojuny.mango.flag.drag_warp_cursor then 1 else 0;

        desktop.ojuny.mango.global.mouse_accel_profile =
          enumSpecs.mouse_accel_profile.choices.${config.ojuny.mango.enum.mouse_accel_profile};
        desktop.ojuny.mango.global.mouse_scroll_method =
          enumSpecs.mouse_scroll_method.choices.${config.ojuny.mango.enum.mouse_scroll_method};
        desktop.ojuny.mango.global.mouse_click_method =
          enumSpecs.mouse_click_method.choices.${config.ojuny.mango.enum.mouse_click_method};
        desktop.ojuny.mango.global.mouse_send_events_mode =
          enumSpecs.mouse_send_events_mode.choices.${config.ojuny.mango.enum.mouse_send_events_mode};
        desktop.ojuny.mango.global.trackpad_accel_profile =
          enumSpecs.trackpad_accel_profile.choices.${config.ojuny.mango.enum.trackpad_accel_profile};
        desktop.ojuny.mango.global.trackpad_scroll_method =
          enumSpecs.trackpad_scroll_method.choices.${config.ojuny.mango.enum.trackpad_scroll_method};
        desktop.ojuny.mango.global.trackpad_click_method =
          enumSpecs.trackpad_click_method.choices.${config.ojuny.mango.enum.trackpad_click_method};
        desktop.ojuny.mango.global.trackpad_send_events_mode =
          enumSpecs.trackpad_send_events_mode.choices.${config.ojuny.mango.enum.trackpad_send_events_mode};
        desktop.ojuny.mango.global.button_map =
          enumSpecs.button_map.choices.${config.ojuny.mango.enum.button_map};
      };
    };

}
