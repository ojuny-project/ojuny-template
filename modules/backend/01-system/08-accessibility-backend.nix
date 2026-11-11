{ self, inputs, ... }: {

  flake.modules.nixos.system-accessibility-backend =
    {
      config,
      lib,
      ...
    }:

    let
      highContrastPalettes = [
        "windows-highcontrast"
        "windows-highcontrast-light"
        "penumbra-dark-contrast-plus-plus"
        "penumbra-light-contrast-plus-plus"
      ];

    in
    {
      options.ojuny.accessibility = {
        highContrast = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "Use a high-contrast base16 palette instead of the normal palette.";
        };
        highContrastPalette = lib.mkOption {
          type = lib.types.enum highContrastPalettes;
          default = "windows-highcontrast";
          description = "High-contrast base16 scheme.";
        };
        iccProfile = lib.mkOption {
          type = lib.types.nullOr lib.types.path;
          default = null;
          description = "ICC profile applied to every monitor as a build-time output color transform. HDR must be off for the output.";
        };
        reduceMotion = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "Disable DMS and Mango window animations.";
        };
      };

      config = {

        environment.sessionVariables.QT_ACCESSIBILITY =
          lib.mkIf config.services.orca.enable "1";
      };
    };

}
