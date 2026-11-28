{
  description = "Ojuny template - a NixOS config edited through nix-settings-gui";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/release";

    lanzaboote = {
      url = "github:nix-community/lanzaboote/v1.2.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-parts.url = "github:hercules-ci/flake-parts";

    import-tree.url = "github:vic/import-tree";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ojuny-desktop = {
      url = "github:ojuny-project/ojuny-desktop";
      inputs.flake-parts.follows = "flake-parts";
      inputs.home-manager.follows = "home-manager";
      inputs.stylix.follows = "stylix";
    };

    ojuny-patches = {
      url = "github:ojuny-project/ojuny-patches";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    raven = {
      url = "github:ojuny-project/raven?ref=nix-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    dux-greeter = {
      url = "github:duxlabs-dev/dux-greeter";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix = {
      url = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware = {
      url = "github:NixOS/nixos-hardware";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-settings-gui = {
      url = "github:ojuny-project/nix-settings-gui";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    wvkbd = {
      url = "github:ojuny-project/wvkbd";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ojuny-welcome = {
      url = "github:ojuny-project/ojuny-welcome";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-regedit = {
      url = "github:ojuny-project/nix-regedit";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-shell-gui = {
      url = "github:ojuny-project/nix-shell-gui";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    simple-nix-update-gui = {
      url = "github:ojuny-project/simple-nix-update-gui";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    craftapps = {
      url = "github:olafkfreund/nix-craftapps";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    chromium-webapps = {
      url = "github:chobbledotcom/nix-chromium-webapps";
    };

    firefox-addons = {
      url = "git+https://gitlab.com/rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ojuny-cli = {
      url = "github:ojuny-project/ojuny-cli";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ojuny-manual = {
      url = "github:ojuny-project/ojuny-manual";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-cache-discovery = {
      url = "github:ojuny-project/nix-cache-discovery";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-builder-discovery = {
      url = "github:ojuny-project/nix-builder-discovery";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nom-cache-discovery = {
      url = "github:ojuny-project/nom-cache-discovery";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-cleaner = {
      url = "github:ojuny-project/nix-cleaner";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-connect = {
      url = "github:ojuny-project/nix-connect";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-anywhere = {
      url = "github:numtide/nixos-anywhere";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs =
    inputs@{ ... }:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        (inputs.import-tree ./modules)
        inputs.flake-parts.flakeModules.modules
        inputs.home-manager.flakeModules.home-manager
      ];

      systems = [ "x86_64-linux" ];
    };
}
