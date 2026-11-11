{ self, inputs, ... }: {

  flake.modules.nixos.applications-terminal-backend =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      options.ojuny.apps.terminal = {
        enable = lib.mkEnableOption "the terminal application set";

        aliases = lib.mkOption {
          type = lib.types.attrsOf (
            lib.types.submodule {
              options = {
                enable = lib.mkOption {
                  type = lib.types.bool;
                  default = true;
                  description = "Enable this alias.";
                };
                value = lib.mkOption {
                  type = lib.types.str;
                  description = "Command the alias expands to.";
                };
              };
            }
          );
          default = { };
          description = "Shell aliases keyed by name, converted to environment.shellAliases.";
        };

        p10k = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Load the powerlevel10k prompt theme.";
        };

        fastfetch = {
          customLogo = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Use a custom image for the fastfetch logo.";
          };

          customLogoPath = lib.mkOption {
            type = lib.types.nullOr lib.types.path;
            default = null;
            description = "Path to the image used as the fastfetch logo when customLogo is enabled.";
          };
        };
      };

      config = {
        programs.zsh.promptInit = ''
          nixupdatesrc=${
            builtins.path {
              name = "nixupdate.sh";
              path = ./terminal/nixupdate.sh;
            }
          }
          ${lib.optionalString config.ojuny.apps.terminal.p10k "source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme"}
          source ${
            builtins.path {
              name = "config.zsh";
              path = ./terminal/config.zsh;
            }
          }
          source ${
            builtins.path {
              name = "functions.zsh";
              path = ./terminal/functions.zsh;
            }
          }
          ${lib.optionalString config.ojuny.apps.terminal.p10k "POWERLEVEL9K_DISABLE_CONFIGURATION_WIZARD=true"}
        '';

        programs.zsh.interactiveShellInit = ''
          eval "$(zoxide init --cmd cd zsh)"
          if [ "$TERM_PROGRAM" != "vscode" ]; then
            if which fastfetch 2>&1 > /dev/null; then fastfetch; else nix-shell -p fastfetch --run "fastfetch"; fi
          fi
        '';

        # Derived, no @option: enabled rows become shell aliases; nixupdate stays fixed.
        environment.shellAliases =
          lib.mapAttrs (_: entry: entry.value) (
            lib.filterAttrs (_: entry: entry.enable) config.ojuny.apps.terminal.aliases
          )
          // {
            nixupdate = "${builtins.path {
              name = "nixupdate.sh";
              path = ./terminal/nixupdate.sh;
            }}";
          };
      };
    };

  flake.modules.homeManager.applications-terminal-fastfetch =
    {
      config,
      lib,
      pkgs,
      osConfig ? { },
      ...
    }:
    let
      colors = self.colors config.lib.stylix.colors;
      template = osConfig.ojuny.style.palette;
      fastfetch =
        osConfig.ojuny.apps.terminal.fastfetch or {
          customLogo = false;
          customLogoPath = null;
        };
    in
    {
      config = lib.mkIf (osConfig.ojuny.apps.terminal.enable or false) {
        programs.fastfetch = {
          enable = true;

          settings = lib.mkDefault {
            display = {
              separator = " ";
            };

            logo = {
              type = "auto";
              source =
                if fastfetch.customLogo && fastfetch.customLogoPath != null then
                  toString fastfetch.customLogoPath
                else
                  "nixos";
              width = 40;
              padding = {
                top = 0;
                left = 0;
                right = 2;
              };
              color = {
                "1" = colors.selectionBackground.hex;
                "2" = colors.variables.hex;
                "3" = colors.selectionBackground.hex;
                "4" = colors.classes.hex;
                "5" = colors.selectionBackground.hex;
                "6" = colors.functions.hex;
              };
            };

            modules = [
              {
                type = "title";
                keyWidth = 10;
              }
              "break"
              {
                type = "os";
                key = " OS";
                keyColor = colors.variables.hex;
              }
              {
                type = "custom";
                key = "├  Dotfiles";
                keyColor = colors.variables.hex;
                format = "Ojuny";
              }
              {
                type = "kernel";
                key = "├ Kernel";
                keyColor = colors.variables.hex;
              }
              {
                type = "packages";
                key = "├󰏖 Packages";
                keyColor = colors.variables.hex;
              }
              {
                type = "shell";
                key = "├ Shell";
                keyColor = colors.variables.hex;
              }
              {
                type = "localIP";
                key = "├󰩟 Local IP";
                keyColor = colors.variables.hex;
              }
              {
                type = "uptime";
                key = "└󰅐 Start Time";
                keyColor = colors.variables.hex;
              }
              "break"
              {
                type = "wm";
                key = "󰧨 Window Manager";
                keyColor = colors.classes.hex;
              }
              {
                type = "custom";
                key = "├󱂬 Desktop Shell";
                keyColor = colors.classes.hex;
                format = "Dux Modular Shell";
              }
              {
                type = "lm";
                key = "├󰧨 Login Manager";
                keyColor = colors.classes.hex;
              }
              {
                type = "wmtheme";
                key = "├󰉼 WM Theme";
                keyColor = colors.classes.hex;
              }
              {
                type = "theme";
                key = "├󰉼 Color Themes";
                keyColor = colors.classes.hex;
              }
              {
                type = "custom";
                key = "├󰉼Stylix Palette";
                keyColor = colors.classes.hex;
                format = "${template}";
              }
              {
                type = "icons";
                key = "├󰸉 System Icons";
                keyColor = colors.classes.hex;
              }
              {
                type = "terminal";
                key = "├ Terminal";
                keyColor = colors.classes.hex;
              }
              {
                type = "terminalfont";
                key = "└ Terminal Font";
                keyColor = colors.classes.hex;
              }
              "break"
              {
                type = "chassis";
                key = "󰌢 PC";
                keyColor = colors.functions.hex;
              }
              {
                type = "board";
                key = "├ Board";
                keyColor = colors.functions.hex;
              }
              {
                type = "cpu";
                key = "├󰻠 CPU";
                keyColor = colors.functions.hex;
                temp = true;
                freqNdigits = 1;
              }
              {
                type = "memory";
                key = "├󰑭 RAM";
                keyColor = colors.functions.hex;
                percent = {
                  type = 3;
                  green = 30;
                  yellow = 70;
                };
              }
              {
                type = "swap";
                key = "├󰓡 Zram";
                keyColor = colors.functions.hex;
                percent = {
                  type = 3;
                  green = 30;
                  yellow = 70;
                };
              }
              {
                type = "disk";
                key = "├ Disk";
                keyColor = colors.functions.hex;
                percent = {
                  type = 3;
                  green = 30;
                  yellow = 70;
                };
              }
              {
                type = "display";
                key = "├󰍹 Display(s)";
                keyColor = colors.functions.hex;
              }
              {
                type = "gpu";
                key = "├󰍛 GPU";
                keyColor = colors.functions.hex;
              }
              {
                type = "opengl";
                key = "├󰍛 OpenGL";
                keyColor = colors.functions.hex;
              }
              {
                type = "vulkan";
                key = "└󰍛 Vulkan";
                keyColor = colors.functions.hex;
              }
            ];
          };
        };
      };
    };

}
