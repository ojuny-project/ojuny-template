/*
  @menu
  displayname = "System";
  icon = "computer-symbolic";
  order = 10;
  description = "Hostname, locale, time, keyboard and package sources";
  category = "07-System";
*/

{ self, inputs, ... }: {

  flake.modules.nixos.system-configuration =
    { ... }:
    {
      imports = [ self.modules.nixos.patches self.modules.nixos.system-configuration-backend ];

      config = {
        # @option widget = "dropdown"; label = "Kernel"; group = "Kernel"; groupOrder = 5; order = 10; choices = [ "lts" "latest" "zen" "cachyos-latest" "cachyos-lts" ]; description = "LTS is the nixpkgs default LTS kernel. Latest follows nixpkgs unstable. Zen is the nixpkgs Zen kernel. CachyOS latest and LTS use the nix-cachyos-kernel input. A patch or host can override this with a normal boot.kernelPackages assignment.";
        ojuny.kernel = "lts";

        # @option widget = "switch"; label = "Enable patches"; group = "Patches"; description = "Automatically import patch- modules placed in the repository.";
        ojuny.patches = false;

        # @option widget = "text"; label = "Repository path"; group = "Paths"; groupOrder = 50; order = 10; description = "Absolute path, or a path relative to the primary user's home.";
        ojuny.repoPath = "repos/nix-flake";

        # @option widget = "dropdown"; label = "Package source"; group = "Binaries"; groupOrder = 60; order = 10; choices = [ "source" "latest" "tag" ]; description = "Build release tools from the flake, install the newest release recorded in binary-url.json, or install a named release from that file.";
        ojuny.binaries.mode = "source";

        # @option widget = "text"; label = "Fallback release tag"; group = "Binaries"; groupOrder = 60; order = 15; advanced = true; description = "Release tag used in tag mode when a tool does not set its own.";
        ojuny.binaries.tag = "";

        # @option widget = "dropdown"; label = "Command line"; group = "Binaries"; groupOrder = 60; order = 20; advanced = true; choices = [ "auto" "source" "latest" "tag" ]; description = "Override the package source for ojuny-cli and ojuny-patches-cli.";
        ojuny.binaries.cli = "auto";

        # @option widget = "text"; label = "Command line release tag"; group = "Binaries"; groupOrder = 60; order = 21; advanced = true; description = "Release tag for ojuny-cli and ojuny-patches-cli when their package source is tag.";
        ojuny.binaries.cliTag = "";

        # @option widget = "dropdown"; label = "Nix cleaner"; group = "Binaries"; groupOrder = 60; order = 30; advanced = true; choices = [ "auto" "source" "latest" "tag" ]; description = "Override the package source for nix-cleaner.";
        ojuny.binaries.cleaner = "auto";

        # @option widget = "text"; label = "Nix cleaner release tag"; group = "Binaries"; groupOrder = 60; order = 31; advanced = true; description = "Release tag for nix-cleaner when its package source is tag.";
        ojuny.binaries.cleanerTag = "";

        # @option widget = "dropdown"; label = "Cache discovery"; group = "Binaries"; groupOrder = 60; order = 40; advanced = true; choices = [ "auto" "source" "latest" "tag" ]; description = "Override the package source for nix-cache-discovery.";
        ojuny.binaries.cacheDiscovery = "auto";

        # @option widget = "text"; label = "Cache discovery release tag"; group = "Binaries"; groupOrder = 60; order = 41; advanced = true; description = "Release tag for nix-cache-discovery when its package source is tag.";
        ojuny.binaries.cacheDiscoveryTag = "";

        # @option widget = "dropdown"; label = "Registry editor"; group = "Binaries"; groupOrder = 60; order = 50; advanced = true; choices = [ "auto" "source" "latest" "tag" ]; description = "Override the package source for nix-regedit.";
        ojuny.binaries.regedit = "auto";

        # @option widget = "text"; label = "Registry editor release tag"; group = "Binaries"; groupOrder = 60; order = 51; advanced = true; description = "Release tag for nix-regedit when its package source is tag.";
        ojuny.binaries.regeditTag = "";

        # @option widget = "dropdown"; label = "Settings GUI"; group = "Binaries"; groupOrder = 60; order = 60; advanced = true; choices = [ "auto" "source" "latest" "tag" ]; description = "Override the package source for nix-settings-gui.";
        ojuny.binaries.settingsGui = "auto";

        # @option widget = "text"; label = "Settings GUI release tag"; group = "Binaries"; groupOrder = 60; order = 61; advanced = true; description = "Release tag for nix-settings-gui when its package source is tag.";
        ojuny.binaries.settingsGuiTag = "";

        # @option widget = "dropdown"; label = "Welcome"; group = "Binaries"; groupOrder = 60; order = 62; advanced = true; choices = [ "auto" "source" "latest" "tag" ]; description = "Override the package source for ojuny-welcome.";
        ojuny.binaries.welcome = "auto";

        # @option widget = "text"; label = "Welcome release tag"; group = "Binaries"; groupOrder = 60; order = 63; advanced = true; description = "Release tag for ojuny-welcome when its package source is tag.";
        ojuny.binaries.welcomeTag = "";

        # @option widget = "dropdown"; label = "Shell GUI"; group = "Binaries"; groupOrder = 60; order = 70; advanced = true; choices = [ "auto" "source" "latest" "tag" ]; description = "Override the package source for nix-shell-gui.";
        ojuny.binaries.shellGui = "auto";

        # @option widget = "text"; label = "Shell GUI release tag"; group = "Binaries"; groupOrder = 60; order = 71; advanced = true; description = "Release tag for nix-shell-gui when its package source is tag.";
        ojuny.binaries.shellGuiTag = "";

        # @option widget = "dropdown"; label = "Update GUI"; group = "Binaries"; groupOrder = 60; order = 80; advanced = true; choices = [ "auto" "source" "latest" "tag" ]; description = "Override the package source for simple-nix-update-gui and its daemon.";
        ojuny.binaries.simpleUpdateGui = "auto";

        # @option widget = "text"; label = "Update GUI release tag"; group = "Binaries"; groupOrder = 60; order = 81; advanced = true; description = "Release tag for simple-nix-update-gui and its daemon when their package source is tag.";
        ojuny.binaries.simpleUpdateGuiTag = "";

        # @option widget = "dropdown"; label = "Manual"; group = "Binaries"; groupOrder = 60; order = 90; choices = [ "source" "latest" "tag" ]; description = "Source builds the manual from the current repository. Latest installs the newest release recorded in binary-url.json. Tag installs a named release from that file. Defaults to source.";
        ojuny.manual.source = "source";

        # @option widget = "text"; label = "Manual release tag"; group = "Binaries"; groupOrder = 60; order = 91; advanced = true; description = "Release tag for the offline manual when its package source is tag.";
        ojuny.manual.tag = "";

        # @option widget = "text"; label = "Hostname"; group = "Identity"; applyCommand = "hostnamectl set-hostname %%val%%";
        networking.hostName = "ojuny";

        # @option widget = "switch"; label = "Automatic time zone"; group = "Time and locale"; groupOrder = 20; order = 5; description = "Use automatic-timezoned and geoclue2 to set the time zone from location.";
        ojuny.time.auto = false;

        # @option widget = "dropdown"; label = "Time zone"; group = "Time and locale"; description = "A name from the tz database."; choices = [ "Europe/Amsterdam" "Europe/London" "Europe/Berlin" "UTC" "America/New_York" "America/Los_Angeles" "Asia/Tokyo" "Asia/Shanghai" "Australia/Sydney" ]; applyCommand = "timedatectl set-timezone %%val%%"; visibleWhen.path = "ojuny.time.auto"; visibleWhen.equals = false;
        time.timeZone = "Europe/Amsterdam";

        # @option widget = "dropdown"; label = "Default locale"; group = "Time and locale"; choices = [ "en_US.UTF-8" "en_GB.UTF-8" "en_AU.UTF-8" "en_CA.UTF-8" "de_DE.UTF-8" "nl_NL.UTF-8" "fr_FR.UTF-8" "es_ES.UTF-8" "pt_BR.UTF-8" "pt_PT.UTF-8" "it_IT.UTF-8" "pl_PL.UTF-8" "ru_RU.UTF-8" "uk_UA.UTF-8" "tr_TR.UTF-8" "ar_SA.UTF-8" "he_IL.UTF-8" "hi_IN.UTF-8" "ja_JP.UTF-8" "ko_KR.UTF-8" "zh_CN.UTF-8" "zh_TW.UTF-8" "sv_SE.UTF-8" "da_DK.UTF-8" "fi_FI.UTF-8" "nb_NO.UTF-8" ]; applyCommand = "localectl set-locale LANG=%%val%%"; description = "System language and formatting locale. Dux Shell follows it by default; its own Locale settings can override it at runtime.";
        i18n.defaultLocale = "en_US.UTF-8";

        # @option widget = "table-attrset"; label = "Extra locale settings"; group = "Time and locale"; advanced = true; columns = [ "locale" ]; columnTypes = [ "str" ]; keyEditable = true; description = "Per-category locale overrides, for example LC_TIME = nl_NL.UTF-8.";
        ojuny.i18n.extraLocaleSettings = { };

        # @option widget = "dropdown"; label = "Console keymap"; group = "Keyboard"; description = "Used on the TTY; the Wayland layout is on the Display page."; choices = [ "us" "uk" "de" "fr" "latam" "es" "nl" "dvorak" ]; applyCommand = "localectl set-keymap %%val%%";
        console.keyMap = "us";

        # DO NOT CHANGE, this value is for the *initial* state and should not be changed.
        system.stateVersion = "26.11";
      };

    };

  flake.modules.nixos.system-bootloader-limits =
    { lib, ... }:
    {
      # @option widget = "spin"; label = "Boot generations"; group = "Boot"; groupOrder = 70; order = 10; description = "Maximum number of systemd-boot generations kept. A higher number may keep more kernels in the boot partition.";
      boot.loader.systemd-boot.configurationLimit = lib.mkDefault 50;
    };

}
