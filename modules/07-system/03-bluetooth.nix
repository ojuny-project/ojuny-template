/*
  @menu
  displayname = "Bluetooth";
  icon = "bluetooth-active-symbolic";
  order = 30;
  description = "Bluetooth pairing and services";
  category = "07-System";
*/

{ self, inputs, ... }: {

  flake.modules.nixos.system-bluetooth = { config, pkgs, ... }: {

    # @option widget = "switch"; label = "Bluetooth"; group = "Bluetooth"; description = "Unblocks rfkill before powering on. Off at boot by default."; applyCommand = "if test %%val%% = true; then /run/current-system/sw/bin/rfkill unblock bluetooth; state=$(/run/current-system/sw/bin/rfkill list bluetooth); case $state in *'blocked: yes'*) echo 'Bluetooth is rfkill-blocked; unblock it with rfkill or the hardware switch' >&2; exit 1;; esac; /run/current-system/sw/bin/bluetoothctl power on || { echo 'Bluetooth failed to power on' >&2; /run/current-system/sw/bin/rfkill list bluetooth >&2; exit 1; }; else /run/current-system/sw/bin/bluetoothctl power off; fi";
    hardware.bluetooth.enable = true;

    # @option widget = "switch"; label = "Power on at boot"; group = "Bluetooth"; visibleWhen.path = "hardware.bluetooth.enable"; visibleWhen.equals = true; description = "Off by default. When enabled, BlueZ powers the adapter on at boot if rfkill allows it.";
    hardware.bluetooth.powerOnBoot = false;

    # @option widget = "switch"; label = "Experimental features"; group = "Advanced"; visibleWhen.path = "hardware.bluetooth.enable"; visibleWhen.equals = true; hidden = true; description = "Enable experimental BlueZ features.";
    hardware.bluetooth.settings.General.Experimental = true;

    # @option widget = "switch"; label = "Blueman applet"; group = "Bluetooth"; visibleWhen.path = "hardware.bluetooth.enable"; visibleWhen.equals = true;
    services.blueman.enable = true;

    # @option widget = "switch"; label = "Bluetooth media controls"; group = "Bluetooth"; visibleWhen.path = "hardware.bluetooth.enable"; visibleWhen.equals = true; description = "Route Bluetooth headset buttons to the active DMS media player instead of mpris-proxy."; applyCommand = "dms ipc call settings set bluetoothMprisEnabled %%val%%";
    desktop.ojuny.dux.settings.bluetoothMprisEnabled = false;

  };

}
