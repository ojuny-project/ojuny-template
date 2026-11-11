/*
  @menu
  displayname = "Display";
  icon = "preferences-desktop-display-symbolic";
  order = 10;
  description = "Monitors, tearing and HDR";
  category = "02-Core";
*/

{ self, inputs, ... }: {

  flake.modules.nixos.desktop-display =
    { config, lib, ... }:

    {
      imports = [ self.modules.nixos.desktop-display-backend ];

      config = {

        # Monitors
        # @option widget = "monitors"; label = "Monitors"; group = "Monitors"; groupOrder = 10; disabledFeatures = [ "match" "mirror" "priority" "modeline" "power" "reflection" "focusAtStartup" "brightness" "autoRotation" "autoHdr" "color.profile" "color.wideGamut" "color.bitDepth" "hdr.sdrBrightness" "hdr.sdrSaturation" "hdr.sdrMinLuminance" "hdr.sdrMaxLuminance" "hdr.sdrEotf" "sync.allowTearing" "sync.maxRenderTime" "render" "signal" "reserved" "hotCorners" "background" ]; description = "Drag monitors to set their position. The output name is the identity; replace a monitor by removing the old row and adding the new one.";
        services.nix-settings-gui.monitors = {
          "eDP-1" = {
            width = 1920;
            height = 1080;
            refresh = 60;
            xPos = 0;
            yPos = 0;
            scale = 1.0;
            transform = "normal";
          };
          "HDMI-A-1" = {
            width = 1920;
            height = 1080;
            refresh = 60;
            xPos = 1920;
            yPos = 0;
            scale = 1.0;
            transform = "90";
          };
        };

        # Tearing and HDR
        # @option widget = "dropdown"; label = "Allow tearing"; group = "Tearing and HDR"; groupOrder = 20; choices = [ "disable" "enable" "fullscreen-only" ]; applyCommand = "case %%val%% in disable) v=0;; enable) v=1;; fullscreen-only) v=2;; esac; mmsg dispatch setoption,allow_tearing,$v";
        ojuny.mango.enum.allow_tearing = "disable";

        # @option widget = "dropdown"; label = "HDR depth"; group = "Tearing and HDR"; groupOrder = 20; choices = [ "default" "hdr8" "hdr10" ]; description = "Requires HDR in the monitor rule and the Vulkan renderer."; applyCommand = "case %%val%% in default) v=0;; hdr8) v=1;; hdr10) v=2;; esac; mmsg dispatch setoption,hdr_depth,$v";
        ojuny.mango.enum.hdr_depth = "hdr10";

        # @option widget = "switch"; label = "Do not scale XWayland"; group = "Tearing and HDR"; groupOrder = 20; applyCommand = "mmsg dispatch setoption,xwayland_ignore_scale,$(case %%val%% in true) echo 1;; *) echo 0;; esac)";
        ojuny.mango.flag.xwayland_ignore_scale = false;

        # Gamma and contrast
        # @option widget = "slider"; label = "Gamma"; group = "Gamma and contrast"; groupOrder = 40; min = 0.5; max = 2.0; step = 0.05; description = "Panel gamma, 1.0 is neutral. Requires DMS API v34+."; applyCommand = "dms ipc call night gamma %%val%%";
        desktop.ojuny.dux.session.displayGamma = 1.0;

        # @option widget = "slider"; label = "Contrast"; group = "Gamma and contrast"; groupOrder = 40; min = 0.5; max = 2.0; step = 0.05; description = "Panel contrast, 1.0 is neutral. Requires DMS API v34+."; applyCommand = "dms ipc call night contrast %%val%%";
        desktop.ojuny.dux.session.displayContrast = 1.0;

      };
    };

}
