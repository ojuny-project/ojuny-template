{ self, inputs, ... }: {

  flake.modules.nixos.desktop-style-typography-backend =
    { config, lib, pkgs, ... }:
    let
      cfg = config.ojuny.fonts.fallbacks;

      sansFallbacks =
        lib.optionals cfg.cjk [ "Noto Sans CJK SC" ]
        ++ lib.optionals cfg.arabic [ "Noto Sans Arabic" ]
        ++ lib.optionals cfg.hebrew [ "Noto Sans Hebrew" ]
        ++ lib.optionals cfg.devanagari [ "Noto Sans Devanagari" ]
        ++ lib.optionals cfg.thai [ "Noto Sans Thai" ]
        ++ lib.optionals cfg.emoji [ "Noto Color Emoji" ];

      serifFallbacks =
        lib.optionals cfg.cjk [ "Noto Serif CJK SC" ]
        ++ lib.optionals cfg.arabic [ "Noto Naskh Arabic" ]
        ++ lib.optionals cfg.hebrew [ "Noto Serif Hebrew" ]
        ++ lib.optionals cfg.devanagari [ "Noto Serif Devanagari" ]
        ++ lib.optionals cfg.thai [ "Noto Serif Thai" ]
        ++ lib.optionals cfg.emoji [ "Noto Color Emoji" ];

      monospaceFallbacks =
        lib.optionals cfg.cjk [ "Noto Sans Mono CJK SC" ]
        ++ lib.optionals cfg.arabic [ "Noto Sans Arabic" ]
        ++ lib.optionals cfg.hebrew [ "Noto Sans Hebrew" ]
        ++ lib.optionals cfg.devanagari [ "Noto Sans Devanagari" ]
        ++ lib.optionals cfg.thai [ "Noto Sans Thai" ]
        ++ lib.optionals cfg.emoji [ "Noto Color Emoji" ];
    in
    {
      options.ojuny.fonts.fallbacks = lib.mkOption {
        type = lib.types.submodule {
          options = {
            cjk = lib.mkOption {
              type = lib.types.bool;
              default = false;
              description = "Install Noto CJK sans and serif and append them after the selected family.";
            };
            arabic = lib.mkOption {
              type = lib.types.bool;
              default = false;
              description = "Install Noto Arabic and append it after the selected family.";
            };
            hebrew = lib.mkOption {
              type = lib.types.bool;
              default = false;
              description = "Install Noto Hebrew and append it after the selected family.";
            };
            devanagari = lib.mkOption {
              type = lib.types.bool;
              default = false;
              description = "Install Noto Devanagari and append it after the selected family.";
            };
            thai = lib.mkOption {
              type = lib.types.bool;
              default = false;
              description = "Install Noto Thai and append it after the selected family.";
            };
            emoji = lib.mkOption {
              type = lib.types.bool;
              default = false;
              description = "Install Noto Color Emoji and append it after the selected family.";
            };
          };
        };
        default = { };
        description = "Script fallback families appended after the selected Stylix family.";
      };

      config = {
        fonts.packages =
          [ pkgs.material-symbols ]
          ++ lib.optionals cfg.cjk [
            pkgs.noto-fonts-cjk-sans
            pkgs.noto-fonts-cjk-serif
          ]
          ++ lib.optionals (cfg.arabic || cfg.hebrew || cfg.devanagari || cfg.thai) [ pkgs.noto-fonts ]
          ++ lib.optionals cfg.emoji [ pkgs.noto-fonts-emoji ];

        fonts.fontconfig.defaultFonts.sansSerif = lib.mkAfter sansFallbacks;
        fonts.fontconfig.defaultFonts.serif = lib.mkAfter serifFallbacks;
        fonts.fontconfig.defaultFonts.monospace = lib.mkAfter monospaceFallbacks;
      };
    };

}
