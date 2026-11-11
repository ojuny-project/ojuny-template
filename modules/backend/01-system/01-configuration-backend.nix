{ self, inputs, ... }: {

  flake.modules.nixos.system-configuration-backend =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      userHome = user: user.home or null;
      primaryUser =
        if config.users.users ? user && userHome config.users.users.user != null then
          config.users.users.user
        else
          lib.findFirst (entry: userHome entry != null) null (lib.attrValues config.users.users);
      primaryHome = if primaryUser != null then userHome primaryUser else "/home/user";
      repoPathAbsolute =
        if lib.hasPrefix "/" config.ojuny.repoPath then
          config.ojuny.repoPath
        else
          "${primaryHome}/${config.ojuny.repoPath}";
      system = pkgs.stdenv.hostPlatform.system;
      toolMode =
        name:
        if config.ojuny.binaries.${name} == "auto" then
          config.ojuny.binaries.mode
        else
          config.ojuny.binaries.${name};
      toolTag =
        name:
        if config.ojuny.binaries.${name + "Tag"} != "" then
          config.ojuny.binaries.${name + "Tag"}
        else if config.ojuny.binaries.tag != "" then
          config.ojuny.binaries.tag
        else
          throw "ojuny.binaries.${name}Tag must name a release recorded in binary-url.json when ${name} uses tag mode";
      binaryPackage =
        name: repo: package:
        if toolMode name == "tag" then
          inputs.${repo}.lib.mkBinary {
            inherit system package;
            tag = toolTag name;
          }
        else
          inputs.${repo}.lib.mkBinary { inherit system package; };
      pick =
        name: source: repo: package:
        if toolMode name == "source" then source else binaryPackage name repo package;
      manualPackage =
        if config.ojuny.manual.source == "source" then
          inputs.ojuny-manual.packages.${system}.default
        else if config.ojuny.manual.source == "tag" then
          inputs.ojuny-manual.lib.mkBinary {
            inherit system;
            tag =
              if config.ojuny.manual.tag != "" then
                config.ojuny.manual.tag
              else
                throw "ojuny.manual.tag must name a release recorded in binary-url.json when ojuny.manual.source is tag";
          }
        else
          inputs.ojuny-manual.lib.mkBinary { inherit system; };
    in
    {
      options.ojuny.patches = lib.mkEnableOption "automatic import of patch- modules placed in the repository";

      options.ojuny.time.auto = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Set the time zone automatically from location.";
      };

      options.ojuny.repoPath = lib.mkOption {
        type = lib.types.str;
        default = "repos/nix-flake";
        description = "Path to the installed system flake, relative to the primary user's home or absolute. This is the single source of truth for the flake location; runtime tools read the generated /etc/ojuny/flake-path projection.";
      };

      options.ojuny.i18n.extraLocaleSettings = lib.mkOption {
        type = lib.types.attrsOf (
          lib.types.submodule {
            options.locale = lib.mkOption {
              type = lib.types.str;
              default = "";
              description = "Locale value for this category.";
            };
          }
        );
        default = { };
        description = "Locale category overrides written to i18n.extraLocaleSettings.";
      };

      options.ojuny.binaries.mode = lib.mkOption {
        type = lib.types.enum [
          "source"
          "latest"
          "tag"
        ];
        default = "source";
        description = "Default package source for release tools. Source builds from the flake; latest downloads the newest bundle recorded in binary-url.json; tag downloads a named release from the same file.";
      };

      options.ojuny.binaries.tag = lib.mkOption {
        type = lib.types.str;
        default = "";
        description = "Fallback release tag for tag mode when a tool does not set its own.";
      };

      options.ojuny.binaries.cli = lib.mkOption {
        type = lib.types.enum [
          "auto"
          "source"
          "latest"
          "tag"
        ];
        default = "auto";
        description = "Package source for ojuny-cli and ojuny-patches-cli.";
      };

      options.ojuny.binaries.cliTag = lib.mkOption {
        type = lib.types.str;
        default = "";
        description = "Release tag for ojuny-cli and ojuny-patches-cli when its package source is tag.";
      };

      options.ojuny.binaries.cleaner = lib.mkOption {
        type = lib.types.enum [
          "auto"
          "source"
          "latest"
          "tag"
        ];
        default = "auto";
        description = "Package source for nix-cleaner.";
      };

      options.ojuny.binaries.cleanerTag = lib.mkOption {
        type = lib.types.str;
        default = "";
        description = "Release tag for nix-cleaner when its package source is tag.";
      };

      options.ojuny.binaries.cacheDiscovery = lib.mkOption {
        type = lib.types.enum [
          "auto"
          "source"
          "latest"
          "tag"
        ];
        default = "auto";
        description = "Package source for nix-cache-discovery.";
      };

      options.ojuny.binaries.cacheDiscoveryTag = lib.mkOption {
        type = lib.types.str;
        default = "";
        description = "Release tag for nix-cache-discovery when its package source is tag.";
      };

      options.ojuny.binaries.regedit = lib.mkOption {
        type = lib.types.enum [
          "auto"
          "source"
          "latest"
          "tag"
        ];
        default = "auto";
        description = "Package source for nix-regedit.";
      };

      options.ojuny.binaries.regeditTag = lib.mkOption {
        type = lib.types.str;
        default = "";
        description = "Release tag for nix-regedit when its package source is tag.";
      };

      options.ojuny.binaries.settingsGui = lib.mkOption {
        type = lib.types.enum [
          "auto"
          "source"
          "latest"
          "tag"
        ];
        default = "auto";
        description = "Package source for nix-settings-gui.";
      };

      options.ojuny.binaries.settingsGuiTag = lib.mkOption {
        type = lib.types.str;
        default = "";
        description = "Release tag for nix-settings-gui when its package source is tag.";
      };

      options.ojuny.binaries.welcome = lib.mkOption {
        type = lib.types.enum [
          "auto"
          "source"
          "latest"
          "tag"
        ];
        default = "auto";
        description = "Package source for ojuny-welcome.";
      };

      options.ojuny.binaries.welcomeTag = lib.mkOption {
        type = lib.types.str;
        default = "";
        description = "Release tag for ojuny-welcome when its package source is tag.";
      };

      options.ojuny.binaries.shellGui = lib.mkOption {
        type = lib.types.enum [
          "auto"
          "source"
          "latest"
          "tag"
        ];
        default = "auto";
        description = "Package source for nix-shell-gui.";
      };

      options.ojuny.binaries.shellGuiTag = lib.mkOption {
        type = lib.types.str;
        default = "";
        description = "Release tag for nix-shell-gui when its package source is tag.";
      };

      options.ojuny.binaries.simpleUpdateGui = lib.mkOption {
        type = lib.types.enum [
          "auto"
          "source"
          "latest"
          "tag"
        ];
        default = "auto";
        description = "Package source for simple-nix-update-gui and its daemon.";
      };

      options.ojuny.binaries.simpleUpdateGuiTag = lib.mkOption {
        type = lib.types.str;
        default = "";
        description = "Release tag for simple-nix-update-gui and its daemon when its package source is tag.";
      };

      options.ojuny.manual.source = lib.mkOption {
        type = lib.types.enum [
          "source"
          "latest"
          "tag"
        ];
        default = "source";
        description = "Package source for the offline manual. Defaults to source because the manual tracks the rolling repository.";
      };

      options.ojuny.manual.tag = lib.mkOption {
        type = lib.types.str;
        default = "";
        description = "Release tag for the offline manual when its package source is tag.";
      };

      options.ojuny.kernel = lib.mkOption {
        type = lib.types.enum [
          "lts"
          "latest"
          "zen"
          "cachyos-latest"
          "cachyos-lts"
        ];
        default = "lts";
        description = "Linux kernel package set. LTS uses the nixpkgs default LTS kernel, latest follows nixpkgs unstable, Zen is the nixpkgs Zen kernel, and the CachyOS choices come from the nix-cachyos-kernel input.";
      };

      config = {
        nixpkgs.overlays = lib.mkIf (lib.hasPrefix "cachyos" config.ojuny.kernel) [
          inputs.nix-cachyos-kernel.overlays.pinned
        ];

        nix.settings = lib.mkIf (lib.hasPrefix "cachyos" config.ojuny.kernel) {
          substituters = [ "https://cache.lantian.pub/lantian" ];
          trusted-public-keys = [
            "lantian:WVGO7vsRMSEN+h7Lp7kv6SAmrkEXgUGbbXm7jMDjBuQ="
          ];
        };

        boot.kernelPackages = lib.mkDefault (
          if config.ojuny.kernel == "latest" then
            pkgs.linuxPackages_latest
          else if config.ojuny.kernel == "zen" then
            pkgs.linuxPackages_zen
          else if config.ojuny.kernel == "cachyos-latest" then
            pkgs.cachyosKernels.linuxPackages-cachyos-latest
          else if config.ojuny.kernel == "cachyos-lts" then
            pkgs.cachyosKernels.linuxPackages-cachyos-lts-lto
          else
            pkgs.linuxPackages
        );

        programs.nix-cleaner.package =
          pick "cleaner" inputs.nix-cleaner.packages.${system}.default "nix-cleaner"
            "nix-cleaner";

        services.nix-cache-discovery.package =
          pick "cacheDiscovery" inputs.nix-cache-discovery.packages.${system}.default "nix-cache-discovery"
            "nix-cache-discovery";

        services.nix-regedit.package =
          pick "regedit" inputs.nix-regedit.packages.${system}.default "nix-regedit"
            "nix-regedit";

        services.nix-settings-gui.package =
          pick "settingsGui" inputs.nix-settings-gui.packages.${system}.default "nix-settings-gui"
            "nix-settings-gui";

        services.ojuny-welcome.package =
          pick "welcome" inputs.ojuny-welcome.packages.${system}.default "ojuny-welcome"
            "ojuny-welcome";

        services.nix-shell-gui.package =
          pick "shellGui" inputs.nix-shell-gui.packages.${system}.default "nix-shell-gui"
            "nix-shell-gui";

        services.simple-nix-update-gui.package =
          pick "simpleUpdateGui" inputs.simple-nix-update-gui.packages.${system}.default
            "simple-nix-update-gui"
            "simple-nix-update-gui";

        services.simple-nix-update-gui.daemonPackage =
          pick "simpleUpdateGui" inputs.simple-nix-update-gui.packages.${system}.daemon
            "simple-nix-update-gui"
            "simple-nix-update-gui-daemon";

        environment.systemPackages = [
          (pick "cli" inputs.ojuny-cli.packages.${system}.ojuny-cli "ojuny-cli" "ojuny-cli")
          (pick "cli" inputs.ojuny-cli.packages.${system}.ojuny-patches-cli "ojuny-cli" "ojuny-patches")
          manualPackage
        ];

        environment.variables = {
          OJUNY_REPO_PATH = repoPathAbsolute;
          OJUNY_FLAKE = repoPathAbsolute;
        };

        environment.etc."ojuny/flake-path" = {
          text = repoPathAbsolute + "\n";
          mode = "0644";
        };

        services.automatic-timezoned.enable = config.ojuny.time.auto;
        services.geoclue2.enable = config.ojuny.time.auto;

        i18n.extraLocaleSettings = lib.mapAttrs (
          _: entry: entry.locale
        ) config.ojuny.i18n.extraLocaleSettings;

        system.nixos.distroName = "Ojuny";
        system.nixos.distroId = "ojuny";

        # Point at the source that built this system. The marker does not store
        # the state versions; setup evaluates the source to read them.
        environment.etc."ojuny/flake-source".source = self.outPath;

      };

    };

}
