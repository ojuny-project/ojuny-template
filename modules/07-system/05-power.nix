/*
  @menu
  displayname = "Power";
  icon = "preferences-system-power-symbolic";
  order = 50;
  description = "Charge limit, battery alerts, idle timeouts, stay awake and power actions";
  category = "07-System";
*/

{ self, inputs, ... }: {

  flake.modules.nixos.system-power =
    { ... }:

    {
      imports = [ self.modules.nixos.system-power-backend ];

      config = {

        # @option widget = "slider"; label = "Charge limit"; group = "Battery"; groupOrder = 10; order = 10; min = 50; max = 100; step = 1; unit = "%"; description = "Stop charging at this percentage (needs a writable sysfs threshold)."; applyCommand = "dms ipc call settings set batteryChargeLimit %%val%%";
        desktop.ojuny.dux.settings.batteryChargeLimit = 100;

        # @option widget = "switch"; label = "Notify when limit is reached"; group = "Battery"; groupOrder = 10; order = 20; applyCommand = "dms ipc call settings set batteryNotifyChargeLimit %%val%%";
        desktop.ojuny.dux.settings.batteryNotifyChargeLimit = false;

        # @option widget = "dropdown"; label = "Alert style"; group = "Battery"; groupOrder = 10; order = 30; choices = [ "toast" "notification" ]; visibleWhen.path = "desktop.ojuny.dux.settings.batteryNotifyChargeLimit"; visibleWhen.equals = true; applyCommand = "case %%val%% in toast) v=0;; notification) v=1;; esac; dms ipc call settings set batteryChargeLimitNotificationType $v";
        ojuny.dux.batteryChargeLimitNotificationType = "toast";

        # @option widget = "slider"; label = "Low threshold"; group = "Battery alerts"; groupOrder = 20; order = 10; min = 5; max = 40; step = 1; unit = "%"; applyCommand = "dms ipc call settings set batteryLowThreshold %%val%%";
        desktop.ojuny.dux.settings.batteryLowThreshold = 20;

        # @option widget = "switch"; label = "Low notification"; group = "Battery alerts"; groupOrder = 20; order = 20; applyCommand = "dms ipc call settings set batteryNotifyLow %%val%%";
        desktop.ojuny.dux.settings.batteryNotifyLow = false;

        # @option widget = "dropdown"; label = "Alert style"; group = "Battery alerts"; groupOrder = 20; order = 30; choices = [ "toast" "notification" ]; visibleWhen.path = "desktop.ojuny.dux.settings.batteryNotifyLow"; visibleWhen.equals = true; applyCommand = "case %%val%% in toast) v=0;; notification) v=1;; esac; dms ipc call settings set batteryLowNotificationType $v";
        ojuny.dux.batteryLowNotificationType = "toast";

        # @option widget = "slider"; label = "Critical threshold"; group = "Battery alerts"; groupOrder = 20; order = 40; min = 1; max = 30; step = 1; unit = "%"; applyCommand = "dms ipc call settings set batteryCriticalThreshold %%val%%";
        desktop.ojuny.dux.settings.batteryCriticalThreshold = 10;

        # @option widget = "switch"; label = "Critical notification"; group = "Battery alerts"; groupOrder = 20; order = 50; applyCommand = "dms ipc call settings set batteryNotifyCritical %%val%%";
        desktop.ojuny.dux.settings.batteryNotifyCritical = true;

        # @option widget = "dropdown"; label = "Alert style"; group = "Battery alerts"; groupOrder = 20; order = 60; choices = [ "toast" "notification" ]; visibleWhen.path = "desktop.ojuny.dux.settings.batteryNotifyCritical"; visibleWhen.equals = true; applyCommand = "case %%val%% in toast) v=0;; notification) v=1;; esac; dms ipc call settings set batteryCriticalNotificationType $v";
        ojuny.dux.batteryCriticalNotificationType = "notification";

        # @option widget = "switch"; label = "Pulse animation"; group = "Battery alerts"; groupOrder = 20; order = 70; description = "Blink the battery indicator at the critical threshold."; applyCommand = "dms ipc call settings set batteryCriticalAnimation %%val%%";
        desktop.ojuny.dux.settings.batteryCriticalAnimation = true;

        # @option widget = "switch"; label = "Auto power saver"; group = "Power profiles"; groupOrder = 30; order = 10; description = "Switches to power saver at the low battery threshold."; applyCommand = "dms ipc call settings set batteryAutoPowerSaver %%val%%";
        desktop.ojuny.dux.settings.batteryAutoPowerSaver = false;

        # @option widget = "switch"; label = "Lower display refresh rate on battery"; group = "Power profiles"; groupOrder = 30; order = 40; description = "Drops the display to its lowest refresh rate while on battery."; applyCommand = "dms ipc call settings set lowerDisplayRefreshRateOnBattery %%val%%";
        desktop.ojuny.dux.settings.lowerDisplayRefreshRateOnBattery = false;

        # @option widget = "dropdown"; label = "Profile on AC"; group = "Power profiles"; groupOrder = 30; order = 20; choices = [ "unchanged" "power-saver" "balanced" "performance" ]; applyCommand = "case %%val%% in unchanged) v='';; power-saver) v=0;; balanced) v=1;; performance) v=2;; esac; dms ipc call settings set acProfileName \"$v\"";
        ojuny.dux.acProfileName = "unchanged";

        # @option widget = "dropdown"; label = "Profile on battery"; group = "Power profiles"; groupOrder = 30; order = 30; choices = [ "unchanged" "power-saver" "balanced" "performance" ]; applyCommand = "case %%val%% in unchanged) v='';; power-saver) v=0;; balanced) v=1;; performance) v=2;; esac; dms ipc call settings set batteryProfileName \"$v\"";
        ojuny.dux.batteryProfileName = "unchanged";

        # Lid
        # @option widget = "dropdown"; label = "When the lid closes"; group = "Lid"; groupOrder = 32; order = 10; choices = [ "suspend" "ignore" "clamshell" ]; description = "Suspend always, never, or only when no external display is attached. Clamshell sets HandleLidSwitch and HandleLidSwitchExternalPower to suspend and HandleLidSwitchDocked to ignore, so logind keeps running when it reports a dock or an enabled external display. Logind counts an enabled HDMI, DP, DVI or VGA output as docked; a connected but disabled output does not count. With an external display, Mango switchbind sleeps the internal panel on lid close and wakes it on lid open. The script runs only while Mango is logged in, unplugging the external display after the lid is closed does not suspend, and a lid already closed when Mango starts does not trigger the panel script.";
        ojuny.power.lidPolicy = "suspend";

        # Stay awake
        # @option widget = "table-list"; label = "Programs that keep the system awake"; group = "Stay awake"; groupOrder = 34; order = 10; columns = [ "appId" "title" ]; columnTypes = [ "str" "str" ]; firstValueEditable = true; description = "App-ID and title regex patterns that keep the system awake while a matching window is focused. Use one column per row: appId matches the Mango class (app_id), title matches the window title. The DMS control-center Stay Awake tile owns the timers (15, 30, 60, 120, 240 and 480 minutes, or Until I turn it off); the controlCenterButton.showIdleInhibitorIcon bar icon shows the state, so no second bar widget exists. This page owns only this list and the two global switches below; disable is Off. An indefinite or unexpired timed inhibit survives a shell restart and a reboot because the generated session state is replaced only when its source changes; an expired timer is cleared on load. Mango rejects an invalid regex when it parses the generated config.";
        ojuny.power.idleInhibitPrograms = [ ];

        # @option widget = "switch"; label = "Idle inhibit for invisible clients"; group = "Stay awake"; groupOrder = 34; order = 20; applyCommand = "mmsg dispatch setoption,idle_inhibit_ignore_visible,$(case %%val%% in true) echo 1;; *) echo 0;; esac)";
        ojuny.mango.flag.idle_inhibit_ignore_visible = false;

        # @option widget = "switch"; label = "Idle inhibit while fullscreen"; group = "Stay awake"; groupOrder = 34; order = 30; applyCommand = "mmsg dispatch setoption,idle_inhibit_when_fullscreen,$(case %%val%% in true) echo 1;; *) echo 0;; esac)";
        ojuny.mango.flag.idle_inhibit_when_fullscreen = false;

        # Idle fade
        # @option widget = "switch"; label = "Fade to lock screen"; group = "Idle"; groupOrder = 35; order = 10; advanced = true; description = "Fade the screen out before locking; input during the fade cancels it."; applyCommand = "dms ipc call settings set fadeToLockEnabled %%val%%";
        desktop.ojuny.dux.settings.fadeToLockEnabled = true;

        # @option widget = "spin"; label = "Lock fade grace period"; group = "Idle"; groupOrder = 35; order = 20; advanced = true; min = 1; max = 30; unit = "s"; visibleWhen.path = "desktop.ojuny.dux.settings.fadeToLockEnabled"; visibleWhen.equals = true; description = "Seconds to wait before locking during the fade."; applyCommand = "dms ipc call settings set fadeToLockGracePeriod %%val%%";
        desktop.ojuny.dux.settings.fadeToLockGracePeriod = 5;

        # @option widget = "switch"; label = "Fade to display off"; group = "Idle"; groupOrder = 35; order = 30; advanced = true; description = "Fade the screen out before DPMS turns the display off."; applyCommand = "dms ipc call settings set fadeToDpmsEnabled %%val%%";
        desktop.ojuny.dux.settings.fadeToDpmsEnabled = true;

        # @option widget = "spin"; label = "Display fade grace period"; group = "Idle"; groupOrder = 35; order = 40; advanced = true; min = 1; max = 30; unit = "s"; visibleWhen.path = "desktop.ojuny.dux.settings.fadeToDpmsEnabled"; visibleWhen.equals = true; description = "Seconds to wait before display off during the fade."; applyCommand = "dms ipc call settings set fadeToDpmsGracePeriod %%val%%";
        desktop.ojuny.dux.settings.fadeToDpmsGracePeriod = 5;

        # @option widget = "dropdown"; label = "Automatically lock after (on AC)"; group = "Idle"; groupOrder = 40; order = 10; choices = [ "never" "15 seconds" "30 seconds" "1 minute" "2 minutes" "3 minutes" "5 minutes" "10 minutes" "15 minutes" "20 minutes" "30 minutes" "1 hour" "1.5 hours" "2 hours" "3 hours" ]; applyCommand = "case %%val%% in never) v=0;; \"15 seconds\") v=15;; \"30 seconds\") v=30;; \"1 minute\") v=60;; \"2 minutes\") v=120;; \"3 minutes\") v=180;; \"5 minutes\") v=300;; \"10 minutes\") v=600;; \"15 minutes\") v=900;; \"20 minutes\") v=1200;; \"30 minutes\") v=1800;; \"1 hour\") v=3600;; \"1.5 hours\") v=5400;; \"2 hours\") v=7200;; \"3 hours\") v=10800;; esac; dms ipc call settings set acLockTimeout $v";
        ojuny.dux.acLockTimeout = "never";

        # @option widget = "dropdown"; label = "Automatically lock after (on battery)"; group = "Idle"; groupOrder = 40; order = 20; choices = [ "never" "15 seconds" "30 seconds" "1 minute" "2 minutes" "3 minutes" "5 minutes" "10 minutes" "15 minutes" "20 minutes" "30 minutes" "1 hour" "1.5 hours" "2 hours" "3 hours" ]; applyCommand = "case %%val%% in never) v=0;; \"15 seconds\") v=15;; \"30 seconds\") v=30;; \"1 minute\") v=60;; \"2 minutes\") v=120;; \"3 minutes\") v=180;; \"5 minutes\") v=300;; \"10 minutes\") v=600;; \"15 minutes\") v=900;; \"20 minutes\") v=1200;; \"30 minutes\") v=1800;; \"1 hour\") v=3600;; \"1.5 hours\") v=5400;; \"2 hours\") v=7200;; \"3 hours\") v=10800;; esac; dms ipc call settings set batteryLockTimeout $v";
        ojuny.dux.batteryLockTimeout = "never";

        # @option widget = "dropdown"; label = "Turn off displays after (on AC)"; group = "Idle"; groupOrder = 40; order = 30; choices = [ "never" "15 seconds" "30 seconds" "1 minute" "2 minutes" "3 minutes" "5 minutes" "10 minutes" "15 minutes" "20 minutes" "30 minutes" "1 hour" "1.5 hours" "2 hours" "3 hours" ]; applyCommand = "case %%val%% in never) v=0;; \"15 seconds\") v=15;; \"30 seconds\") v=30;; \"1 minute\") v=60;; \"2 minutes\") v=120;; \"3 minutes\") v=180;; \"5 minutes\") v=300;; \"10 minutes\") v=600;; \"15 minutes\") v=900;; \"20 minutes\") v=1200;; \"30 minutes\") v=1800;; \"1 hour\") v=3600;; \"1.5 hours\") v=5400;; \"2 hours\") v=7200;; \"3 hours\") v=10800;; esac; dms ipc call settings set acMonitorTimeout $v";
        ojuny.dux.acMonitorTimeout = "never";

        # @option widget = "dropdown"; label = "Turn off displays after (on battery)"; group = "Idle"; groupOrder = 40; order = 40; choices = [ "never" "15 seconds" "30 seconds" "1 minute" "2 minutes" "3 minutes" "5 minutes" "10 minutes" "15 minutes" "20 minutes" "30 minutes" "1 hour" "1.5 hours" "2 hours" "3 hours" ]; applyCommand = "case %%val%% in never) v=0;; \"15 seconds\") v=15;; \"30 seconds\") v=30;; \"1 minute\") v=60;; \"2 minutes\") v=120;; \"3 minutes\") v=180;; \"5 minutes\") v=300;; \"10 minutes\") v=600;; \"15 minutes\") v=900;; \"20 minutes\") v=1200;; \"30 minutes\") v=1800;; \"1 hour\") v=3600;; \"1.5 hours\") v=5400;; \"2 hours\") v=7200;; \"3 hours\") v=10800;; esac; dms ipc call settings set batteryMonitorTimeout $v";
        ojuny.dux.batteryMonitorTimeout = "never";

        # @option widget = "dropdown"; label = "Turn off displays after lock (on AC)"; group = "Idle"; groupOrder = 40; order = 50; choices = [ "never" "15 seconds" "30 seconds" "1 minute" "2 minutes" "3 minutes" "5 minutes" "10 minutes" "15 minutes" "20 minutes" "30 minutes" "1 hour" "1.5 hours" "2 hours" "3 hours" ]; advanced = true; applyCommand = "case %%val%% in never) v=0;; \"15 seconds\") v=15;; \"30 seconds\") v=30;; \"1 minute\") v=60;; \"2 minutes\") v=120;; \"3 minutes\") v=180;; \"5 minutes\") v=300;; \"10 minutes\") v=600;; \"15 minutes\") v=900;; \"20 minutes\") v=1200;; \"30 minutes\") v=1800;; \"1 hour\") v=3600;; \"1.5 hours\") v=5400;; \"2 hours\") v=7200;; \"3 hours\") v=10800;; esac; dms ipc call settings set acPostLockMonitorTimeout $v";
        ojuny.dux.acPostLockMonitorTimeout = "never";

        # @option widget = "dropdown"; label = "Turn off displays after lock (on battery)"; group = "Idle"; groupOrder = 40; order = 60; choices = [ "never" "15 seconds" "30 seconds" "1 minute" "2 minutes" "3 minutes" "5 minutes" "10 minutes" "15 minutes" "20 minutes" "30 minutes" "1 hour" "1.5 hours" "2 hours" "3 hours" ]; advanced = true; applyCommand = "case %%val%% in never) v=0;; \"15 seconds\") v=15;; \"30 seconds\") v=30;; \"1 minute\") v=60;; \"2 minutes\") v=120;; \"3 minutes\") v=180;; \"5 minutes\") v=300;; \"10 minutes\") v=600;; \"15 minutes\") v=900;; \"20 minutes\") v=1200;; \"30 minutes\") v=1800;; \"1 hour\") v=3600;; \"1.5 hours\") v=5400;; \"2 hours\") v=7200;; \"3 hours\") v=10800;; esac; dms ipc call settings set batteryPostLockMonitorTimeout $v";
        ojuny.dux.batteryPostLockMonitorTimeout = "never";

        # @option widget = "dropdown"; label = "Suspend system after (on AC)"; group = "Idle"; groupOrder = 40; order = 70; choices = [ "never" "15 seconds" "30 seconds" "1 minute" "2 minutes" "3 minutes" "5 minutes" "10 minutes" "15 minutes" "20 minutes" "30 minutes" "1 hour" "1.5 hours" "2 hours" "3 hours" ]; applyCommand = "case %%val%% in never) v=0;; \"15 seconds\") v=15;; \"30 seconds\") v=30;; \"1 minute\") v=60;; \"2 minutes\") v=120;; \"3 minutes\") v=180;; \"5 minutes\") v=300;; \"10 minutes\") v=600;; \"15 minutes\") v=900;; \"20 minutes\") v=1200;; \"30 minutes\") v=1800;; \"1 hour\") v=3600;; \"1.5 hours\") v=5400;; \"2 hours\") v=7200;; \"3 hours\") v=10800;; esac; dms ipc call settings set acSuspendTimeout $v";
        ojuny.dux.acSuspendTimeout = "never";

        # @option widget = "dropdown"; label = "Suspend system after (on battery)"; group = "Idle"; groupOrder = 40; order = 80; choices = [ "never" "15 seconds" "30 seconds" "1 minute" "2 minutes" "3 minutes" "5 minutes" "10 minutes" "15 minutes" "20 minutes" "30 minutes" "1 hour" "1.5 hours" "2 hours" "3 hours" ]; applyCommand = "case %%val%% in never) v=0;; \"15 seconds\") v=15;; \"30 seconds\") v=30;; \"1 minute\") v=60;; \"2 minutes\") v=120;; \"3 minutes\") v=180;; \"5 minutes\") v=300;; \"10 minutes\") v=600;; \"15 minutes\") v=900;; \"20 minutes\") v=1200;; \"30 minutes\") v=1800;; \"1 hour\") v=3600;; \"1.5 hours\") v=5400;; \"2 hours\") v=7200;; \"3 hours\") v=10800;; esac; dms ipc call settings set batterySuspendTimeout $v";
        ojuny.dux.batterySuspendTimeout = "never";

        # @option widget = "dropdown"; label = "Suspend behavior (on AC)"; group = "Idle"; groupOrder = 40; order = 90; choices = [ "suspend" "hibernate" "suspend-then-hibernate" ]; advanced = true; applyCommand = "case %%val%% in suspend) v=0;; hibernate) v=1;; suspend-then-hibernate) v=2;; esac; dms ipc call settings set acSuspendBehavior $v";
        ojuny.dux.acSuspendBehavior = "suspend";

        # @option widget = "dropdown"; label = "Suspend behavior (on battery)"; group = "Idle"; groupOrder = 40; order = 100; choices = [ "suspend" "hibernate" "suspend-then-hibernate" ]; advanced = true; applyCommand = "case %%val%% in suspend) v=0;; hibernate) v=1;; suspend-then-hibernate) v=2;; esac; dms ipc call settings set batterySuspendBehavior $v";
        ojuny.dux.batterySuspendBehavior = "suspend";

        # Power menu
        # @option widget = "dropdown"; label = "Default selected action"; group = "Power menu"; groupOrder = 45; order = 10; choices = [ "reboot" "logout" "poweroff" "lock" "suspend" "restart" "hibernate" "softreboot" ]; description = "Action highlighted when the power menu opens."; applyCommand = "dms ipc call settings set powerMenuDefaultAction %%val%%";
        desktop.ojuny.dux.settings.powerMenuDefaultAction = "logout";

        # @option widget = "switch"; label = "Grid layout"; group = "Power menu"; groupOrder = 45; order = 20; description = "Lay the actions out in a grid instead of a list."; applyCommand = "dms ipc call settings set powerMenuGridLayout %%val%%";
        desktop.ojuny.dux.settings.powerMenuGridLayout = false;

        # @option widget = "switch"; label = "Confirm actions"; group = "Power menu"; groupOrder = 45; order = 30; description = "Require holding the power action before it runs."; applyCommand = "dms ipc call settings set powerActionConfirm %%val%%";
        desktop.ojuny.dux.settings.powerActionConfirm = true;

        # @option widget = "dropdown"; label = "Hold duration"; group = "Power menu"; groupOrder = 45; order = 40; choices = [ "0.25" "0.5" "0.75" "1" "2" "3" "5" "10" ]; visibleWhen.path = "desktop.ojuny.dux.settings.powerActionConfirm"; visibleWhen.equals = true; description = "Seconds the power action must be held."; applyCommand = "dms ipc call settings set powerActionHoldDuration %%val%%";
        desktop.ojuny.dux.settings.powerActionHoldDuration = 0.5;

        # @option widget = "switch"; label = "Firmware setup"; group = "Power menu"; groupOrder = 45; order = 50; advanced = true; description = "Add an action that reboots into the UEFI/BIOS settings screen."; applyCommand = "dms ipc call settings set powerMenuFirmwareSetup %%val%%";
        desktop.ojuny.dux.settings.powerMenuFirmwareSetup = false;

        # @option widget = "raw"; label = "Reboot targets"; group = "Advanced"; groupOrder = 45; order = 60; advanced = true; rows = 4; description = "EFI boot entries the power menu can reboot into once, as id and label objects.";
        desktop.ojuny.dux.settings.powerMenuBootEntries = [ ];

        # @option widget = "raw"; label = "Custom buttons"; group = "Advanced"; groupOrder = 45; order = 70; advanced = true; rows = 4; description = "Extra power menu buttons.";
        desktop.ojuny.dux.settings.customPowerButtons = [ ];

        # @option widget = "text"; label = "Lock"; group = "Advanced"; groupOrder = 50; order = 10; advanced = true; placeholder = "/usr/bin/myLock.sh"; description = "Runs instead of the built-in action; empty keeps the default."; applyCommand = "dms ipc call settings set customPowerActionLock %%val%%";
        desktop.ojuny.dux.settings.customPowerActionLock = "";

        # @option widget = "text"; label = "Log out"; group = "Advanced"; groupOrder = 50; order = 20; advanced = true; placeholder = "/usr/bin/myLogout.sh"; description = "Runs instead of the built-in action; empty keeps the default."; applyCommand = "dms ipc call settings set customPowerActionLogout %%val%%";
        desktop.ojuny.dux.settings.customPowerActionLogout = "";

        # @option widget = "text"; label = "Suspend"; group = "Advanced"; groupOrder = 50; order = 30; advanced = true; placeholder = "/usr/bin/mySuspend.sh"; description = "Runs instead of the built-in action; empty keeps the default."; applyCommand = "dms ipc call settings set customPowerActionSuspend %%val%%";
        desktop.ojuny.dux.settings.customPowerActionSuspend = "";

        # @option widget = "text"; label = "Hibernate"; group = "Advanced"; groupOrder = 50; order = 40; advanced = true; placeholder = "/usr/bin/myHibernate.sh"; description = "Runs instead of the built-in action; empty keeps the default."; applyCommand = "dms ipc call settings set customPowerActionHibernate %%val%%";
        desktop.ojuny.dux.settings.customPowerActionHibernate = "";

        # @option widget = "text"; label = "Reboot"; group = "Advanced"; groupOrder = 50; order = 50; advanced = true; placeholder = "/usr/bin/myReboot.sh"; description = "Runs instead of the built-in action; empty keeps the default."; applyCommand = "dms ipc call settings set customPowerActionReboot %%val%%";
        desktop.ojuny.dux.settings.customPowerActionReboot = "";

        # @option widget = "text"; label = "Power off"; group = "Advanced"; groupOrder = 50; order = 60; advanced = true; placeholder = "/usr/bin/myPowerOff.sh"; description = "Runs instead of the built-in action; empty keeps the default."; applyCommand = "dms ipc call settings set customPowerActionPowerOff %%val%%";
        desktop.ojuny.dux.settings.customPowerActionPowerOff = "";

      };
    };

}
