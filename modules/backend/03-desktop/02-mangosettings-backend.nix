{ self, inputs, ... }: {

  flake.modules.nixos.desktop-mangosettings-backend =
    { config, lib, ... }:

    let
      # mango stores booleans as the integers 0 and 1, so these are exposed as
      # switches under ojuny.mango.* and written back as 0/1 in the derived
      # assignments at the bottom of this module.
      flagDefaults = {
        focus_on_activate = false;
        sloppy_focus = true;
        warp_cursor = true;
        allow_lock_transparent = true;
        focus_cross_monitor = true;
        focus_cross_tag = false;
        focus_direction_only_zone_overlap = true;
        exchange_cross_monitor = true;
        view_current_to_back = true;
        enable_floating_snap = true;
        float_full_to_top = false;
        enable_border_resize = true;
        enable_hotarea = false;
        hotarea_disable_on_fullscreen = true;
        allow_shortcuts_inhibit = true;
        auto_reload_config = true;
        disable_middle_paste = false;
        sync_obj_enable = true;
        xwayland_persistence = true;
        idle_inhibit_ignore_visible = false;
        idle_inhibit_when_fullscreen = false;
      };

      # mango mode integers, exposed as named choices under ojuny.mango.enum and
      # mapped back to their integers in the derived assignments below.
      enumSpecs = {
        hotarea_corner = {
          default = "bottom-left";
          choices = {
            "top-left" = 0;
            "top-right" = 1;
            "bottom-left" = 2;
            "bottom-right" = 3;
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
        # Derived mango integers (no @option, hidden in the GUI).
        desktop.ojuny.mango.global.focus_on_activate =
          if config.ojuny.mango.flag.focus_on_activate then 1 else 0;
        desktop.ojuny.mango.global.sloppy_focus = if config.ojuny.mango.flag.sloppy_focus then 1 else 0;
        desktop.ojuny.mango.global.warp_cursor = if config.ojuny.mango.flag.warp_cursor then 1 else 0;
        desktop.ojuny.mango.global.allow_lock_transparent =
          if config.ojuny.mango.flag.allow_lock_transparent then 1 else 0;
        desktop.ojuny.mango.global.focus_cross_monitor =
          if config.ojuny.mango.flag.focus_cross_monitor then 1 else 0;
        desktop.ojuny.mango.global.focus_cross_tag =
          if config.ojuny.mango.flag.focus_cross_tag then 1 else 0;
        desktop.ojuny.mango.global.focus_direction_only_zone_overlap =
          if config.ojuny.mango.flag.focus_direction_only_zone_overlap then 1 else 0;
        desktop.ojuny.mango.global.exchange_cross_monitor =
          if config.ojuny.mango.flag.exchange_cross_monitor then 1 else 0;
        desktop.ojuny.mango.global.view_current_to_back =
          if config.ojuny.mango.flag.view_current_to_back then 1 else 0;
        desktop.ojuny.mango.global.enable_floating_snap =
          if config.ojuny.mango.flag.enable_floating_snap then 1 else 0;
        desktop.ojuny.mango.global.float_full_to_top =
          if config.ojuny.mango.flag.float_full_to_top then 1 else 0;
        desktop.ojuny.mango.global.enable_border_resize =
          if config.ojuny.mango.flag.enable_border_resize then 1 else 0;
        desktop.ojuny.mango.global.idle_inhibit_ignore_visible =
          if config.ojuny.mango.flag.idle_inhibit_ignore_visible then 1 else 0;
        desktop.ojuny.mango.global.idle_inhibit_when_fullscreen =
          if config.ojuny.mango.flag.idle_inhibit_when_fullscreen then 1 else 0;
        desktop.ojuny.mango.global.enable_hotarea = if config.ojuny.mango.flag.enable_hotarea then 1 else 0;
        desktop.ojuny.mango.global.hotarea_disable_on_fullscreen =
          if config.ojuny.mango.flag.hotarea_disable_on_fullscreen then 1 else 0;
        desktop.ojuny.mango.global.allow_shortcuts_inhibit =
          if config.ojuny.mango.flag.allow_shortcuts_inhibit then 1 else 0;
        desktop.ojuny.mango.global.auto_reload_config =
          if config.ojuny.mango.flag.auto_reload_config then 1 else 0;
        desktop.ojuny.mango.global.disable_middle_paste =
          if config.ojuny.mango.flag.disable_middle_paste then 1 else 0;
        desktop.ojuny.mango.global.sync_obj_enable =
          if config.ojuny.mango.flag.sync_obj_enable then 1 else 0;
        desktop.ojuny.mango.global.xwayland_persistence =
          if config.ojuny.mango.flag.xwayland_persistence then 1 else 0;

        desktop.ojuny.mango.global.hotarea_corner =
          enumSpecs.hotarea_corner.choices.${config.ojuny.mango.enum.hotarea_corner};
      };
    };
}
