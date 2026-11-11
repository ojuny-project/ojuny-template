/*
  @menu
  displayname = "Gaming";
  icon = "applications-games-symbolic";
  order = 50;
  description = "Steam and gaming";
  category = "05-Applications";
*/

{ self, inputs, ... }: {

  flake.modules.nixos.applications-steam =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {

      imports = [ self.modules.nixos.applications-steam-backend ];

      config = {
        # @option widget = "switch"; label = "Steam"; group = "Steam"; groupOrder = 10; order = 1;
        programs.steam.enable = false;

        # @option widget = "switch"; label = "Windows compatibility tools"; group = "Steam"; description = "Install Wine, winetricks, protontricks and gamescope so non-Steam Windows games and launchers can run."; visibleWhen.path = "programs.steam.enable"; visibleWhen.equals = true;
        ojuny.steam.compat = true;

        # @option widget = "switch"; label = "Proton GE"; group = "Steam"; description = "Community Proton build with extra codec and performance patches, offered alongside the official Proton versions in Steam Play."; visibleWhen.path = "programs.steam.enable"; visibleWhen.equals = true;
        ojuny.steam.protonGE = true;

        # @option widget = "switch"; label = "Legacy GPU Proton (DXVK-Sarek)"; group = "Steam"; description = "Add DW-Proton, which bundles DXVK-Sarek for Vulkan 1.1 and 1.2 GPUs such as the GTX 750 Ti. Select it per game under Properties > Compatibility."; visibleWhen.path = "programs.steam.enable"; visibleWhen.equals = true;
        ojuny.steam.dxvkSarek = false;

        # @option widget = "switch"; label = "Steam Input on Wayland"; group = "Steam"; description = "Load the extest library into Steam so Steam Input works on Wayland by translating X11 input events to uinput events. Leave off unless Steam Input misbehaves on Wayland; it is unnecessary on X11."; visibleWhen.path = "programs.steam.enable"; visibleWhen.equals = true;
        ojuny.steam.extest = false;

        # @option widget = "switch"; label = "Gamescope session"; group = "Steam"; description = "Add a sessions entry that boots straight into Steam Big Picture through gamescope."; visibleWhen.path = "programs.steam.enable"; visibleWhen.equals = true;
        ojuny.steam.gamescopeSession = false;

        # @option widget = "switch"; label = "Xbox wireless controller driver"; group = "Controllers"; groupOrder = 20; order = 10; description = "Install the xpadneo kernel driver for Xbox One and Xbox Series controllers over Bluetooth. It only adds quirks for those controllers; wired USB and most other Bluetooth controllers work without it.";
        ojuny.hardware.xpadneo = false;

        # @option widget = "slider"; label = "Rumble attenuation"; group = "Controllers"; groupOrder = 20; order = 20; min = 0; max = 100; step = 1; unit = "%"; visibleWhen.path = "ojuny.hardware.xpadneo"; visibleWhen.equals = true; description = "Reduce main and trigger rumble together. 0 keeps full rumble and 100 disables it.";
        hardware.xpadneo.rumbleAttenuation.overall = 0;

        # @option widget = "table-attrset"; label = "Controller quirks"; group = "Controllers"; groupOrder = 20; order = 30; columns = [ "flags" ]; columnTypes = [ "int" ]; keyEditable = true; visibleWhen.path = "ojuny.hardware.xpadneo"; visibleWhen.equals = true; description = "Per-controller quirk flags keyed by Bluetooth MAC address. The value is the sum of the flags from the xpadneo configuration guide.";
        hardware.xpadneo.quirks = { };

        # @option widget = "table-attrset"; label = "Module settings"; group = "Controllers"; groupOrder = 20; order = 40; columns = [ "value" ]; columnTypes = [ "str" ]; keyEditable = true; visibleWhen.path = "ojuny.hardware.xpadneo"; visibleWhen.equals = true; description = "Raw xpadneo module parameters such as disable_deadzones or trigger_rumble_mode. Values are written as kernel module options.";
        hardware.xpadneo.settings = { };

        # @option widget = "switch"; label = "GameMode"; group = "Steam"; description = "Lets games request a temporary performance profile (governor, niceness, IO priority). Works independently of Steam and other launchers.";
        programs.gamemode.enable = true;

        # @option widget = "switch"; label = "Remote Play firewall"; group = "Steam"; description = "Open the ports Steam Remote Play uses on the local network."; visibleWhen.path = "programs.steam.enable"; visibleWhen.equals = true;
        programs.steam.remotePlay.openFirewall = true;

        # @option widget = "switch"; label = "LAN game transfers"; group = "Steam"; description = "Allow Steam to copy game downloads between PCs on the local network."; visibleWhen.path = "programs.steam.enable"; visibleWhen.equals = true;
        programs.steam.localNetworkGameTransfers.openFirewall = true;

        # @option widget = "switch"; label = "Dedicated server firewall"; group = "Steam"; advanced = true; description = "Open ports for hosted game servers."; visibleWhen.path = "programs.steam.enable"; visibleWhen.equals = true;
        programs.steam.dedicatedServer.openFirewall = false;
      };

    };

}
