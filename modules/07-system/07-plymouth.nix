/*
  @menu
  displayname = "Plymouth";
  icon = "preferences-desktop-theme-symbolic";
  order = 70;
  description = "Boot splash and branding";
  category = "07-System";
  hidden = true;
*/

{ self, inputs, ... }: {

  flake.modules.nixos.system-plymouth =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      mkRecoloredImage = import "${inputs.ojuny-desktop.outPath}/lib/mk-recolored-image.nix" {
        inherit lib pkgs;
      };

      recoloredLogo = mkRecoloredImage {
        name = "ojuny-plymouth-logo.png";
        base = ./plymouth/ojuny-logo.png;
        fills = [
          {
            color = "4F5B58";
            slot = "base03";
          }
          {
            color = "E67E80";
            slot = "base08";
          }
          {
            color = "7FBBB3";
            slot = "base0D";
          }
          {
            color = "DBBC7F";
            slot = "base0A";
          }
        ];
        colors = config.lib.stylix.colors;
      };

      logo =
        pkgs.runCommand "ojuny-plymouth-logo-bordered.png"
          {
            nativeBuildInputs = [ pkgs.imagemagick ];
          }
          ''
            magick ${recoloredLogo} \
              -background transparent \
              -bordercolor transparent \
              -border 22% \
              "$out"
          '';

      theme = pkgs.callPackage ./plymouth/_theme.nix {
        background = config.lib.stylix.colors.base00;
        foreground = config.lib.stylix.colors.base05;
        inherit logo;
        logoSize = 512;
      };
    in
    {
      options.ojuny.plymouth.enable = lib.mkEnableOption "the Ojuny Plymouth theme";

      config = {
        # @option widget = "switch"; label = "Plymouth"; group = "Plymouth"; description = "Use the Ojuny boot splash generated from Stylix colors.";
        ojuny.plymouth.enable = true;

        boot.plymouth = lib.mkIf config.ojuny.plymouth.enable {
          enable = true;
          theme = lib.mkForce "ojuny";
          themePackages = [ theme ];
        };

        services.greetd.greeterManagesPlymouth = lib.mkIf config.ojuny.plymouth.enable true;

        # The greeter's compositor cannot acquire the DRM device while
        # plymouthd holds it. Quit Plymouth with the last frame retained before
        # greetd starts sway; the retained splash stays visible until sway draws.
        systemd.services.greetd.preStart = lib.mkIf config.ojuny.plymouth.enable ''
          ${lib.getExe' config.boot.plymouth.package "plymouth"} quit --retain-splash || true
        '';

        systemd.services.plymouth-quit.enable = lib.mkIf config.ojuny.plymouth.enable false;
        systemd.services.plymouth-quit-wait.enable = lib.mkIf config.ojuny.plymouth.enable false;

        systemd.services.ojuny-plymouth-quit = lib.mkIf config.ojuny.plymouth.enable {
          description = "Quit Plymouth if the greeter did not";
          unitConfig.ConditionPathExists = "/run/plymouth/pid";
          serviceConfig = {
            Type = "oneshot";
            ExecStart = "-${lib.getExe' config.boot.plymouth.package "plymouth"} quit --retain-splash";
          };
        };

        systemd.timers.ojuny-plymouth-quit = lib.mkIf config.ojuny.plymouth.enable {
          wantedBy = [ "multi-user.target" ];
          timerConfig = {
            OnActiveSec = "30s";
            Unit = "ojuny-plymouth-quit.service";
          };
        };
      };
    };
}
