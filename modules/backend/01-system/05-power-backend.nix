{ self, inputs, ... }: {

  flake.modules.nixos.system-power-backend =
    {
      config,
      lib,
      pkgs,
      ...
    }:

    let
      notificationStyles = {
        "toast" = 0;
        "notification" = 1;
      };

      powerProfiles = {
        "unchanged" = "";
        "power-saver" = "0";
        "balanced" = "1";
        "performance" = "2";
      };

      timeoutPresets = {
        "never" = 0;
        "15 seconds" = 15;
        "30 seconds" = 30;
        "1 minute" = 60;
        "2 minutes" = 120;
        "3 minutes" = 180;
        "5 minutes" = 300;
        "10 minutes" = 600;
        "15 minutes" = 900;
        "20 minutes" = 1200;
        "30 minutes" = 1800;
        "1 hour" = 3600;
        "1.5 hours" = 5400;
        "2 hours" = 7200;
        "3 hours" = 10800;
      };

      suspendBehaviors = {
        "suspend" = 0;
        "hibernate" = 1;
        "suspend-then-hibernate" = 2;
      };

      enumSpecs = {
        batteryChargeLimitNotificationType = {
          default = "toast";
          choices = notificationStyles;
        };
        batteryLowNotificationType = {
          default = "toast";
          choices = notificationStyles;
        };
        batteryCriticalNotificationType = {
          default = "notification";
          choices = notificationStyles;
        };
        acProfileName = {
          default = "unchanged";
          choices = powerProfiles;
        };
        batteryProfileName = {
          default = "unchanged";
          choices = powerProfiles;
        };
        acLockTimeout = {
          default = "never";
          choices = timeoutPresets;
        };
        batteryLockTimeout = {
          default = "never";
          choices = timeoutPresets;
        };
        acMonitorTimeout = {
          default = "never";
          choices = timeoutPresets;
        };
        batteryMonitorTimeout = {
          default = "never";
          choices = timeoutPresets;
        };
        acPostLockMonitorTimeout = {
          default = "never";
          choices = timeoutPresets;
        };
        batteryPostLockMonitorTimeout = {
          default = "never";
          choices = timeoutPresets;
        };
        acSuspendTimeout = {
          default = "never";
          choices = timeoutPresets;
        };
        batterySuspendTimeout = {
          default = "never";
          choices = timeoutPresets;
        };
        acSuspendBehavior = {
          default = "suspend";
          choices = suspendBehaviors;
        };
        batterySuspendBehavior = {
          default = "suspend";
          choices = suspendBehaviors;
        };
      };

      idleInhibitRows = config.ojuny.power.idleInhibitPrograms;

      idleInhibitField =
        row:
        if row.appId != "" then
          "appId"
        else if row.title != "" then
          "title"
        else
          "";

      idleInhibitKey =
        row:
        let
          field = idleInhibitField row;
        in
        if field == "" then "" else "${field}:${row.${field}}";

      lidScript = pkgs.writeShellScript "ojuny-lid" ''
        export PATH=${lib.makeBinPath [ pkgs.jq pkgs.util-linux ]}:$PATH

        mode="''${1:-}"
        tag="ojuny-lid"

        log() {
          logger -t "$tag" "$*"
        }

        if [ -z "''${MANGO_INSTANCE_SIGNATURE:-}" ]; then
          log "missing MANGO_INSTANCE_SIGNATURE; leaving the panel unchanged"
          exit 1
        fi

        if ! monitors=$(mmsg get all-monitors 2>/dev/null); then
          log "mmsg get all-monitors failed; leaving the panel unchanged"
          exit 1
        fi

        if ! names=$(printf '%s' "$monitors" | jq -r '.monitors[] | select(.active == true) | .name' 2>/dev/null); then
          log "could not parse mmsg output; leaving the panel unchanged"
          exit 1
        fi

        if [ -z "$names" ]; then
          log "no active monitors; leaving the panel unchanged"
          exit 1
        fi

        internal=$(printf '%s\n' "$names" | grep -E '^(eDP|LVDS|DSI)-' | head -n 1)
        external=$(printf '%s\n' "$names" | grep -Ev '^(eDP|LVDS|DSI|HEADLESS)-' | head -n 1)

        case "$mode" in
          fold)
            if [ -z "$internal" ]; then
              log "no internal panel; nothing to sleep"
              exit 0
            fi
            if [ -z "$external" ]; then
              log "no external display; logind will handle suspend"
              exit 0
            fi
            if mmsg dispatch "sleep_monitor,$internal" >/dev/null 2>&1; then
              log "external display $external present; slept internal panel $internal"
            else
              log "failed to sleep internal panel $internal"
              exit 1
            fi
            ;;
          unfold)
            if [ -z "$internal" ]; then
              log "no internal panel; nothing to wake"
              exit 0
            fi
            if mmsg dispatch "wakeup_monitor,$internal" >/dev/null 2>&1; then
              log "woke internal panel $internal"
            else
              log "failed to wake internal panel $internal"
              exit 1
            fi
            ;;
          *)
            log "unknown mode '$mode'; expected fold or unfold"
            exit 1
            ;;
        esac
      '';

      lidAction =
        if config.ojuny.power.lidPolicy == "clamshell" then {
          HandleLidSwitch = "suspend";
          HandleLidSwitchExternalPower = "suspend";
          HandleLidSwitchDocked = "ignore";
        } else {
          HandleLidSwitch = config.ojuny.power.lidPolicy;
          HandleLidSwitchExternalPower = config.ojuny.power.lidPolicy;
          HandleLidSwitchDocked = config.ojuny.power.lidPolicy;
        };
    in
    {

      options.ojuny.dux = lib.mapAttrs (
        name: spec:
        lib.mkOption {
          type = lib.types.enum (lib.attrNames spec.choices);
          inherit (spec) default;
          description = "DMS ${name}.";
        }
      ) enumSpecs;

      options.ojuny.power.idleInhibitPrograms = lib.mkOption {
        type = lib.types.listOf (
          lib.types.submodule {
            options = {
              appId = lib.mkOption {
                type = lib.types.str;
                default = "";
                description = "Mango app_id regex pattern. Empty when the row matches by title.";
              };
              title = lib.mkOption {
                type = lib.types.str;
                default = "";
                description = "Mango window title regex pattern. Empty when the row matches by app_id.";
              };
            };
          }
        );
        default = [ ];
        description = "Focus programs that keep the system awake through the Mango idle_inhibit_when_focus window rule. Each row sets either appId or title, as a regex pattern.";
      };

      options.ojuny.power.lidPolicy = lib.mkOption {
        type = lib.types.enum [
          "suspend"
          "ignore"
          "clamshell"
        ];
        default = "suspend";
        description = "What systemd-logind does when the laptop lid closes: suspend, ignore, or clamshell.";
      };

      config = {

        assertions = lib.concatMap (
          row:
          let
            field = idleInhibitField row;
            pattern = if field == "" then "" else row.${field};
            duplicate =
              builtins.length (
                lib.filter (key: key == idleInhibitKey row) (map idleInhibitKey idleInhibitRows)
              ) > 1;
          in
          [
            {
              assertion = (row.appId != "") != (row.title != "");
              message = "ojuny.power.idleInhibitPrograms: row { appId = \"${row.appId}\"; title = \"${row.title}\"; } must set exactly one of appId or title, never both and never neither.";
            }
            {
              assertion = field == "" || lib.trim pattern != "";
              message = "ojuny.power.idleInhibitPrograms: the ${if field == "" then "appId or title" else field} pattern in row { appId = \"${row.appId}\"; title = \"${row.title}\"; } must not be empty or whitespace-only.";
            }
            {
              assertion = !duplicate;
              message = "ojuny.power.idleInhibitPrograms: duplicate ${field} pattern \"${pattern}\"; each field and pattern pair may appear only once.";
            }
          ]
        ) idleInhibitRows;

        desktop.ojuny.dux.settings.batteryChargeLimitNotificationType =
          notificationStyles.${config.ojuny.dux.batteryChargeLimitNotificationType};

        desktop.ojuny.dux.settings.batteryLowNotificationType =
          notificationStyles.${config.ojuny.dux.batteryLowNotificationType};

        desktop.ojuny.dux.settings.batteryCriticalNotificationType =
          notificationStyles.${config.ojuny.dux.batteryCriticalNotificationType};

        desktop.ojuny.dux.settings.acProfileName = powerProfiles.${config.ojuny.dux.acProfileName};

        desktop.ojuny.dux.settings.batteryProfileName =
          powerProfiles.${config.ojuny.dux.batteryProfileName};

        services.logind.settings.Login.HandleLidSwitch = lidAction.HandleLidSwitch;
        services.logind.settings.Login.HandleLidSwitchExternalPower = lidAction.HandleLidSwitchExternalPower;
        services.logind.settings.Login.HandleLidSwitchDocked = lidAction.HandleLidSwitchDocked;

        desktop.ojuny.mango.switchbind = lib.mkIf (config.ojuny.power.lidPolicy == "clamshell") {
          default = {
            fold = "spawn,${lidScript} fold";
            unfold = "spawn,${lidScript} unfold";
          };
        };

        # One window_rule per row; the regex pattern is passed through unchanged.
        desktop.ojuny.mango.rules.window_rule = lib.mkAfter (
          map (
            row:
            { idle_inhibit_when_focus = 1; }
            // lib.optionalAttrs (row.appId != "") { app_id = row.appId; }
            // lib.optionalAttrs (row.title != "") { title = row.title; }
          ) idleInhibitRows
        );

        desktop.ojuny.dux.settings.acLockTimeout = timeoutPresets.${config.ojuny.dux.acLockTimeout};

        desktop.ojuny.dux.settings.batteryLockTimeout =
          timeoutPresets.${config.ojuny.dux.batteryLockTimeout};

        desktop.ojuny.dux.settings.acMonitorTimeout = timeoutPresets.${config.ojuny.dux.acMonitorTimeout};

        desktop.ojuny.dux.settings.batteryMonitorTimeout =
          timeoutPresets.${config.ojuny.dux.batteryMonitorTimeout};

        desktop.ojuny.dux.settings.acPostLockMonitorTimeout =
          timeoutPresets.${config.ojuny.dux.acPostLockMonitorTimeout};

        desktop.ojuny.dux.settings.batteryPostLockMonitorTimeout =
          timeoutPresets.${config.ojuny.dux.batteryPostLockMonitorTimeout};

        desktop.ojuny.dux.settings.acSuspendTimeout = timeoutPresets.${config.ojuny.dux.acSuspendTimeout};

        desktop.ojuny.dux.settings.batterySuspendTimeout =
          timeoutPresets.${config.ojuny.dux.batterySuspendTimeout};

        desktop.ojuny.dux.settings.acSuspendBehavior =
          suspendBehaviors.${config.ojuny.dux.acSuspendBehavior};

        desktop.ojuny.dux.settings.batterySuspendBehavior =
          suspendBehaviors.${config.ojuny.dux.batterySuspendBehavior};

        desktop.ojuny.dux.settings.powerMenuActions = [
          "reboot"
          "logout"
          "poweroff"
          "lock"
          "suspend"
          "hibernate"
          "restart"
        ];

      };
    };

}
