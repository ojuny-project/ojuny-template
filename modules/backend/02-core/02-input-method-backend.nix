{ self, inputs, ... }: {

  flake.modules.nixos.desktop-input-method-backend =
    { config, lib, pkgs, ... }:
    let
      cfg = config.ojuny.inputMethod;

      cjkEngines = {
        none = null;
        japanese = {
          name = "mozc";
          package = pkgs.fcitx5-mozc;
        };
        korean = {
          name = "hangul";
          package = pkgs.fcitx5-hangul;
        };
        simplified-chinese = {
          name = "pinyin";
          package = pkgs.fcitx5-chinese-addons;
        };
        traditional-chinese = {
          name = "chewing";
          package = pkgs.fcitx5-chewing;
        };
      };

      cjkEngine = cjkEngines.${cfg.cjkForms};

      knownEngineNames = {
        fcitx5-mozc = "mozc";
        fcitx5-hangul = "hangul";
        fcitx5-chinese-addons = "pinyin";
        fcitx5-chewing = "chewing";
      };

      extraEngineNames = lib.filter (name: name != null) (
        map (package: knownEngineNames.${lib.getName package} or null) cfg.engines
      );

      profileEngines = lib.unique (
        [ "keyboard-us" ]
        ++ lib.optional (cjkEngine != null) cjkEngine.name
        ++ extraEngineNames
      );

      profileItems = lib.listToAttrs (
        lib.imap0 (
          index: name: {
            name = "Groups/0/Items/${toString index}";
            value = {
              Name = name;
              Layout = "";
            };
          }
        ) profileEngines
      );

      profile = profileItems // {
        "Groups/0" = {
          Name = cfg.defaultGroup;
          "Default Layout" = "us";
          DefaultIM = "keyboard-us";
        };
        GroupOrder = {
          "0" = cfg.defaultGroup;
        };
      };
    in
    {
      config = lib.mkIf cfg.enable {
          i18n.inputMethod.enable = true;
          i18n.inputMethod.type = "fcitx5";

          i18n.inputMethod.fcitx5.addons =
            lib.optional (cjkEngine != null) cjkEngine.package ++ cfg.engines;

          i18n.inputMethod.fcitx5.settings.inputMethod = profile;

          environment.variables = {
            GTK_IM_MODULE = "fcitx";
            QT_IM_MODULE = "fcitx";
            XMODIFIERS = "@im=fcitx";
            SDL_IM_MODULE = "fcitx";
          };

          fonts.packages = lib.optionals (cfg.cjkForms != "none") [
            pkgs.noto-fonts-cjk-sans
            pkgs.noto-fonts-cjk-serif
          ];
      };
    };

}
