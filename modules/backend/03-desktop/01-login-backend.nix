{ self, inputs, ... }: {

  flake.modules.nixos.desktop-login-backend =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      rendered = (import "${inputs.ojuny-desktop}/lib/mk-config.nix" { inherit lib; })
        .mkConfig { dux = config.desktop.ojuny.dux; };

      greeterConfig = pkgs.runCommand "ojuny-dux-greeter-config" { } ''
        mkdir -p "$out"
        cp ${pkgs.writeText "settings.json" rendered.duxJson} "$out/settings.json"
        cp ${pkgs.writeText "session.json" rendered.duxSessionJson} "$out/session.json"
      '';
    in
    {
      imports = [ inputs.dux-greeter.nixosModules.default ];

      programs.dms-greeter = {
        configFiles = [
          "${greeterConfig}/settings.json"
          "${greeterConfig}/session.json"
        ];
      };

      services.displayManager.defaultSession = "ojuny";
    };
}
