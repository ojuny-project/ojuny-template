/*
  @menu
  displayname = "Login";
  icon = "system-log-out-symbolic";
  order = 10;
  description = "Greeter and display manager";
  category = "03-Desktop";
  hidden = true;
*/

{ self, inputs, ... }: {

  flake.modules.nixos.desktop-login =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      imports = [ self.modules.nixos.desktop-login-backend ];

      # @option widget = "switch"; label = "Auto login"; group = "Greeter"; groupOrder = 20; order = 10; hidden = true; advanced = true; description = "Log in to the last session without a password. This bypasses the greeter."; applyCommand = "dms ipc call settings set greeterAutoLogin %%val%%";
      desktop.ojuny.dux.settings.greeterAutoLogin = false;

      # @option widget = "switch"; label = "Follow lock screen widgets"; group = "Greeter"; groupOrder = 20; order = 20; hidden = true; advanced = true; description = "Mirror the lock screen widget layout on the greeter. Save and Rebuild is required."; applyCommand = "dms ipc call settings set greeterFollowLockScreen %%val%%";
      desktop.ojuny.dux.settings.greeterFollowLockScreen = true;

      # @option widget = "switch"; label = "Remember last session"; group = "Greeter"; groupOrder = 20; order = 40; advanced = true; description = "Preselect the last used session on the greeter."; applyCommand = "dms ipc call settings set greeterRememberLastSession %%val%%";
      desktop.ojuny.dux.settings.greeterRememberLastSession = true;

      # @option widget = "switch"; label = "Remember last user"; group = "Greeter"; groupOrder = 20; order = 50; advanced = true; description = "Preselect the last logged in user on the greeter."; applyCommand = "dms ipc call settings set greeterRememberLastUser %%val%%";
      desktop.ojuny.dux.settings.greeterRememberLastUser = true;

      # @option widget = "switch"; label = "PAM managed externally"; group = "Greeter"; groupOrder = 20; order = 60; advanced = true; description = "Leave greeter authentication to an externally managed PAM configuration."; applyCommand = "dms ipc call settings set greeterPamExternallyManaged %%val%%";
      desktop.ojuny.dux.settings.greeterPamExternallyManaged = false;

      # @option widget = "switch"; label = "Fingerprint login"; group = "Greeter"; groupOrder = 20; order = 70; advanced = true; description = "Allow fingerprint authentication on the greeter."; applyCommand = "dms ipc call settings set greeterEnableFprint %%val%%";
      desktop.ojuny.dux.settings.greeterEnableFprint = false;

      # @option widget = "switch"; label = "Security key login"; group = "Greeter"; groupOrder = 20; order = 80; advanced = true; description = "Allow U2F security key authentication on the greeter."; applyCommand = "dms ipc call settings set greeterEnableU2f %%val%%";
      desktop.ojuny.dux.settings.greeterEnableU2f = false;

      # @option widget = "raw"; label = "Widget layout"; group = "Greeter"; groupOrder = 20; order = 30; rows = 12; hidden = true; advanced = true; description = "Greeter widget instances with id, widgetType, enabled and config. Defaults to the lock screen widgets the greeter can render plus the session picker. Save and Rebuild is required.";
      desktop.ojuny.dux.settings.greeterWidgetInstances = [
        {
          id = "lock_clock";
          widgetType = "desktopClock";
          enabled = true;
          config = {
            displayPreferences = [ "all" ];
            syncPositionAcrossScreens = true;
            colorMode = "default";
            customColor = "#ffffff";
            style = "expressive";
            transparency = 0;
            weight = 0;
            twoTone = true;
            showDate = false;
            showDigitalSeconds = false;
            showAnalogNumbers = false;
            showAnalogSeconds = true;
            autoPosition = true;
          };
        }
        {
          id = "lock_date";
          widgetType = "lockDate";
          enabled = false;
          config = {
            displayPreferences = [ "all" ];
            syncPositionAcrossScreens = true;
            colorMode = "default";
            customColor = "#ffffff";
            format = "short";
          };
        }
        {
          id = "lock_auth";
          widgetType = "lockAuth";
          enabled = true;
          config = {
            style = "expressive";
            profileVisibility = "always";
            passwordVisibility = "always";
          };
        }
        {
          id = "lock_status";
          widgetType = "lockStatus";
          enabled = true;
          config = {
            showMediaPlayer = true;
            showWeather = true;
            background = false;
          };
        }
        {
          id = "lock_power";
          widgetType = "lockPower";
          enabled = false;
          config = {
            shape = "round";
          };
        }
        {
          id = "greeter_session";
          widgetType = "greeterSession";
          enabled = true;
          config = {
            displayPreferences = [ "all" ];
            syncPositionAcrossScreens = true;
          };
        }
      ];

      programs.dms-greeter = {
        # @option widget = "switch"; label = "Enable greeter"; group = "Greeter"; groupOrder = 10; order = 10;
        enable = true;
        # @option widget = "dropdown"; label = "Compositor"; group = "Greeter"; groupOrder = 10; order = 20; choices = [ "sway" ];
        compositor = {
          name = "sway";
          package = pkgs.sway;
          customConfig = lib.mkIf config.ojuny.plymouth.enable
            "exec ${lib.getExe' config.boot.plymouth.package "plymouth"} quit --retain-splash";
        };
      };
    };
}
