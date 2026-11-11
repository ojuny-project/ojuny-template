{ self, inputs, ... }: {

  flake.modules.nixos.desktop-style-compositor-backend =
    {
      config,
      lib,
      ...
    }:
    let
      colors = self.colors config.lib.stylix.colors;

      # mango appearance flags (0/1) exposed as switches.
      flagDefaults = {
        blur = true;
        blur_layer = false;
        blur_optimized = false;
        shadows = false;
        layer_shadows = false;
        shadow_only_floating = true;
        dim_enable = false;
        no_border_when_single = false;
        no_radius_when_single = false;
        smart_gaps = false;
        animations = true;
        layer_animations = false;
        animation_fade_in = true;
        animation_fade_out = true;
        always_show_group_bar = false;
        group_bar_close_button_enable = true;
      };

      # mango appearance strings and mode integers exposed as named choices.
      enumSpecs = {
        animation_type_open = {
          default = "zoom";
          choices = {
            "slide" = "slide";
            "zoom" = "zoom";
            "fade" = "fade";
            "none" = "none";
          };
        };
        animation_type_close = {
          default = "zoom";
          choices = {
            "slide" = "slide";
            "zoom" = "zoom";
            "fade" = "fade";
            "none" = "none";
          };
        };
        layer_animation_type_open = {
          default = "zoom";
          choices = {
            "slide" = "slide";
            "zoom" = "zoom";
            "fade" = "fade";
            "none" = "none";
          };
        };
        layer_animation_type_close = {
          default = "zoom";
          choices = {
            "slide" = "slide";
            "zoom" = "zoom";
            "fade" = "fade";
            "none" = "none";
          };
        };
        tag_animation_direction = {
          default = "vertical";
          choices = {
            "vertical" = 0;
            "horizontal" = 1;
          };
        };
      };
    in
    {
      options.ojuny.style = {
        customGaps = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "Use per-edge gaps instead of the single unified gap size.";
        };
        gaps = lib.mkOption {
          type = lib.types.int;
          default = 4;
          description = "Unified gap size used for every edge unless customGaps is on.";
        };
        gapInnerHorizontal = lib.mkOption {
          type = lib.types.int;
          default = 4;
          description = "Inner horizontal gap.";
        };
        gapInnerVertical = lib.mkOption {
          type = lib.types.int;
          default = 4;
          description = "Inner vertical gap.";
        };
        gapOuterHorizontal = lib.mkOption {
          type = lib.types.int;
          default = 4;
          description = "Outer horizontal gap.";
        };
        gapOuterVertical = lib.mkOption {
          type = lib.types.int;
          default = 4;
          description = "Outer vertical gap.";
        };
        customBorders = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "Use per-surface border thickness instead of the single unified thickness.";
        };
        borderThickness = lib.mkOption {
          type = lib.types.int;
          default = 1;
          description = "Unified border thickness used by mango, the bar and the dock unless customBorders is on.";
        };
        mangoBorderThickness = lib.mkOption {
          type = lib.types.int;
          default = 3;
          description = "mango window border thickness.";
        };
        barBorderThickness = lib.mkOption {
          type = lib.types.int;
          default = 1;
          description = "Bar border thickness.";
        };
        dockBorderThickness = lib.mkOption {
          type = lib.types.int;
          default = 1;
          description = "Dock border thickness.";
        };
      };

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
        # Derived mango values (no @option, hidden in the GUI).
        desktop.ojuny.mango.global.blur = if config.ojuny.mango.flag.blur then 1 else 0;
        desktop.ojuny.mango.global.blur_layer = if config.ojuny.mango.flag.blur_layer then 1 else 0;
        desktop.ojuny.mango.global.blur_optimized = if config.ojuny.mango.flag.blur_optimized then 1 else 0;
        desktop.ojuny.mango.global.shadows = if config.ojuny.mango.flag.shadows then 1 else 0;
        desktop.ojuny.mango.global.dim_enable = if config.ojuny.mango.flag.dim_enable then 1 else 0;
        desktop.ojuny.mango.global.no_border_when_single =
          if config.ojuny.mango.flag.no_border_when_single then 1 else 0;
        desktop.ojuny.mango.global.no_radius_when_single =
          if config.ojuny.mango.flag.no_radius_when_single then 1 else 0;
        desktop.ojuny.mango.global.smart_gaps = if config.ojuny.mango.flag.smart_gaps then 1 else 0;
        desktop.ojuny.mango.global.animations =
          if config.ojuny.accessibility.reduceMotion then
            0
          else if config.ojuny.mango.flag.animations then
            1
          else
            0;
        desktop.ojuny.mango.global.layer_animations =
          if config.ojuny.mango.flag.layer_animations then 1 else 0;
        desktop.ojuny.mango.global.animation_fade_in =
          if config.ojuny.mango.flag.animation_fade_in then 1 else 0;
        desktop.ojuny.mango.global.animation_fade_out =
          if config.ojuny.mango.flag.animation_fade_out then 1 else 0;
        desktop.ojuny.mango.global.always_show_group_bar =
          if config.ojuny.mango.flag.always_show_group_bar then 1 else 0;
        desktop.ojuny.mango.global.group_bar_close_button_enable =
          if config.ojuny.mango.flag.group_bar_close_button_enable then 1 else 0;
        desktop.ojuny.mango.global.layer_shadows =
          if config.ojuny.mango.flag.layer_shadows then 1 else 0;
        desktop.ojuny.mango.global.shadow_only_floating =
          if config.ojuny.mango.flag.shadow_only_floating then 1 else 0;

        desktop.ojuny.mango.global.animation_type_open =
          enumSpecs.animation_type_open.choices.${config.ojuny.mango.enum.animation_type_open};
        desktop.ojuny.mango.global.animation_type_close =
          enumSpecs.animation_type_close.choices.${config.ojuny.mango.enum.animation_type_close};
        desktop.ojuny.mango.global.layer_animation_type_open =
          enumSpecs.layer_animation_type_open.choices.${config.ojuny.mango.enum.layer_animation_type_open};
        desktop.ojuny.mango.global.layer_animation_type_close =
          enumSpecs.layer_animation_type_close.choices.${config.ojuny.mango.enum.layer_animation_type_close};
        desktop.ojuny.mango.global.tag_animation_direction =
          enumSpecs.tag_animation_direction.choices.${config.ojuny.mango.enum.tag_animation_direction};

        desktop.ojuny.mango.global.gap_inner_horizontal =
          if config.ojuny.style.customGaps then
            config.ojuny.style.gapInnerHorizontal
          else
            config.ojuny.style.gaps;
        desktop.ojuny.mango.global.gap_inner_vertical =
          if config.ojuny.style.customGaps then
            config.ojuny.style.gapInnerVertical
          else
            config.ojuny.style.gaps;
        desktop.ojuny.mango.global.gap_outer_horizontal =
          if config.ojuny.style.customGaps then
            config.ojuny.style.gapOuterHorizontal
          else
            config.ojuny.style.gaps;
        desktop.ojuny.mango.global.gap_outer_vertical =
          if config.ojuny.style.customGaps then
            config.ojuny.style.gapOuterVertical
          else
            config.ojuny.style.gaps;
        desktop.ojuny.mango.global.tab_bar_decorate_bg_color = colors.defaultBackground.rgba "ff";
        desktop.ojuny.mango.global.border_px =
          if config.ojuny.style.customBorders then
            config.ojuny.style.mangoBorderThickness
          else
            config.ojuny.style.borderThickness;
        desktop.ojuny.dux.barConfigs.default.borderThickness =
          if config.ojuny.style.customBorders then
            config.ojuny.style.barBorderThickness
          else
            config.ojuny.style.borderThickness;
        desktop.ojuny.dux.dockConfigs.dock.borderThickness =
          if config.ojuny.style.customBorders then
            config.ojuny.style.dockBorderThickness
          else
            config.ojuny.style.borderThickness;
      };
    };

}
