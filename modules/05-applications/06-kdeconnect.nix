/*
  @menu
  displayname = "KDE Connect";
  icon = "phone-symbolic";
  order = 60;
  description = "KDE Connect integration";
  category = "05-Applications";
  hidden = true;
*/

{ self, inputs, ... }: {

  flake.modules.nixos.applications-kdeconnect =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    let
      enabled = config.desktop.ojuny.dux.plugins.dankKDEConnect.enable;
    in
    {
      # The switch lives on the DMS plugins page. Valent and the DMS KDE
      # Connect plugin share one state.
      programs.kdeconnect.enable = enabled;

      # themed fork of KDE Connect used by stylix; parity with dendrite desktop-svc.nix.
      programs.kdeconnect.package = lib.mkDefault pkgs.valent;

      # valent's sftp plugin mounts the device under /run/user/<uid>/gvfs and runs
      # `ssh-add` to register the device key, so gvfs and a reachable agent are required.
      services.gvfs.enable = true;
      programs.ssh.startAgent = true;
      environment.etc."environment.d/50-ssh-agent.conf".text = ''
        SSH_AUTH_SOCK=$XDG_RUNTIME_DIR/ssh-agent
      '';

      # KDE Connect is the one default open port. nixpkgs opens TCP/UDP
      # 1714-1764 on every interface, so replace that with source-scoped rules.
      networking.firewall.allowedTCPPortRanges = lib.mkIf enabled (lib.mkForce [ ]);
      networking.firewall.allowedUDPPortRanges = lib.mkIf enabled (lib.mkForce [ ]);

      networking.firewall.extraCommands = lib.mkIf (enabled && config.networking.firewall.enable) ''
        for source in 10.0.0.0/8 172.16.0.0/12 192.168.0.0/16 169.254.0.0/16; do
          iptables -w -A nixos-fw -s "$source" -p tcp --dport 1714:1764 -j nixos-fw-accept
          iptables -w -A nixos-fw -s "$source" -p udp --dport 1714:1764 -j nixos-fw-accept
        done
        for source in fc00::/7 fe80::/10; do
          ip6tables -w -A nixos-fw -s "$source" -p tcp --dport 1714:1764 -j nixos-fw-accept
          ip6tables -w -A nixos-fw -s "$source" -p udp --dport 1714:1764 -j nixos-fw-accept
        done
      '';

    };

}
