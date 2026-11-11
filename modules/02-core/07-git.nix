/*
  @menu
  displayname = "Git";
  icon = "folder-remote-symbolic";
  order = 70;
  description = "Git and version control defaults";
  category = "02-Core";
*/

{ self, inputs, ... }: {

  flake.modules.nixos.applications-git =
    { pkgs, ... }:
    {
      imports = [ self.modules.nixos.applications-git-backend ];

      config = {

        programs.git.enable = true;

        # @option widget = "switch"; label = "Git LFS"; group = "Large files"; groupOrder = 60; order = 10; description = "Track large binaries with Git LFS.";
        programs.git.lfs.enable = false;

        # @option widget = "packages"; label = "Git packages"; group = "Git"; groupOrder = 10; order = 20; advanced = true;
        environment.systemPackages = with pkgs; [
          git
          gh
          lazygit
          delta
        ];

        # Identity
        # @option widget = "text"; label = "Name"; group = "Identity"; groupOrder = 20; order = 10; description = "Name written to new commits. Empty means git asks on first commit."; applyCommand = "if [ -n %%val%% ]; then git config --global user.name %%val%%; else git config --global --unset user.name; fi";
        programs.git.config.user.name = "";

        # @option widget = "text"; label = "Email"; group = "Identity"; groupOrder = 20; order = 20; description = "Email written to new commits. Empty means git asks on first commit."; applyCommand = "if [ -n %%val%% ]; then git config --global user.email %%val%%; else git config --global --unset user.email; fi";
        programs.git.config.user.email = "";

        # @option widget = "text"; label = "Default branch"; group = "Identity"; groupOrder = 20; order = 30; applyCommand = "git config --global init.defaultBranch %%val%%";
        programs.git.config.init.defaultBranch = "main";

        # Behaviour
        # @option widget = "dropdown"; label = "Line endings"; group = "Behaviour"; groupOrder = 30; order = 10; choices = [ "input" "true" "false" ]; applyCommand = "git config --global core.autocrlf %%val%%";
        programs.git.config.core.autocrlf = "input";

        # @option widget = "switch"; label = "Rebase on pull"; group = "Behaviour"; groupOrder = 30; order = 20; applyCommand = "git config --global pull.rebase %%val%%";
        programs.git.config.pull.rebase = false;

        # @option widget = "switch"; label = "Auto set upstream on push"; group = "Behaviour"; groupOrder = 30; order = 30; applyCommand = "git config --global push.autoSetupRemote %%val%%";
        programs.git.config.push.autoSetupRemote = true;

        # @option widget = "switch"; label = "Reuse conflict resolutions"; group = "Behaviour"; groupOrder = 30; order = 40; applyCommand = "git config --global rerere.enabled %%val%%";
        programs.git.config.rerere.enabled = true;

        # @option widget = "dropdown"; label = "Conflict style"; group = "Behaviour"; groupOrder = 30; order = 50; choices = [ "merge" "diff3" "zdiff3" ]; applyCommand = "git config --global merge.conflictstyle %%val%%";
        programs.git.config.merge.conflictstyle = "zdiff3";

        # Paging with delta
        # @option widget = "dropdown"; label = "Pager"; group = "Paging"; groupOrder = 40; order = 10; choices = [ "delta" "less" "bat" "none" ]; applyCommand = "git config --global core.pager %%val%%";
        programs.git.config.core.pager = "delta";

        # @option widget = "switch"; label = "Delta line numbers"; group = "Paging"; groupOrder = 40; order = 20; applyCommand = "git config --global delta.lineNumbers %%val%%";
        programs.git.config.delta.lineNumbers = true;

        # @option widget = "dropdown"; label = "Delta decorations"; group = "Paging"; groupOrder = 40; order = 30; choices = [ "plain" "filebox" "underline" "box" "boxe" "ol" "ul" ]; description = "Style for the +/- file decorations."; applyCommand = "git config --global delta.decorationStyle %%val%%";
        programs.git.config.delta.decorationStyle = "filebox";

        # Credentials, askpass and stores
        # @option widget = "dropdown"; label = "Askpass helper"; group = "Credentials"; groupOrder = 50; order = 10; choices = [ "ssh-askpass" "systemd-askpass" "ksshaskpass" "lxqt-openssh-askpass" ]; description = "Command that prompts for a password."; applyCommand = "git config --global core.askpass %%val%%";
        ojuny.git.askpass = "ssh-askpass";

        # @option widget = "dropdown"; label = "Credential helper"; group = "Credentials"; groupOrder = 50; order = 20; description = "Where stored credentials live. Pick store to keep them in a file."; choices = [ "cache" "cache --timeout=3600" "store" "libsecret" "!gh auth git-credential" ]; applyCommand = "git config --global credential.helper %%val%%";
        ojuny.git.credentialHelper = "cache";

        # @option widget = "text"; label = "Credential file"; group = "Credentials"; groupOrder = 50; order = 30; description = "File the store helper keeps credentials in."; visibleWhen.path = "ojuny.git.credentialHelper"; visibleWhen.equals = "store"; applyCommand = "if [ -n %%val%% ]; then git config --global credential.helper \"store --file=%%val%%\"; else git config --global credential.helper store; fi";
        ojuny.git.credentialFile = "";

        # @option widget = "switch"; label = "Store HTTP path"; group = "Credentials"; groupOrder = 50; order = 40; description = "Keep credentials per host and path, not just per host."; applyCommand = "git config --global credential.useHttpPath %%val%%";
        programs.git.config.credential.useHttpPath = false;

        # @option widget = "switch"; label = "GitHub credential helper"; group = "Credentials"; groupOrder = 50; order = 50; description = "Use gh to authenticate github.com over HTTPS."; applyCommand = "git config --global credential.https://github.com.helper %%val%%";
        programs.git.config.credential."https://github.com".helper = "!gh auth git-credential";

      };

    };

}
