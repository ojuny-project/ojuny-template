{ self, inputs, ... }: {

  flake.modules.nixos.applications-browser-backend =
    {
      config,
      lib,
      ...
    }:
    let
      browserCommand =
        {
          firefox = "firefox --new-window";
          chrome = "google-chrome-stable --new-window";
          brave = "brave --new-window";
        }
        .${config.ojuny.browser.selected};

      enabledSearchEngines = lib.filterAttrs (
        _: engine: engine.enable
      ) config.ojuny.browser.searchEngines;

      defaultSearchEngine =
        let
          engines = lib.attrValues enabledSearchEngines;
        in
        if engines == [ ] then
          null
        else
          lib.findFirst (engine: engine.isDefault) (lib.head engines) engines;

      searchEngineKeyword = alias: if lib.hasPrefix "@" alias then lib.removePrefix "@" alias else alias;

      toolbarBookmarks = lib.filter (bookmark: bookmark.toolbar) config.ojuny.browser.bookmarks;
      folderedBookmarks = lib.filter (
        bookmark: !bookmark.toolbar && bookmark.folder != ""
      ) config.ojuny.browser.bookmarks;
      topLevelBookmarks = lib.filter (
        bookmark: !bookmark.toolbar && bookmark.folder == ""
      ) config.ojuny.browser.bookmarks;

      bookmarksByFolder = lib.foldl' (
        folders: bookmark:
        folders
        // {
          ${bookmark.folder} = (folders.${bookmark.folder} or [ ]) ++ [ bookmark ];
        }
      ) { } folderedBookmarks;

      chromiumBookmark = bookmark: {
        inherit (bookmark) name url;
      };

      chromiumBookmarkFolders = lib.mapAttrsToList (folder: bookmarks: {
        name = folder;
        children = map chromiumBookmark bookmarks;
      }) bookmarksByFolder;

      chromiumPolicy =
        lib.optionalAttrs (defaultSearchEngine != null) {
          DefaultSearchProviderEnabled = true;
          DefaultSearchProviderName = defaultSearchEngine.name;
          DefaultSearchProviderSearchURL = defaultSearchEngine.searchUrl;
          DefaultSearchProviderEncodings = [ "UTF-8" ];
        }
        // lib.optionalAttrs (defaultSearchEngine != null && defaultSearchEngine.alias != "") {
          DefaultSearchProviderKeyword = searchEngineKeyword defaultSearchEngine.alias;
        }
        // lib.optionalAttrs (config.ojuny.browser.bookmarks != [ ]) {
          ManagedBookmarks = [
            { toplevel_name = "Managed bookmarks"; }
          ]
          ++ map chromiumBookmark topLevelBookmarks
          ++ chromiumBookmarkFolders
          ++ lib.optional (toolbarBookmarks != [ ]) {
            name = "Bookmarks Toolbar";
            children = map chromiumBookmark toolbarBookmarks;
          };
        }
        // lib.optionalAttrs (toolbarBookmarks != [ ]) {
          BookmarkBarEnabled = true;
        };

      chromePoliciesEnabled =
        config.ojuny.browser.selected == "chrome"
        && config.ojuny.browser.chrome.enable
        && chromiumPolicy != { };
      bravePoliciesEnabled =
        config.ojuny.browser.selected == "brave"
        && config.ojuny.browser.brave.enable
        && chromiumPolicy != { };
    in
    {
      options.ojuny.browser.command = lib.mkOption {
        type = lib.types.str;
        internal = true;
        default = browserCommand;
        description = "Command used by the browser keybind for the selected browser.";
      };

      options.ojuny.browser.selected = lib.mkOption {
        type = lib.types.enum [
          "firefox"
          "chrome"
          "brave"
        ];
        default = "firefox";
        description = "Browser used for web and document links.";
      };

      options.ojuny.browser.chrome.savePasswords = lib.mkEnableOption "saving passwords in Chrome";

      options.ojuny.browser.brave.savePasswords = lib.mkEnableOption "saving passwords in Brave";

      options.ojuny.browser.searchEngines = lib.mkOption {
        type = lib.types.attrsOf (
          lib.types.submodule (
            { name, ... }:
            {
              options = {
                enable = lib.mkOption {
                  type = lib.types.bool;
                  default = true;
                  description = "Enable this search engine.";
                };
                name = lib.mkOption {
                  type = lib.types.nonEmptyStr;
                  default = name;
                  description = "Search engine display name.";
                };
                searchUrl = lib.mkOption {
                  type = lib.types.nonEmptyStr;
                  description = "Search URL template containing {searchTerms}.";
                };
                alias = lib.mkOption {
                  type = lib.types.str;
                  default = "";
                  description = "Search alias. Firefox receives it with a leading @, Chromium without.";
                };
                isDefault = lib.mkOption {
                  type = lib.types.bool;
                  default = false;
                  description = "Use this engine as the single Chrome or Brave default. Firefox keeps its own Search engine option.";
                };
              };
            }
          )
        );
        default = { };
        description = "Custom search engines keyed by id. Firefox installs every enabled row. Chrome and Brave use the isDefault row, or the first row.";
      };

      options.ojuny.browser.bookmarks = lib.mkOption {
        type = lib.types.listOf (
          lib.types.submodule {
            options = {
              name = lib.mkOption {
                type = lib.types.nonEmptyStr;
                description = "Bookmark name.";
              };
              url = lib.mkOption {
                type = lib.types.nonEmptyStr;
                description = "Bookmark URL.";
              };
              folder = lib.mkOption {
                type = lib.types.str;
                default = "";
                description = "Folder name. Empty keeps the bookmark at the top level.";
              };
              toolbar = lib.mkOption {
                type = lib.types.bool;
                default = false;
                description = "Place the bookmark in the Firefox bookmarks toolbar. Chromium browsers only enable the bookmarks bar.";
              };
            };
          }
        );
        default = [ ];
        description = "Bookmarks written to Firefox and to the selected Chromium browser's managed policies.";
      };

      options.ojuny.browser.chromiumExtensions = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [
          "cjpalhdlnbpafiamejdnhcphjbkeiagm"
          "mnjggcdmjocbbbhaepdhchncahnbgone"
        ];
        description = "Chromium, Chrome, and Brave extension IDs installed through the ExtensionInstallForcelist policy.";
      };

      options.ojuny.browser.firefox.autoEnableExtensions = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Set extensions.autoDisableScopes to 0 so packaged Firefox extensions are enabled on first launch.";
      };

      options.ojuny.browser.firefox.stylixColorTheme = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Apply the Stylix Firefox color theme to the default profile.";
      };

      options.ojuny.browser.firefox.extensions = lib.mkOption {
        type = lib.types.listOf lib.types.package;
        default = [ ];
        description = "Firefox extensions installed into the default profile.";
      };

      options.ojuny.browser.chromiumStylix = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Apply the Stylix Chromium theme color policy to Chromium, Chrome, and Brave.";
      };

      options.ojuny.browser.defaults = {
        html = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "the selected browser as default for HTML files";
        };
        http = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "the selected browser as default for HTTP links";
        };
        https = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "the selected browser as default for HTTPS links";
        };
        pdf = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "the selected browser as default for PDF documents";
        };
        png = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "the selected browser as default for PNG images";
        };
        mailto = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "the selected browser as default for email links";
        };
      };

      config = {
        programs.chromium.enable = lib.mkDefault config.ojuny.browser.selected != "firefox";

        programs.chromium.defaultSearchProviderEnabled = config.ojuny.browser.selected != "firefox";

        programs.chromium.extensions = config.ojuny.browser.chromiumExtensions;

        stylix.targets.chromium.enable = config.ojuny.browser.chromiumStylix;

        programs.chromium.extraOpts =
          {
            firefox = { };
            chrome = {
              PasswordManagerEnabled = config.ojuny.browser.chrome.savePasswords;
            };
            brave = {
              PasswordManagerEnabled = config.ojuny.browser.brave.savePasswords;
            };
          }
          .${config.ojuny.browser.selected};

        environment.etc = lib.mkMerge [
          (lib.mkIf chromePoliciesEnabled {
            "opt/chrome/policies/managed/ojuny.json".text = builtins.toJSON chromiumPolicy;
          })
          (lib.mkIf bravePoliciesEnabled {
            "brave/policies/managed/ojuny.json".text = builtins.toJSON chromiumPolicy;
          })
        ];
      };
    };

}
