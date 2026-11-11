/*
  @menu
  displayname = "Screensaver";
  icon = "preferences-desktop-screensaver-symbolic";
  order = 65;
  description = "ASCII screensaver before the lock screen";
  category = "03-Desktop";
*/

{ self, inputs, ... }: {

  flake.modules.nixos.desktop-screensaver =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      imports = [ self.modules.nixos.desktop-screensaver-backend ];

      config = {
        # @option widget = "switch"; label = "Screensaver"; group = "Screensaver"; description = "Show a terminal screensaver before the DMS lock.";
        ojuny.screensaver.enable = false;

        # @option widget = "spin"; label = "Idle seconds"; group = "Screensaver"; min = 10; description = "Must be lower than the DMS lock timeout.";
        ojuny.screensaver.idleSeconds = 120;

        # @option widget = "text"; label = "Terminal command prefix"; group = "Screensaver"; advanced = true; description = "Flags placed before the command, e.g. foot --app-id=org.ojuny.screensaver.";
        ojuny.screensaver.terminal = "foot --app-id=org.ojuny.screensaver";

        # @option widget = "text"; label = "Screensaver command"; group = "Screensaver"; description = "Command run inside the terminal, e.g. cmatrix -b or pipes.sh.";
        ojuny.screensaver.command = "${pkgs.cmatrix}/bin/cmatrix -b";
      };
    };
}
