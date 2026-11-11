{ ... }: {

  flake.modules.nixos.applications-screenshot-backend =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.ojuny.apps.screenshot;
      ocrLanguageCodes = lib.unique ([ "eng" ] ++ cfg.ocr.languages);
      ocrLanguages = lib.concatStringsSep "+" ocrLanguageCodes;
      tesseractPackage = pkgs.tesseract.override {
        enableLanguages = ocrLanguageCodes;
      };
      capturePath = lib.makeBinPath (
        [
          pkgs.grim
          pkgs.slurp
          pkgs.wl-clipboard
          pkgs.libnotify
          pkgs.zbar
        ]
        ++ lib.optionals cfg.ocr.enable [ tesseractPackage ]
      );
    in
    {
      options.ojuny.apps.screenshot = {
        enable = lib.mkEnableOption "screenshot editing with satty";

        ocr.enable = lib.mkEnableOption "OCR text capture";

        ocr.languages = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [ "eng" ];
          description = "Tesseract language codes used for OCR, for example eng or deu. English is always installed.";
        };
      };

      config = {
        environment.systemPackages = lib.mkIf cfg.enable (
          with pkgs;
          [
            satty
            jq
            grim
            slurp
            wl-clipboard
            imagemagick
            zbar
            (writeShellApplication {
              name = "ojuny-screenshot-menu";
              runtimeInputs = [ coreutils ];
              text = builtins.readFile ../../../scripts/ojuny-screenshot-menu.sh;
            })
            (writeShellApplication {
              name = "ojuny-screenshot-edit";
              runtimeInputs = [
                jq
                satty
              ];
              text = builtins.readFile ../../../scripts/ojuny-screenshot-edit.sh;
            })
            (writeShellScriptBin "ojuny-capture-text" ''
              export PATH="${capturePath}:$PATH"
              export OJUNY_OCR_LANGS="${ocrLanguages}"
              ${builtins.readFile ../../../scripts/ojuny-capture-text}
            '')
            (writeShellScriptBin "ojuny-capture-qr" ''
              export PATH="${capturePath}:$PATH"
              ${builtins.readFile ../../../scripts/ojuny-capture-qr}
            '')
            (writeShellScriptBin "ojuny-capture-scroll" (
              builtins.readFile ../../../scripts/ojuny-capture-scroll
            ))
          ]
          ++ lib.optionals cfg.ocr.enable [
            tesseractPackage
          ]
        );
      };
    };

}
