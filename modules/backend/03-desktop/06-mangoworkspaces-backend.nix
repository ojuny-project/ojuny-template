{ self, inputs, ... }: {

  flake.modules.nixos.desktop-mangoworkspaces-backend =
    { config, lib, ... }:

    let
      # mango stores booleans as the integers 0 and 1, so these are exposed as
      # switches under ojuny.mango.* and written back as 0/1 in the derived
      # assignments at the bottom of this module.
      flagDefaults = {
        tag_gather = true;
        tag_carousel = false;
        scratchpad_cross_monitor = true;
        single_scratchpad = false;
      };

      layoutChoices = [
        "tile"
        "dwindle"
        "scroller"
        "monocle"
        "deck"
        "grid"
        "fair"
        "vertical_scroller"
        "vertical_tile"
        "vertical_fair"
        "vertical_grid"
        "vertical_deck"
        "right_tile"
        "center_tile"
      ];



      tagRuleSpec = lib.types.submodule {
        options = {
          tag = lib.mkOption {
            type = lib.types.ints.between 0 99;
            default = 0;
            description = "Tag id. 0 is the special workspace.";
          };

          note = lib.mkOption {
            type = lib.types.str;
            default = "";
            description = "Display note for the table row. Not sent to Mango.";
          };

          monitor_name = lib.mkOption {
            type = lib.types.str;
            default = "";
            description = "Mango monitor name this layout applies to. Empty applies to all monitors.";
          };

          layout = lib.mkOption {
            type = lib.types.enum layoutChoices;
            default = "tile";
            description = "Mango layout name.";
          };
        };
      };

      scratchpadFields = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Generate the bind and window rule for this scratchpad.";
        };

        appId = lib.mkOption {
          type = lib.types.str;
          default = "";
          description = "Window app_id. Empty sends none to Mango.";
        };

        title = lib.mkOption {
          type = lib.types.str;
          default = "";
          description = "Window title. Empty sends none to Mango.";
        };

        command = lib.mkOption {
          type = lib.types.str;
          default = "";
          description = "Launch command. It cannot contain commas.";
        };

        chord = lib.mkOption {
          type = lib.types.str;
          default = "SUPER+grave";
          description = "MOD+KEY chord. It must be unique.";
        };
      };

      scratchpadSpec = lib.types.submodule {
        options = scratchpadFields;
      };

      cfg = config.ojuny.workspaces;
      tagNum = config.desktop.ojuny.mango.global.tag_num or 10;
      tagRules = map (
        rule:
        {
          id = rule.tag;
          layout_name = rule.layout;
        }
        // lib.optionalAttrs (rule.monitor_name != "") {
          monitor_name = rule.monitor_name;
        }
      ) cfg.tags;

      scratchpadRows = lib.mapAttrsToList (name: row: row // { inherit name; }) config.ojuny.scratchpads;

      quakeScratchpadRow = {
        name = "quake";
        enable = true;
        appId = "org.ojuny.quake";
        title = "";
        command = "ghostty --class=org.ojuny.quake";
        chord = lib.concatStringsSep "+" (config.ojuny.quake.modifier ++ config.ojuny.quake.keys);
      };

      allScratchpads = scratchpadRows ++ lib.optional config.ojuny.quake.enable quakeScratchpadRow;

      activeScratchpads = lib.filter (row: row.enable) allScratchpads;

      splitChord =
        chord:
        let
          parts = lib.splitString "+" chord;
          modifiers = lib.init parts;
        in
        {
          keys = [ (lib.last parts) ];
          modifier = if modifiers == [ ] then [ "none" ] else modifiers;
        };

      scratchpadBind =
        row:
        {
          inherit (splitChord row.chord) modifier keys;
          dispatcher = "toggle_named_scratchpad";
          args = "${if row.appId != "" then row.appId else "none"},${if row.title != "" then row.title else "none"},${row.command}";
          description = "Toggle ${row.name} scratchpad";
          group = "Windows";
          subcat = "Scratchpad";
        };

      scratchpadBinds = lib.listToAttrs (
        map (row: {
          name = row.name;
          value = scratchpadBind row;
        }) activeScratchpads
      );

      scratchpadWindowRule =
        row:
        { is_named_scratchpad = 1; }
        // lib.optionalAttrs (row.appId != "") { app_id = row.appId; }
        // lib.optionalAttrs (row.title != "") { title = row.title; };
    in
    {
      options.ojuny.mango.flag = lib.mapAttrs (
        name: default:
        lib.mkOption {
          type = lib.types.bool;
          inherit default;
          description = "mango global ${name}, stored as 0/1.";
        }
      ) flagDefaults;

      options.ojuny.quake = {
        enable = lib.mkEnableOption "the quake-style scratchpad terminal";
        widthRatio = lib.mkOption {
          type = lib.types.float;
          default = 0.7;
          description = "Width of the quake scratchpad as a fraction of the screen.";
        };
        heightRatio = lib.mkOption {
          type = lib.types.float;
          default = 0.55;
          description = "Height of the quake scratchpad as a fraction of the screen. This is global, so it also affects other named scratchpads.";
        };
        modifier = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [ "SUPER" ];
          description = "Modifier keys that open the quake console.";
        };
        keys = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [ "grave" ];
          description = "Keys that toggle the quake console with the modifiers above.";
        };
      };

      options.ojuny.scratchpads = lib.mkOption {
        type = lib.types.attrsOf scratchpadSpec;
        default = { };
        description = "Named scratchpads, keyed by a stable name. Each enabled row generates one bind and one window rule.";
      };

      options.ojuny.workspaces.tags = lib.mkOption {
        type = lib.types.listOf tagRuleSpec;
        default = [ ];
        description = "Tag rules in application order. Specific tags override the wildcard rule.";
      };

      options.ojuny.workspaces.defaultLayout = lib.mkOption {
        type = lib.types.enum layoutChoices;
        default = "tile";
        description = "Layout used by tags without an explicit per-workspace row.";
      };

      options.ojuny.workspaces.overflow = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "Switch the active workspace to the overflow layout when it holds the configured number of tiled windows.";
        };
        windowCount = lib.mkOption {
          type = lib.types.ints.between 0 99;
          default = 4;
          description = "Number of tiled windows that triggers the overflow layout. Floating windows are not counted.";
        };
        layout = lib.mkOption {
          type = lib.types.enum layoutChoices;
          default = "monocle";
          description = "Layout used when a workspace reaches the overflow window count.";
        };
      };

      config = {
        desktop.ojuny.mango.global.scratchpad_width_ratio = config.ojuny.quake.widthRatio;
        desktop.ojuny.mango.global.scratchpad_height_ratio = config.ojuny.quake.heightRatio;

        desktop.ojuny.mango.binds.common = scratchpadBinds;

        assertions = [
          {
            assertion = lib.all (rule: rule.tag <= tagNum) cfg.tags;
            message = "ojuny.workspaces.tags contains a tag id above desktop.ojuny.mango.global.tag_num.";
          }
          {
            assertion =
              let
                tags = map (rule: rule.tag) cfg.tags;
              in
              lib.length tags == lib.length (lib.unique tags);
            message = "ojuny.workspaces.tags has duplicate tag ids.";
          }
          {
            assertion = lib.all (row: row.appId != "" || row.title != "") allScratchpads;
            message = "ojuny.scratchpads rows must set appId, title, or both.";
          }
          {
            assertion = lib.all (row: row.command != "") allScratchpads;
            message = "ojuny.scratchpads rows must set a non-empty command.";
          }
          {
            assertion = lib.all (
              row:
              lib.all (value: !lib.hasInfix "," value) [
                row.name
                row.appId
                row.title
                row.command
                row.chord
              ]
            ) allScratchpads;
            message = "ojuny.scratchpads values cannot contain commas; bind arguments and rule fields are comma-separated.";
          }
          {
            assertion =
              let
                pairs = map (row: [ row.appId row.title ]) allScratchpads;
              in
              lib.length pairs == lib.length (lib.unique pairs);
            message = "ojuny.scratchpads has a duplicate appId and title pair, including the quake row.";
          }
          {
            assertion =
              let
                chords = map (row: row.chord) activeScratchpads;
              in
              lib.length chords == lib.length (lib.unique chords);
            message = "ojuny.scratchpads chords must be unique across enabled rows and the quake row.";
          }
        ];

        desktop.ojuny.mango.rules.window_rule = lib.mkAfter (map scratchpadWindowRule activeScratchpads);

        desktop.ojuny.mango.rules.tag_rule = lib.mkBefore (
          [
            {
              id = "*";
              layout_name = cfg.defaultLayout;
            }
          ]
          ++ tagRules
        );

        # Derived mango integers (no @option, hidden in the GUI).
        desktop.ojuny.mango.global.tag_gather = if config.ojuny.mango.flag.tag_gather then 1 else 0;
        desktop.ojuny.mango.global.tag_carousel = if config.ojuny.mango.flag.tag_carousel then 1 else 0;
        desktop.ojuny.mango.global.scratchpad_cross_monitor =
          if config.ojuny.mango.flag.scratchpad_cross_monitor then 1 else 0;
        desktop.ojuny.mango.global.single_scratchpad =
          if config.ojuny.mango.flag.single_scratchpad then 1 else 0;
      };
    };
}
