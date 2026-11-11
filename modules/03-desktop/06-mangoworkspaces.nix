/*
  @menu
  displayname = "Workspaces";
  icon = "preferences-desktop-workspaces-symbolic";
  order = 60;
  description = "Workspace and tag settings. Named scratchpads summon on the active tag, and their commands cannot contain commas.";
  category = "03-Desktop";
*/

{ self, inputs, ... }: {

  flake.modules.nixos.desktop-mangoworkspaces =
    { config, lib, ... }:
    {
      imports = [
        self.modules.nixos.system-overflow-layout
        self.modules.nixos.desktop-mangoworkspaces-backend
      ];

      config = {
        # @option widget = "switch"; label = "Quake console"; group = "Quake"; description = "Enable the quake-style scratchpad terminal and its keybind.";
        ojuny.quake.enable = true;

        # @option widget = "slider"; label = "Width ratio"; group = "Quake"; min = 0.1; max = 1.0; step = 0.05; description = "Width of the quake scratchpad as a fraction of the screen.";
        ojuny.quake.widthRatio = 0.7;

        # @option widget = "slider"; label = "Height ratio"; group = "Quake"; min = 0.1; max = 1.0; step = 0.05; description = "Height of the quake scratchpad as a fraction of the screen. This is global, so it also affects other named scratchpads.";
        ojuny.quake.heightRatio = 0.55;

        # @option widget = "list"; label = "Modifiers"; group = "Quake"; itemLabel = "Modifier"; addLabel = "Add modifier"; description = "Modifier keys that open the quake console, for example SUPER.";
        ojuny.quake.modifier = [ "SUPER" ];

        # @option widget = "list"; label = "Keys"; group = "Quake"; itemLabel = "Key"; addLabel = "Add key"; description = "Keys that toggle the quake console with the modifiers above.";
        ojuny.quake.keys = [ "grave" ];

        # @option widget = "table-attrset"; label = "Scratchpads"; group = "Scratchpads"; groupOrder = 15; columns = [ "enable" "appId" "title" "command" "chord" ]; columnTypes = [ "bool" "str" "str" "str" "str" ]; keyEditable = true; firstValueEditable = true; description = "One row per named scratchpad, keyed by a stable name. Set appId, title, or both to identify the window; an empty field is sent to Mango as none. command must launch the app with that class or title. chord is MOD+KEY and must be unique. A named scratchpad opens on the tag that is active when you toggle it; Mango has no per-tag pinning. Dimensions are global. Commands cannot contain commas because bind arguments and rule fields are comma-separated.";
        ojuny.scratchpads = { };

        # @option widget = "switch"; label = "Only one scratchpad visible at a time"; group = "Scratchpads"; groupOrder = 15; order = 20; description = "Global Mango option. When on, showing a named scratchpad hides the normal scratchpad and every other named scratchpad. It applies to all scratchpads, not one row."; applyCommand = "mmsg dispatch setoption,single_scratchpad,$(case %%val%% in true) echo 1;; *) echo 0;; esac)";
        ojuny.mango.flag.single_scratchpad = false;

        # Workspaces
        # @option widget = "spin"; label = "Tag count"; group = "Workspaces"; groupOrder = 5; order = 10; min = 1;
        desktop.ojuny.mango.global.tag_num = 10;

        # @option widget = "switch"; label = "Gather occupied tags"; group = "Workspaces"; groupOrder = 5; order = 30; applyCommand = "mmsg dispatch setoption,tag_gather,$(case %%val%% in true) echo 1;; *) echo 0;; esac)";
        ojuny.mango.flag.tag_gather = true;

        # @option widget = "switch"; label = "Share scratchpad across monitors"; group = "Workspaces"; groupOrder = 5; order = 40; applyCommand = "mmsg dispatch setoption,scratchpad_cross_monitor,$(case %%val%% in true) echo 1;; *) echo 0;; esac)";
        ojuny.mango.flag.scratchpad_cross_monitor = true;

        # @option widget = "switch"; label = "Tag carousel"; group = "Workspaces"; groupOrder = 5; order = 50; hidden = true; applyCommand = "mmsg dispatch setoption,tag_carousel,$(case %%val%% in true) echo 1;; *) echo 0;; esac)";
        ojuny.mango.flag.tag_carousel = false;

        # @option widget = "dropdown"; label = "Default Layout"; group = "Workspaces"; groupOrder = 5; order = 20; choices = [ "tile" "dwindle" "scroller" "monocle" "deck" "grid" "fair" "vertical_scroller" "vertical_tile" "vertical_fair" "vertical_grid" "vertical_deck" "right_tile" "center_tile" ]; description = "Layout used by tags without an explicit per-workspace row.";
        ojuny.workspaces.defaultLayout = "tile";

        # @option widget = "switch"; label = "Overflow layout"; group = "Overflow layout"; groupOrder = 15; order = 5; description = "Switch the active workspace to the overflow layout when it holds the configured number of tiled windows. The previous layout is restored when the count drops below it.";
        ojuny.workspaces.overflow.enable = false;

        # @option widget = "spin"; label = "Overflow after this many windows"; group = "Overflow layout"; groupOrder = 15; order = 10; min = 1; max = 99; unit = "windows"; visibleWhen.path = "ojuny.workspaces.overflow.enable"; visibleWhen.equals = true; description = "Switch the active workspace to the overflow layout when it holds at least this many tiled windows. Floating windows are not counted.";
        ojuny.workspaces.overflow.windowCount = 4;

        # @option widget = "dropdown"; label = "Overflow layout"; group = "Overflow layout"; groupOrder = 15; order = 20; choices = [ "tile" "dwindle" "scroller" "monocle" "deck" "grid" "fair" "vertical_scroller" "vertical_tile" "vertical_fair" "vertical_grid" "vertical_deck" "right_tile" "center_tile" ]; visibleWhen.path = "ojuny.workspaces.overflow.enable"; visibleWhen.equals = true; description = "Layout used when a workspace reaches the overflow window count. The previous layout is restored when the count drops below it.";
        ojuny.workspaces.overflow.layout = "monocle";

        # Per-workspace layout
        # @option widget = "table-list"; label = "Per-workspace layout"; group = "Per-Workspace Layout"; groupOrder = 20; columns = [ "tag" "note" "monitor_name" "layout" ]; columnTypes = [ "int" "str" "str" "dropdown" ]; choices = [ "tile" "dwindle" "scroller" "monocle" "deck" "grid" "fair" "vertical_scroller" "vertical_tile" "vertical_fair" "vertical_grid" "vertical_deck" "right_tile" "center_tile" ]; firstValueEditable = true; description = "One row per workspace. tag is 0 for the special workspace or a number up to the tag count. note is a display label only. monitor_name pins the layout to one output; empty applies to all monitors. layout is the Mango layout. Rows apply in table order after the default wildcard rule, so a specific tag overrides the wildcard.";
        ojuny.workspaces.tags = [
          {
            tag = 0;
            note = "special";
            monitor_name = "";
            layout = "monocle";
          }
        ];

        # Special workspace (tag 0)
        # @option widget = "slider"; label = "Background dim"; group = "Special workspace"; min = 0.0; max = 1.0; step = 0.05; applyCommand = "mmsg dispatch setoption,special_dim,%%val%%";
        desktop.ojuny.mango.global.special_dim = 0.5;

        # @option widget = "spin"; label = "Inner gap (horizontal)"; group = "Special workspace"; min = 0; max = 64; unit = "px"; advanced = true; applyCommand = "mmsg dispatch setoption,special_gap_inner_horizontal,%%val%%";
        desktop.ojuny.mango.global.special_gap_inner_horizontal = 5;

        # @option widget = "spin"; label = "Inner gap (vertical)"; group = "Special workspace"; min = 0; max = 64; unit = "px"; advanced = true; applyCommand = "mmsg dispatch setoption,special_gap_inner_vertical,%%val%%";
        desktop.ojuny.mango.global.special_gap_inner_vertical = 5;

        # @option widget = "spin"; label = "Outer gap (horizontal)"; group = "Special workspace"; min = 0; max = 64; unit = "px"; advanced = true; applyCommand = "mmsg dispatch setoption,special_gap_outer_horizontal,%%val%%";
        desktop.ojuny.mango.global.special_gap_outer_horizontal = 30;

        # @option widget = "spin"; label = "Outer gap (vertical)"; group = "Special workspace"; min = 0; max = 64; unit = "px"; advanced = true; applyCommand = "mmsg dispatch setoption,special_gap_outer_vertical,%%val%%";
        desktop.ojuny.mango.global.special_gap_outer_vertical = 30;
      };
    };
}
