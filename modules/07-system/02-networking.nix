/*
  @menu
  displayname = "Networking";
  icon = "network-wireless-symbolic";
  order = 20;
  description = "NetworkManager and firewall";
  category = "07-System";
*/

{ self, inputs, ... }: {

  flake.modules.nixos.system-networking =
    { ... }:
    {
      imports = [ self.modules.nixos.system-deploy-rs self.modules.nixos.system-networking-backend ];

      config = {

        # @option widget = "switch"; label = "NetworkManager"; group = "Network";
        networking.networkmanager.enable = true;

        # @option widget = "switch"; label = "WireGuard profile folder"; group = "VPN"; groupOrder = 5; order = 10; description = "Watch a folder for WireGuard .conf files and import them into NetworkManager. Imported profiles appear in the DMS VPN panel.";
        ojuny.vpn.wireguard.enable = true;

        # @option widget = "text"; label = "Profile directory"; group = "VPN"; groupOrder = 5; order = 20; visibleWhen.path = "ojuny.vpn.wireguard.enable"; visibleWhen.equals = true; description = "Absolute path. Empty uses ~/.config/ojuny/wireguard for the primary user.";
        ojuny.vpn.wireguard.directory = "";

        # @option widget = "switch"; label = "Connect VPN at boot"; group = "VPN"; groupOrder = 5; order = 30; visibleWhen.path = "ojuny.vpn.wireguard.enable"; visibleWhen.equals = true; description = "Enable autoconnect for one managed WireGuard profile and disable it for the others.";
        ojuny.vpn.wireguard.autoconnect = false;

        # @option widget = "text"; label = "Profile at boot"; group = "VPN"; groupOrder = 5; order = 40; visibleWhen.path = "ojuny.vpn.wireguard.autoconnect"; visibleWhen.equals = true; description = "File basename of the profile to connect at boot. Empty uses the first profile in the folder.";
        ojuny.vpn.wireguard.autoconnectProfile = "";

        # @option widget = "switch"; label = "Wi-Fi power saving"; group = "Wi-Fi"; visibleWhen.path = "networking.networkmanager.enable"; visibleWhen.equals = true; description = "Disable to fix stuttering on some Wi-Fi cards.";
        networking.networkmanager.wifi.powersave = true;

        # @option widget = "list"; label = "DNS servers"; group = "DNS"; description = "Static resolvers; leave empty to use DHCP.";
        networking.nameservers = [ ];

        # @option widget = "text"; label = "Domain"; group = "DNS"; description = "Local DNS search domain.";
        networking.domain = "";

        # @option widget = "text"; label = "Ethernet MAC address"; group = "Ethernet"; hidden = true; description = "Spoof the MAC of wired devices, e.g. 02:00:00:00:00:01.";
        networking.networkmanager.ethernet.macAddress = "stable";

        # @option widget = "switch"; label = "Predictable interface names"; group = "Ethernet"; hidden = true; description = "Use names like enp1s0 instead of eth0.";
        networking.usePredictableInterfaceNames = true;

        # @option widget = "switch"; label = "Firewall"; group = "Firewall";
        networking.firewall.enable = true;

        # @option widget = "switch"; label = "Log refused connections"; group = "Firewall"; visibleWhen.path = "networking.firewall.enable"; visibleWhen.equals = true; hidden = true;
        networking.firewall.logRefusedConnections = true;

        # @option widget = "list"; label = "Open TCP ports"; group = "Firewall"; visibleWhen.path = "networking.firewall.enable"; visibleWhen.equals = true;
        networking.firewall.allowedTCPPorts = [ ];

        # @option widget = "list"; label = "Open UDP ports"; group = "Firewall"; visibleWhen.path = "networking.firewall.enable"; visibleWhen.equals = true;
        networking.firewall.allowedUDPPorts = [ ];

        # @option widget = "list"; label = "Trusted interfaces"; group = "Firewall"; visibleWhen.path = "networking.firewall.enable"; visibleWhen.equals = true;
        networking.firewall.trustedInterfaces = [ "virbr0" ];

        # @option widget = "table-list"; label = "Static hosts"; group = "Hosts"; advanced = true; columns = [ "address" "hostNames" ]; columnTypes = [ "str" "str" ]; firstValueEditable = true; description = "Extra /etc/hosts entries. Host names are separated by spaces.";
        ojuny.networking.hosts = [ ];

      };

    };

}
