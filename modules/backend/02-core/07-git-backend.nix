{ self, inputs, ... }: {

  flake.modules.nixos.applications-git-backend =
    {
      config,
      lib,
      ...
    }:
    {

      options.ojuny.git = {
        credentialHelper = lib.mkOption {
          type = lib.types.enum [
            "cache"
            "cache --timeout=3600"
            "store"
            "libsecret"
            "!gh auth git-credential"
          ];
          default = "cache";
          description = "Git credential helper.";
        };

        credentialFile = lib.mkOption {
          type = lib.types.str;
          default = "";
          description = "File the store helper keeps credentials in.";
        };

        askpass = lib.mkOption {
          type = lib.types.enum [
            "ssh-askpass"
            "systemd-askpass"
            "ksshaskpass"
            "lxqt-openssh-askpass"
          ];
          default = "ssh-askpass";
          description = "Command used by Git to prompt for a password.";
        };
      };

      config = {

        # Derived from the dropdown above; no @option.
        programs.git.config.core.askpass = config.ojuny.git.askpass;

        # Derived: no @option, the two controls above feed it.
        programs.git.config.credential.helper =
          if config.ojuny.git.credentialHelper == "store" && config.ojuny.git.credentialFile != "" then
            "store --file=${config.ojuny.git.credentialFile}"
          else
            config.ojuny.git.credentialHelper;

      };

    };

}
