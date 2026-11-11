{ self, inputs, ... }: {

  flake.modules.nixos.desktop-style-theme-backend =
    {
      config,
      lib,
      pkgs,
      ...
    }:

    let
      presetNames = builtins.attrNames inputs.ojuny-desktop.wallpaperPresets;
      wallpaperValue = config.ojuny.style.wallpaperPreset;
      wallpaperIsPreset = builtins.isString wallpaperValue && builtins.elem wallpaperValue presetNames;
    in
    {
      options.ojuny.style = {
        palette = lib.mkOption {
          type = lib.types.str;
          default = "everforest-dark-hard";
          description = "base16 scheme name from pkgs.base16-schemes, without the .yaml suffix.";
        };
        wallpaperPreset = lib.mkOption {
          type = lib.types.nullOr (
            lib.types.oneOf [
              (lib.types.enum presetNames)
              lib.types.path
            ]
          );
          default = null;
          description = "Bundled wallpaper preset name, a custom image path, or null for the default preset. Presets are recolored with the active palette; paths are used as-is.";
        };
        wallpaperCycleIncludeBuiltins = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Include bundled presets when DMS cycles through wallpapers.";
        };
        wallpaper = lib.mkOption {
          type = lib.types.nullOr lib.types.path;
          default = null;
          description = "Deprecated and ignored; use wallpaperPreset.";
        };
      };

      config = {
        # Derived from the palette name; no @option so a GUI edit cannot lose the store path.
        stylix.base16Scheme =
          "${pkgs.base16-schemes}/share/themes/${
            if config.ojuny.accessibility.highContrast
            then config.ojuny.accessibility.highContrastPalette
            else config.ojuny.style.palette
          }.yaml";

        desktop.ojuny.wallpaper.image = if wallpaperIsPreset then null else wallpaperValue;
        desktop.ojuny.wallpaper.preset = lib.mkIf wallpaperIsPreset wallpaperValue;
        desktop.ojuny.wallpaper.cycleIncludeBuiltins = config.ojuny.style.wallpaperCycleIncludeBuiltins;
      };
    };

}
