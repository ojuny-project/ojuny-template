/*
  @menu
  displayname = "Accessibility";
  icon = "preferences-desktop-accessibility-symbolic";
  order = 65;
  description = "Screen reader, braille, on-screen keyboard, color profiles and accessibility binds";
  category = "07-System";
*/

{ self, inputs, ... }: {

  flake.modules.nixos.system-accessibility =
    {
      config,
      lib,
      pkgs,
      ...
    }:

    let
      screenReaderToggle = pkgs.writeShellScript "ojuny-screen-reader-toggle" ''
        export PATH=${lib.makeBinPath [ pkgs.procps ]}:$PATH

        orca="${config.services.orca.package}/bin/orca"
        pid=$(pgrep -f "$orca" | head -n 1)
        if [ -n "$pid" ]; then
          kill "$pid"
        else
          "$orca" --replace >/dev/null 2>&1 &
        fi
      '';

      mouseModeToggle = pkgs.writeShellScript "ojuny-mouse-mode-toggle" ''
        mode=$(mmsg get keymode 2>/dev/null)
        case "$mode" in
          *mouse*) mmsg dispatch setkeymode,default ;;
          *) mmsg dispatch setkeymode,mouse ;;
        esac
      '';

      osk = config.ojuny.accessibility.onScreenKeyboard;
      oskToggle = import ../../packages/osk-toggle.nix { inherit pkgs; };
      oskTray = import ../../packages/osk-tray.nix { inherit pkgs oskToggle; };

    in
    {
      imports = [
        self.modules.nixos.system-accessibility-backend
        inputs.wvkbd.nixosModules.default
      ];

      config = {

        # @option widget = "switch"; label = "Screen reader (Orca)"; group = "Vision"; groupOrder = 10; order = 10; description = "Install Orca, Speech Dispatcher and AT-SPI, and enable Qt and DMS accessibility. Save and rebuild; Orca starts with the session.";
        services.orca.enable = false;

        # @option widget = "switch"; label = "Braille (BRLTTY)"; group = "Vision"; groupOrder = 10; order = 20; description = "Enable the BRLTTY daemon. Requires a refreshable braille display.";
        services.brltty.enable = false;

        # @option widget = "switch"; label = "High contrast"; group = "Vision"; groupOrder = 10; order = 30; description = "Use a high-contrast base16 palette instead of the normal palette. Save and rebuild.";
        ojuny.accessibility.highContrast = false;

        # @option widget = "dropdown"; label = "High-contrast palette"; group = "Vision"; groupOrder = 10; order = 40; choices = [ "windows-highcontrast" "windows-highcontrast-light" "penumbra-dark-contrast-plus-plus" "penumbra-light-contrast-plus-plus" ]; visibleWhen.path = "ojuny.accessibility.highContrast"; visibleWhen.equals = true; description = "High-contrast base16 scheme used while the switch is on.";
        ojuny.accessibility.highContrastPalette = "windows-highcontrast";

        # @option widget = "path"; label = "ICC color profile"; group = "Vision"; groupOrder = 10; order = 50; nullable = true; description = "ICC profile applied to every monitor as a build-time output color transform. HDR must be off for the output. A color inversion or colorblindness profile goes here. Save and rebuild.";
        ojuny.accessibility.iccProfile = null;

        # @option widget = "switch"; label = "Mono audio"; group = "Hearing"; groupOrder = 20; order = 10; description = "Mix all stereo content into a single channel.";
        desktop.ojuny.dux.settings.audioMono = false;

        # @option widget = "switch"; label = "Reduce motion"; group = "Motion"; groupOrder = 30; order = 10; applyCommand = "dms ipc call settings set reduceMotion %%val%%"; description = "Disable DMS motion and force Mango window animations off. Window animations apply on rebuild.";
        ojuny.accessibility.reduceMotion = false;

        # @option widget = "switch"; label = "On-screen keyboard (wvkbd)"; group = "Keyboard"; groupOrder = 25; order = 10; description = "Install wvkbd, start it with the session and theme it with the Stylix palette. It types through the wlroots virtual-keyboard and input-method protocols and works with touch.";
        ojuny.accessibility.onScreenKeyboard.enable = true;

        # @option widget = "switch"; label = "Show on text fields"; group = "Keyboard"; groupOrder = 25; order = 20; visibleWhen.path = "ojuny.accessibility.onScreenKeyboard.enable"; visibleWhen.equals = true; description = "Use wvkbd --auto so the keyboard appears when a text field takes focus and hides when focus leaves. It requires a client that enables text-input-v3: terminals never trigger it, and GTK applications depend on their input-method path, so use Super+Alt+O or the tray there.";
        ojuny.accessibility.onScreenKeyboard.auto = true;

        # @option widget = "switch"; label = "Tray toggle"; group = "Keyboard"; groupOrder = 25; order = 30; visibleWhen.path = "ojuny.accessibility.onScreenKeyboard.enable"; visibleWhen.equals = true; description = "Show a tray icon. Left click toggles the keyboard; right click opens the menu.";
        ojuny.accessibility.onScreenKeyboard.tray = true;

        # @option widget = "spin"; label = "Portrait height"; group = "Keyboard"; groupOrder = 25; order = 40; min = 120; max = 600; unit = "px"; visibleWhen.path = "ojuny.accessibility.onScreenKeyboard.enable"; visibleWhen.equals = true; description = "Keyboard height while the display is upright.";
        ojuny.accessibility.onScreenKeyboard.portraitHeight = 300;

        # @option widget = "spin"; label = "Landscape height"; group = "Keyboard"; groupOrder = 25; order = 50; min = 120; max = 600; unit = "px"; visibleWhen.path = "ojuny.accessibility.onScreenKeyboard.enable"; visibleWhen.equals = true; description = "Keyboard height while the display is sideways.";
        ojuny.accessibility.onScreenKeyboard.landscapeHeight = 200;

        # @option widget = "spin"; label = "Corner rounding"; group = "Keyboard"; groupOrder = 25; order = 60; min = 0; max = 40; unit = "px"; visibleWhen.path = "ojuny.accessibility.onScreenKeyboard.enable"; visibleWhen.equals = true; description = "Corner radius of the keys.";
        ojuny.accessibility.onScreenKeyboard.rounding = 12;

        # @option widget = "spin"; label = "Label size"; group = "Keyboard"; groupOrder = 25; order = 70; min = 8; max = 48; unit = "pt"; visibleWhen.path = "ojuny.accessibility.onScreenKeyboard.enable"; visibleWhen.equals = true; description = "Size of the key labels in the sans-serif font.";
        ojuny.accessibility.onScreenKeyboard.fontSize = 20;

        # @option widget = "keybinds"; label = "Common binds"; group = "Keybinds"; groupOrder = 40; order = 10; description = "Accessibility binds. The screen reader bind works when Orca is enabled, the on-screen keyboard bind starts or toggles wvkbd and reports when the keyboard is disabled, and the mouse mode toggle is always active.";
        desktop.ojuny.mango.binds.common = {
          accessibilityScreenReader = {
            modifier = [
              "SUPER"
              "ALT"
            ];
            keys = [ "s" ];
            dispatcher = "spawn";
            args = "${screenReaderToggle}";
            description = "Toggle the Orca screen reader";
            group = "Accessibility";
            subcat = "Screen reader";
          };
          accessibilityKeyboard = {
            modifier = [
              "SUPER"
              "ALT"
            ];
            keys = [ "o" ];
            dispatcher = "spawn";
            args = "${oskToggle}/bin/ojuny-osk-toggle";
            description = "Toggle the on-screen keyboard (Super+Alt+O)";
            group = "Accessibility";
            subcat = "Keyboard";
          };
          accessibilityMouseMode = {
            modifier = [
              "SUPER"
              "ALT"
            ];
            keys = [ "m" ];
            dispatcher = "spawn";
            args = "${mouseModeToggle}";
            description = "Toggle the keyboard mouse mode";
            group = "Accessibility";
            subcat = "Mouse mode";
          };
        };

        # @option widget = "keybinds"; label = "Mouse mode binds"; group = "Mouse mode"; groupOrder = 45; order = 10; description = "Pointer controls for the mouse keymode. Enter with SUPER+ALT+M; the mode is active only while set. Movement is 15 px per press; edit the commands to change speed. Escape or the toggle exits.";
        desktop.ojuny.mango.binds.mouse = {
          mouseUpW = {
            modifier = [ "NONE" ];
            keys = [ "w" ];
            dispatcher = "spawn";
            args = "ydotool mousemove -x 0 -y -15";
            description = "Move the pointer up";
            group = "Accessibility";
            subcat = "Mouse mode";
          };
          mouseUpArrow = {
            modifier = [ "NONE" ];
            keys = [ "Up" ];
            dispatcher = "spawn";
            args = "ydotool mousemove -x 0 -y -15";
            description = "Move the pointer up";
            group = "Accessibility";
            subcat = "Mouse mode";
          };
          mouseDownS = {
            modifier = [ "NONE" ];
            keys = [ "s" ];
            dispatcher = "spawn";
            args = "ydotool mousemove -x 0 -y 15";
            description = "Move the pointer down";
            group = "Accessibility";
            subcat = "Mouse mode";
          };
          mouseDownArrow = {
            modifier = [ "NONE" ];
            keys = [ "Down" ];
            dispatcher = "spawn";
            args = "ydotool mousemove -x 0 -y 15";
            description = "Move the pointer down";
            group = "Accessibility";
            subcat = "Mouse mode";
          };
          mouseLeftA = {
            modifier = [ "NONE" ];
            keys = [ "a" ];
            dispatcher = "spawn";
            args = "ydotool mousemove -x -15 -y 0";
            description = "Move the pointer left";
            group = "Accessibility";
            subcat = "Mouse mode";
          };
          mouseLeftArrow = {
            modifier = [ "NONE" ];
            keys = [ "Left" ];
            dispatcher = "spawn";
            args = "ydotool mousemove -x -15 -y 0";
            description = "Move the pointer left";
            group = "Accessibility";
            subcat = "Mouse mode";
          };
          mouseRightD = {
            modifier = [ "NONE" ];
            keys = [ "d" ];
            dispatcher = "spawn";
            args = "ydotool mousemove -x 15 -y 0";
            description = "Move the pointer right";
            group = "Accessibility";
            subcat = "Mouse mode";
          };
          mouseRightArrow = {
            modifier = [ "NONE" ];
            keys = [ "Right" ];
            dispatcher = "spawn";
            args = "ydotool mousemove -x 15 -y 0";
            description = "Move the pointer right";
            group = "Accessibility";
            subcat = "Mouse mode";
          };
          mouseClickLeft = {
            modifier = [ "NONE" ];
            keys = [ "space" ];
            dispatcher = "spawn";
            args = "ydotool click 0xC0";
            description = "Left click";
            group = "Accessibility";
            subcat = "Mouse mode";
          };
          mouseClickRight = {
            modifier = [ "NONE" ];
            keys = [ "Return" ];
            dispatcher = "spawn";
            args = "ydotool click 0xC1";
            description = "Right click";
            group = "Accessibility";
            subcat = "Mouse mode";
          };
          mouseClickMiddle = {
            modifier = [ "NONE" ];
            keys = [ "BackSpace" ];
            dispatcher = "spawn";
            args = "ydotool click 0xC2";
            description = "Middle click";
            group = "Accessibility";
            subcat = "Mouse mode";
          };
          mouseScrollUp = {
            modifier = [ "NONE" ];
            keys = [ "Page_Up" ];
            dispatcher = "spawn";
            args = "ydotool mousemove -w -y -1";
            description = "Scroll up";
            group = "Accessibility";
            subcat = "Mouse mode";
          };
          mouseScrollDown = {
            modifier = [ "NONE" ];
            keys = [ "Page_Down" ];
            dispatcher = "spawn";
            args = "ydotool mousemove -w -y 1";
            description = "Scroll down";
            group = "Accessibility";
            subcat = "Mouse mode";
          };
          mouseExit = {
            modifier = [ "NONE" ];
            keys = [ "Escape" ];
            dispatcher = "setkeymode";
            args = "default";
            description = "Exit the mouse mode";
            group = "Accessibility";
            subcat = "Mouse mode";
          };
        };

        services.ojuny-wvkbd = {
          enable = osk.enable;
          auto = osk.auto;
          portraitHeight = osk.portraitHeight;
          landscapeHeight = osk.landscapeHeight;
          rounding = osk.rounding;
          fontSize = osk.fontSize;
          fontFamily = config.stylix.fonts.sansSerif.name;
          colors = self.colors config.lib.stylix.colors;
          target = "mango-session.target";
        };

        environment.systemPackages = lib.mkIf osk.enable [
          oskToggle
          oskTray
        ];

        systemd.user.services.ojuny-osk-tray = lib.mkIf (osk.enable && osk.tray) {
          description = "Ojuny on-screen keyboard tray";
          partOf = [ "mango-session.target" ];
          wantedBy = [ "mango-session.target" ];
          serviceConfig = {
            ExecStart = "${oskTray}/bin/ojuny-osk-tray";
            Restart = "on-failure";
          };
        };
      };
    };

}
