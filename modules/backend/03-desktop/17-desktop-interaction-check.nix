{ self, ... }:
{
  perSystem =
    { pkgs, lib, ... }:
    let
      source = pkgs.lib.cleanSource ../../..;
      fixture = self.nixosConfigurations.fixture;
      findRule =
        config: appId:
        builtins.head (
          builtins.filter (rule: (rule.app_id or "") == appId) config.desktop.ojuny.mango.rules.window_rule
        );
      autoRotateFixture = fixture.extendModules {
        modules = [ { services.nix-settings-gui.monitors."eDP-1".autoRotation = lib.mkForce true; } ];
      };
      payload = pkgs.writeText "desktop-interaction-eval.json" (
        builtins.toJSON {
          quakeRule = findRule fixture.config "org.ojuny.quake";
          extraRule = findRule (
            fixture.extendModules {
              modules = [
                {
                  ojuny.scratchpads.extra = {
                    appId = "org.example.Extra";
                    command = "foot";
                    chord = "SUPER+F9";
                  };
                }
              ];
            }
          ).config "org.example.Extra";
          middleClick = fixture.config.desktop.ojuny.mango.mousebind.default.maximize;
          middleClickPolicy = {
            inherit (fixture.config.ojuny.mango.middleClick) floating tiling;
          };
          displayToggle = fixture.config.desktop.ojuny.mango.binds.common.displayToggle;
          displayAll = fixture.config.desktop.ojuny.mango.binds.common.displayAll;
          steamTheme = fixture.config.ojuny.steam.theme;
          steamThemeName = fixture.config.ojuny.steam.themeName;
          steamPackage = fixture.config.programs.steam.package.pname or "";
          steamOffPackage =
            (fixture.extendModules {
              modules = [ { ojuny.steam.theme = lib.mkForce false; } ];
            }).config.programs.steam.package.pname
            or "";
          autoRotateExec =
            autoRotateFixture.config.systemd.user.services.ojuny-auto-rotate.serviceConfig.ExecStart;
          autoRotateSensor = autoRotateFixture.config.hardware.sensor.iio.enable;
          autoRotateDisabled =
            !(fixture.config.systemd.user.services ? ojuny-auto-rotate);
        }
      );
    in
    {
      checks.desktop-interaction-scripts =
        pkgs.runCommand "check-desktop-interaction-scripts"
          {
            nativeBuildInputs = [
              pkgs.bash
              pkgs.coreutils
              pkgs.gnugrep
              pkgs.jq
              pkgs.util-linux
            ];
          }
          ''
            bash ${source}/scripts/check-desktop-interaction.sh
            touch $out
          '';

      checks.clipboard-doctor =
        pkgs.runCommand "check-clipboard-doctor"
          {
            nativeBuildInputs = [
              pkgs.bash
              pkgs.coreutils
              pkgs.gnugrep
            ];
          }
          ''
            bash ${source}/tests/check-clipboard-doctor.sh ${source}/scripts/ojuny-clipboard-doctor.sh
            touch $out
          '';

      checks.quake-toggle =
        pkgs.runCommand "check-quake-toggle"
          {
            nativeBuildInputs = [
              pkgs.bash
              pkgs.coreutils
              pkgs.gnugrep
              pkgs.jq
            ];
          }
          ''
            bash ${source}/tests/check-quake-toggle.sh ${source}/scripts/ojuny-quake-toggle.sh
            touch $out
          '';

      checks.auto-rotate-scripts =
        pkgs.runCommand "check-auto-rotate"
          {
            nativeBuildInputs = [
              pkgs.bash
              pkgs.coreutils
              pkgs.gnugrep
            ];
          }
          ''
            bash ${source}/tests/check-auto-rotate.sh ${source}/scripts/ojuny-auto-rotate.sh
            touch $out
          '';

      checks.desktop-interaction-eval =
        pkgs.runCommand "check-desktop-interaction-eval"
          {
            nativeBuildInputs = [
              pkgs.gnugrep
              pkgs.jq
            ];
          }
          ''
            jq -e '.quakeRule.width == 0.7' ${payload}
            jq -e '.quakeRule.height == 0.55' ${payload}
            jq -e '.quakeRule.offset_y == -100' ${payload}
            jq -e '.quakeRule.is_overlay == 1' ${payload}
            jq -e '.extraRule.width == null and .extraRule.height == null and .extraRule.offset_y == null and .extraRule.is_overlay == null' ${payload}
            jq -e '.middleClick.dispatcher == "spawn_shell"' ${payload}
            jq -e '.middleClick.args == "ojuny-middle-click maximize zoom"' ${payload}
            jq -e '.middleClickPolicy.floating == "maximize" and .middleClickPolicy.tiling == "zoom"' ${payload}
            jq -e '.displayToggle.keys == [ "O" ] and .displayToggle.modifier == [ "SUPER" ] and (.displayToggle.args | endswith("ojuny-display-toggle focused"))' ${payload}
            jq -e '.displayAll.keys == [ "O" ] and .displayAll.modifier == [ "SUPER", "SHIFT" ] and (.displayAll.args | endswith("ojuny-display-toggle all"))' ${payload}
            jq -e '.steamTheme == true and .steamThemeName == "Adwaita"' ${payload}
            jq -e '.steamPackage == "steam-with-millennium"' ${payload}
            jq -e '.steamOffPackage == "steam"' ${payload}
            jq -e '.autoRotateExec | endswith("ojuny-auto-rotate eDP-1")' ${payload}
            jq -e '.autoRotateSensor == true' ${payload}
            jq -e '.autoRotateDisabled == true' ${payload}
            grep -q 'sleep_toggle_monitor' ${source}/scripts/ojuny-display-toggle.sh
            if grep -q 'mmsg dispatch "toggle_monitor' ${source}/scripts/ojuny-display-toggle.sh; then
              echo "the display toggle must not use toggle_monitor" >&2
              exit 1
            fi
            if grep -q 'reload_config' ${source}/scripts/ojuny-display-toggle.sh; then
              echo "the display toggle must not reload the layout" >&2
              exit 1
            fi
            touch $out
          '';
    };
}
