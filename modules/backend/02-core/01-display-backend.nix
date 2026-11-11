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
        desktop.ojuny.mango.global.xwayland_ignore_scale =
          if config.ojuny.mango.flag.xwayland_ignore_scale then 1 else 0;
        desktop.ojuny.mango.global.allow_tearing =
          enumSpecs.allow_tearing.choices.${config.ojuny.mango.enum.allow_tearing};
        desktop.ojuny.mango.global.hdr_depth =
          enumSpecs.hdr_depth.choices.${config.ojuny.mango.enum.hdr_depth};
      };
    };

}
