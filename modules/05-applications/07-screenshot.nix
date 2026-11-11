/*
  @menu
  displayname = "Screenshots";
  icon = "camera-photo-symbolic";
  order = 70;
  description = "Screenshot capture and annotation";
  category = "05-Applications";
*/

{ self, inputs, ... }: {

  flake.modules.nixos.applications-screenshot =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      imports = [ self.modules.nixos.applications-screenshot-backend ];

      config = {
        # @option widget = "switch"; label = "Screenshot editing"; group = "Screenshots"; description = "Install satty and the capture-and-annotate wrapper.";
        ojuny.apps.screenshot.enable = true;

        # @option widget = "switch"; label = "OCR text capture"; group = "OCR"; groupOrder = 20; order = 10; description = "Install Tesseract and the capture-text command for region OCR.";
        ojuny.apps.screenshot.ocr.enable = true;

        # @option widget = "list"; label = "OCR languages"; group = "OCR"; groupOrder = 20; order = 20; visibleWhen.path = "ojuny.apps.screenshot.ocr.enable"; visibleWhen.equals = true; description = "Tesseract language codes, for example eng, deu, or nld. Only the listed packs are installed.";
        ojuny.apps.screenshot.ocr.languages = [ "eng" ];

        # @option widget = "keybinds"; label = "Screenshot binds"; group = "Binds"; groupOrder = 30; description = "Screenshot keys. They stay in the always-active common bind mode.";
        desktop.ojuny.mango.binds.common = {
        screenshotMenu = {
          modifier = [
            "SUPER"
            "ALT"
          ];
          keys = [ "PRINT" ];
          dispatcher = "spawn";
          args = "ojuny-screenshot-menu";
          description = "Screenshot menu (Super+Alt+Print)";
          group = "System";
          subcat = "Screenshots";
        };
        screenshot = {
          modifier = [ ];
          keys = [ "PRINT" ];
          dispatcher = "spawn";
          args = "dms screenshot";
          description = "Selection screenshot";
          group = "System";
          subcat = "Screenshots";
        };
        screenshotFull = {
          modifier = [ "ALT" ];
          keys = [ "PRINT" ];
          dispatcher = "spawn";
          args = "dms screenshot full";
          description = "Fullscreen screenshot";
          group = "System";
          subcat = "Screenshots";
        };
        screenshotWindow = {
          modifier = [ "SUPER" ];
          keys = [ "PRINT" ];
          dispatcher = "spawn";
          args = "dms screenshot window";
          description = "Focused window screenshot";
          group = "System";
          subcat = "Screenshots";
        };
        screenshotEdit = {
          modifier = [
            "SUPER"
            "SHIFT"
          ];
          keys = [ "PRINT" ];
          dispatcher = "spawn";
          args = "ojuny-screenshot-edit region";
          description = "Annotate region screenshot";
          group = "System";
          subcat = "Screenshots";
        };
        screenshotEditWindow = {
          modifier = [
            "SUPER"
            "SHIFT"
            "CTRL"
          ];
          keys = [ "PRINT" ];
          dispatcher = "spawn";
          args = "ojuny-screenshot-edit window";
          description = "Annotate window screenshot";
          group = "System";
          subcat = "Screenshots";
        };
        captureText = {
          modifier = [
            "SUPER"
            "SHIFT"
          ];
          keys = [ "O" ];
          dispatcher = "spawn";
          args = [ "ojuny-capture-text" ];
          description = "OCR capture and copy text (Super+Shift+O)";
          group = "System";
          subcat = "Screenshots";
        };
        captureQr = {
          modifier = [
            "SUPER"
            "SHIFT"
          ];
          keys = [ "Q" ];
          dispatcher = "spawn";
          args = [ "ojuny-capture-qr" ];
          description = "Scan QR code from screen (Super+Shift+Q)";
          group = "System";
          subcat = "Screenshots";
        };
        captureScroll = {
          modifier = [
            "SUPER"
            "SHIFT"
          ];
          keys = [ "X" ];
          dispatcher = "spawn";
          args = [ "dms screenshot scroll" ];
          description = "Scroll capture (Super+Shift+X)";
          group = "System";
          subcat = "Screenshots";
        };
        };
      };
    };

}
