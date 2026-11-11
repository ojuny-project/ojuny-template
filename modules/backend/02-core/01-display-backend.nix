{ self, inputs, ... }: {

  flake.modules.nixos.desktop-display-backend =
    { config, lib, ... }:

    let
      flagDefaults = {
        xwayland_ignore_scale = false;
      };

      enumSpecs = {
        allow_tearing = {
          default = "disable";
          choices = {
            "disable" = 0;
            "enable" = 1;
            "fullscreen-only" = 2;
          };
        };
        hdr_depth = {
          default = "hdr10";
          choices = {
            "default" = 0;
            "hdr8" = 1;
            "hdr10" = 2;
          };
        };
      };

      iccProfile = config.ojuny.accessibility.iccProfile;

      transformToRr = {
        normal = 0;
        "90" = 1;
        "180" = 2;
        "270" = 3;
        flipped = 4;
        "flipped-90" = 5;
        "flipped-180" = 6;
        "flipped-270" = 7;
      };

      monitorRule = name: output:
        let
          icc =
            if output.color.icc != "" then
              output.color.icc
            else if iccProfile != null then
              toString iccProfile
            else
              null;
          modeSet = output.width > 0 && output.height > 0 && output.refresh > 0;
        in
        {
          inherit name;
          x = output.xPos;
          y = output.yPos;
          scale = output.scale;
          rr = transformToRr.${output.transform};
          disable = if output.enabled then 0 else 1;
          primary = if output.primary then 1 else 0;
          vrr = if output.sync.vrr == "off" || output.sync.vrr == "never" then 0 else 1;
          hdr = if output.hdr.enabled then 1 else 0;
          hdr_force = if output.hdr.force then 1 else 0;
          custom = if output.customMode then 1 else 0;
        }
        // lib.optionalAttrs modeSet {
          inherit (output) width height refresh;
        }
        // lib.optionalAttrs (output.hdr.minLuminance > 0) {
          hdr_min_lum = output.hdr.minLuminance;
        }
        // lib.optionalAttrs (output.hdr.maxLuminance > 0) {
          hdr_max_lum = output.hdr.maxLuminance;
        }
        // lib.optionalAttrs (output.hdr.maxAvgLuminance > 0) {
          hdr_max_avg_lum = output.hdr.maxAvgLuminance;
        }
        // lib.optionalAttrs (output.match.make != "") {
          inherit (output.match) make;
        }
        // lib.optionalAttrs (output.match.model != "") {
          inherit (output.match) model;
        }
        // lib.optionalAttrs (output.match.serial != "") {
          inherit (output.match) serial;
        }
        // lib.optionalAttrs (icc != null) {
          inherit icc;
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

        desktop.ojuny.mango.rules.monitor_rule =
          lib.mapAttrsToList monitorRule config.services.nix-settings-gui.monitors;

        # Derived mango integers (no @option, hidden in the GUI).
        desktop.ojuny.mango.global.xwayland_ignore_scale =
          if config.ojuny.mango.flag.xwayland_ignore_scale then 1 else 0;
        desktop.ojuny.mango.global.allow_tearing =
          enumSpecs.allow_tearing.choices.${config.ojuny.mango.enum.allow_tearing};
        desktop.ojuny.mango.global.hdr_depth =
          enumSpecs.hdr_depth.choices.${config.ojuny.mango.enum.hdr_depth};
      };
    };

}
