/*
  Bar widget catalog. One @widget-preset per widget DMS ships; presets with
  an options file in BarWidgetCatalog.qml also carry @widget-preset-field
  markers describing the settings the editor renders in the cog pop-out.
*/
/*
  @widget-preset
  id = "layout"; label = "Layout";
  description = "Display and switch MangoWC layouts";
  icon = "view-grid-symbolic"; sections = [ "left" "right" "center" "dock" ];
  hasSettings = false;
*/
/*
  @widget-preset
  id = "launcherButton"; label = "App launcher";
  description = "Quick access to application launcher";
  icon = "view-app-grid-symbolic"; sections = [ "left" "right" "center" "dock" ];
  hasSettings = true;
  defaults.launcherLogoMode = "apps";
  defaults.launcherLogoSizeOffset = 0;
*/
/*
  @widget-preset-field
  preset = "launcherButton"; name = "launcherLogoMode";
  widget = "dropdown"; choices = [ "apps" "os" "custom" ];
  label = "Logo"; description = "Which logo the launcher button shows.";
*/
/*
  @widget-preset-field
  preset = "launcherButton"; name = "launcherLogoSizeOffset";
  widget = "spin"; min = -20; max = 20; unit = "px";
  label = "Logo size offset"; description = "Grow or shrink the launcher logo.";
*/
/*
  @widget-preset-field
  preset = "launcherButton"; name = "launcherLogoBrightness";
  widget = "slider"; min = 0.0; max = 1.0; step = 0.05;
  label = "Logo brightness"; description = "Brightness of the launcher logo color.";
*/
/*
  @widget-preset-field
  preset = "launcherButton"; name = "launcherLogoColorOverride";
  widget = "text";
  label = "Logo color override"; description = "Color role name or hex value; empty follows the theme.";
*/
/*
  @widget-preset-field
  preset = "launcherButton"; name = "launcherLogoContrast";
  widget = "slider"; min = 0.0; max = 2.0; step = 0.05;
  label = "Logo contrast"; description = "Contrast of the launcher logo color.";
*/
/*
  @widget-preset-field
  preset = "launcherButton"; name = "launcherLogoCustomPath";
  widget = "text";
  label = "Custom logo path"; description = "Image used when the logo mode is custom.";
*/

/*
  @widget-preset
  id = "workspaceSwitcher"; label = "Workspace switcher";
  description = "Shows current workspace and allows switching";
  icon = "view-dual-symbolic"; sections = [ "left" "right" "center" "dock" ];
  hasSettings = true;
  defaults.showOccupiedWorkspacesOnly = true;
  defaults.showWorkspaceIndex = true;
  defaults.showWorkspacePadding = true;
  defaults.workspacePaddingCount = 5;
  defaults.workspaceIndicatorCompact = true;
  defaults.dwlShowAllTags = false;
*/
/*
  @widget-preset-field
  preset = "workspaceSwitcher"; name = "showOccupiedWorkspacesOnly";
  widget = "switch"; label = "Show occupied workspaces only";
  description = "Only list workspaces that have open windows.";
*/
/*
  @widget-preset-field
  preset = "workspaceSwitcher"; name = "showWorkspaceIndex";
  widget = "switch"; label = "Show workspace index";
*/
/*
  @widget-preset-field
  preset = "workspaceSwitcher"; name = "workspacePaddingCount";
  widget = "spin"; min = 0; max = 20;
  label = "Workspace padding count";
*/
/*
  @widget-preset-field
  preset = "workspaceSwitcher"; name = "workspaceIndicatorCompact";
  widget = "switch"; label = "Compact indicators";
  description = "Use the compact workspace pill size.";
*/
/*
  @widget-preset-field
  preset = "workspaceSwitcher"; name = "dwlShowAllTags";
  widget = "switch"; label = "Show all tags";
  description = "DWL only: list every tag instead of occupied ones.";
*/
/*
  @widget-preset-field
  preset = "workspaceSwitcher"; name = "groupActiveWorkspaceApps";
  widget = "switch";
  label = "Group on active workspace"; description = "Group app icons on the active workspace.";
*/
/*
  @widget-preset-field
  preset = "workspaceSwitcher"; name = "groupWorkspaceApps";
  widget = "switch";
  label = "Group apps"; description = "Group app icons by application.";
*/
/*
  @widget-preset-field
  preset = "workspaceSwitcher"; name = "maxWorkspaceIcons";
  widget = "spin"; min = 1; max = 10;
  label = "Max apps to show"; description = "App icons shown per workspace.";
*/
/*
  @widget-preset-field
  preset = "workspaceSwitcher"; name = "reverseScrolling";
  widget = "switch";
  label = "Reverse scroll direction"; description = "Invert the scroll direction over the switcher.";
*/
/*
  @widget-preset-field
  preset = "workspaceSwitcher"; name = "showSpecialWorkspaces";
  widget = "switch";
  label = "Show scratchpads"; description = "List special workspaces last.";
*/
/*
  @widget-preset-field
  preset = "workspaceSwitcher"; name = "showWorkspaceApps";
  widget = "switch";
  label = "Show apps"; description = "Show app icons inside each workspace.";
*/
/*
  @widget-preset-field
  preset = "workspaceSwitcher"; name = "showWorkspaceName";
  widget = "switch";
  label = "Names"; description = "Show workspace names.";
*/
/*
  @widget-preset-field
  preset = "workspaceSwitcher"; name = "showWorkspacePadding";
  widget = "switch";
  label = "Pad short lists"; description = "Fill the switcher with empty placeholders up to the minimum count.";
*/
/*
  @widget-preset-field
  preset = "workspaceSwitcher"; name = "workspaceActiveAppHighlightEnabled";
  widget = "switch";
  label = "Highlight focused app"; description = "Highlight the focused app icon.";
*/
/*
  @widget-preset-field
  preset = "workspaceSwitcher"; name = "workspaceAppIconSizeOffset";
  widget = "spin"; min = 0; max = 10; unit = "px";
  label = "Icon size"; description = "Grow or shrink workspace app icons.";
*/
/*
  @widget-preset-field
  preset = "workspaceSwitcher"; name = "workspaceDragReorder";
  widget = "switch";
  label = "Drag to reorder"; description = "Reorder workspaces by dragging.";
*/
/*
  @widget-preset-field
  preset = "workspaceSwitcher"; name = "workspaceFollowFocus";
  widget = "switch";
  label = "Follow display focus"; description = "List workspaces from whichever display has focus.";
*/
/*
  @widget-preset-field
  preset = "workspaceSwitcher"; name = "workspaceIndicatorRoundness";
  widget = "spin"; min = -1; max = 100;
  label = "Indicator roundness"; description = "Corner roundness of the indicator; -1 follows the theme.";
*/
/*
  @widget-preset-field
  preset = "workspaceSwitcher"; name = "workspaceIndicatorStyle";
  widget = "dropdown"; choices = [ "pills" "dots" "lines" "cards" ];
  label = "Style"; description = "Shape drawn for each workspace.";
*/
/*
  @widget-preset-field
  preset = "workspaceSwitcher"; name = "workspaceUnfocusedAppsFullOpacity";
  widget = "switch";
  label = "Don't dim unfocused apps"; description = "Show icons of unfocused apps at full opacity.";
*/
/*
  @widget-preset-field
  preset = "workspaceSwitcher"; name = "workspaceUnfocusedMonitorSeparateAppearance";
  widget = "switch";
  label = "Separate appearance"; description = "Use different colors on unfocused displays.";
*/
/*
  @widget-preset-field
  preset = "workspaceSwitcher"; name = "workspaceFocusedBorderEnabled";
  widget = "switch";
  label = "Focused border"; description = "Draw a border around the focused workspace.";
*/
/*
  @widget-preset-field
  preset = "workspaceSwitcher"; name = "workspaceFocusedBorderColor";
  widget = "dropdown"; choices = [ "surfaceText" "primary" "primaryContainer" "secondary" "secondaryContainer" "tertiary" "tertiaryContainer" "custom" ];
  label = "Focused border color"; description = "Theme role used for the focused workspace border.";
*/
/*
  @widget-preset-field
  preset = "workspaceSwitcher"; name = "workspaceFocusedBorderCustomColor";
  widget = "color";
  label = "Custom focused border color"; description = "Border color used when the focused border color is custom.";
*/
/*
  @widget-preset-field
  preset = "workspaceSwitcher"; name = "workspaceFocusedBorderThickness";
  widget = "spin"; min = 1; max = 10; unit = "px";
  label = "Focused border thickness"; description = "Width of the focused workspace border.";
*/
/*
  @widget-preset-field
  preset = "workspaceSwitcher"; name = "workspaceFocusedCustomColor";
  widget = "color";
  label = "Custom focused color"; description = "Focused color used when the focused color mode is custom.";
*/
/*
  @widget-preset-field
  preset = "workspaceSwitcher"; name = "workspaceOccupiedColorMode";
  widget = "dropdown"; choices = [ "none" "primary" "primaryContainer" "sec" "secondaryContainer" "tertiary" "tertiaryContainer" "s" "sc" "sch" "schh" "custom" ];
  label = "Occupied color"; description = "Theme role used for occupied workspaces.";
*/
/*
  @widget-preset-field
  preset = "workspaceSwitcher"; name = "workspaceOccupiedCustomColor";
  widget = "color";
  label = "Custom occupied color"; description = "Occupied color used when the occupied color mode is custom.";
*/
/*
  @widget-preset-field
  preset = "workspaceSwitcher"; name = "workspaceUnfocusedColorMode";
  widget = "dropdown"; choices = [ "default" "surfaceText" "primary" "secondary" "tertiary" "s" "sc" "sch" "schh" "custom" ];
  label = "Unfocused color"; description = "Theme role used for unfocused workspaces.";
*/
/*
  @widget-preset-field
  preset = "workspaceSwitcher"; name = "workspaceUnfocusedCustomColor";
  widget = "color";
  label = "Custom unfocused color"; description = "Unfocused color used when the unfocused color mode is custom.";
*/
/*
  @widget-preset-field
  preset = "workspaceSwitcher"; name = "workspaceUrgentColorMode";
  widget = "dropdown"; choices = [ "default" "primary" "primaryContainer" "secondary" "secondaryContainer" "tertiary" "tertiaryContainer" "s" "sc" "sch" "custom" ];
  label = "Urgent color"; description = "Theme role used for urgent workspaces.";
*/
/*
  @widget-preset-field
  preset = "workspaceSwitcher"; name = "workspaceUrgentCustomColor";
  widget = "color";
  label = "Custom urgent color"; description = "Urgent color used when the urgent color mode is custom.";
*/
/*
  @widget-preset-field
  preset = "workspaceSwitcher"; name = "workspaceColorMode";
  widget = "dropdown"; choices = [ "default" "primaryContainer" "secondary" "secondaryContainer" "tertiary" "tertiaryContainer" "s" "sc" "sch" "schh" "none" "custom" ];
  label = "Focused color"; description = "Theme role used for the focused workspace.";
*/
/*
  @widget-preset-field
  preset = "workspaceSwitcher"; name = "workspaceUnfocusedMonitorColorMode";
  widget = "dropdown"; choices = [ "default" "primaryContainer" "secondary" "secondaryContainer" "tertiary" "tertiaryContainer" "s" "sc" "sch" "schh" "none" "custom" ];
  label = "Unfocused display focused color"; description = "Theme role used for the focused workspace on unfocused displays.";
*/
/*
  @widget-preset-field
  preset = "workspaceSwitcher"; name = "workspaceUnfocusedMonitorFocusedCustomColor";
  widget = "color";
  label = "Custom unfocused display focused color"; description = "Color used when the unfocused display focused color is custom.";
*/
/*
  @widget-preset-field
  preset = "workspaceSwitcher"; name = "workspaceUnfocusedMonitorOccupiedColorMode";
  widget = "dropdown"; choices = [ "none" "primary" "primaryContainer" "sec" "secondaryContainer" "tertiary" "tertiaryContainer" "s" "sc" "sch" "schh" "custom" ];
  label = "Unfocused display occupied color"; description = "Theme role used for occupied workspaces on unfocused displays.";
*/
/*
  @widget-preset-field
  preset = "workspaceSwitcher"; name = "workspaceUnfocusedMonitorOccupiedCustomColor";
  widget = "color";
  label = "Custom unfocused display occupied color"; description = "Color used when the unfocused display occupied color is custom.";
*/
/*
  @widget-preset-field
  preset = "workspaceSwitcher"; name = "workspaceUnfocusedMonitorUnfocusedColorMode";
  widget = "dropdown"; choices = [ "default" "surfaceText" "primary" "secondary" "tertiary" "s" "sc" "sch" "schh" "custom" ];
  label = "Unfocused display unfocused color"; description = "Theme role used for unfocused workspaces on unfocused displays.";
*/
/*
  @widget-preset-field
  preset = "workspaceSwitcher"; name = "workspaceUnfocusedMonitorUnfocusedCustomColor";
  widget = "color";
  label = "Custom unfocused display unfocused color"; description = "Color used when the unfocused display unfocused color is custom.";
*/
/*
  @widget-preset-field
  preset = "workspaceSwitcher"; name = "workspaceUnfocusedMonitorUrgentColorMode";
  widget = "dropdown"; choices = [ "default" "primary" "primaryContainer" "secondary" "secondaryContainer" "tertiary" "tertiaryContainer" "s" "sc" "sch" "custom" ];
  label = "Unfocused display urgent color"; description = "Theme role used for urgent workspaces on unfocused displays.";
*/
/*
  @widget-preset-field
  preset = "workspaceSwitcher"; name = "workspaceUnfocusedMonitorUrgentCustomColor";
  widget = "color";
  label = "Custom unfocused display urgent color"; description = "Color used when the unfocused display urgent color is custom.";
*/
/*
  @widget-preset-field
  preset = "workspaceSwitcher"; name = "workspaceUnfocusedMonitorBorderEnabled";
  widget = "switch";
  label = "Unfocused display focused border"; description = "Draw a border around the focused workspace on unfocused displays.";
*/
/*
  @widget-preset-field
  preset = "workspaceSwitcher"; name = "workspaceUnfocusedMonitorBorderColor";
  widget = "dropdown"; choices = [ "surfaceText" "primary" "primaryContainer" "secondary" "secondaryContainer" "tertiary" "tertiaryContainer" "custom" ];
  label = "Unfocused display border color"; description = "Theme role used for the unfocused display border.";
*/
/*
  @widget-preset-field
  preset = "workspaceSwitcher"; name = "workspaceUnfocusedMonitorBorderCustomColor";
  widget = "color";
  label = "Custom unfocused display border color"; description = "Border color used when the unfocused display border color is custom.";
*/
/*
  @widget-preset-field
  preset = "workspaceSwitcher"; name = "workspaceUnfocusedMonitorBorderThickness";
  widget = "spin"; min = 1; max = 10; unit = "px";
  label = "Unfocused display border thickness"; description = "Width of the unfocused display border.";
*/

/*
  @widget-preset
  id = "focusedWindow"; label = "Focused window";
  description = "Display currently focused application title";
  icon = "focus-windows-symbolic"; sections = [ "left" "right" "center" "dock" ];
  hasSettings = true;
  defaults.focusedWindowCompactMode = false;
  defaults.focusedWindowShowIcon = true;
  defaults.focusedWindowSize = 1;
*/
/*
  @widget-preset-field
  preset = "focusedWindow"; name = "focusedWindowCompactMode";
  widget = "switch"; label = "Compact mode";
*/
/*
  @widget-preset-field
  preset = "focusedWindow"; name = "focusedWindowShowIcon";
  widget = "switch"; label = "Show icon";
*/
/*
  @widget-preset-field
  preset = "focusedWindow"; name = "focusedWindowSize";
  widget = "spin"; min = 0; max = 3; label = "Size";
*/
/*
  @widget-preset
  id = "runningApps"; label = "Running apps";
  description = "Shows all running applications with focus indication";
  icon = "view-app-grid-symbolic"; sections = [ "left" "right" "center" "dock" ];
  hasSettings = true;
*/
/*
  @widget-preset-field
  preset = "runningApps"; name = "runningAppsCompactMode";
  widget = "switch"; label = "Compact mode";
*/
/*
  @widget-preset-field
  preset = "runningApps"; name = "runningAppsGroupByApp";
  widget = "switch"; label = "Group by app";
*/
/*
  @widget-preset-field
  preset = "runningApps"; name = "runningAppsCurrentWorkspace";
  widget = "switch"; label = "Current workspace";
  description = "Only show apps from the active workspace.";
*/
/*
  @widget-preset-field
  preset = "runningApps"; name = "runningAppsCurrentMonitor";
  widget = "switch"; label = "Current display";
  description = "Only show apps from the same monitor.";
*/
/*
  @widget-preset
  id = "appsDock"; label = "Apps dock";
  description = "Pinned and running apps with drag-and-drop";
  icon = "view-list-symbolic"; sections = [ "left" "right" "center" "dock" ];
  hasSettings = true;
*/
/*
  @widget-preset-field
  preset = "appsDock"; name = "barMaxVisibleApps";
  widget = "spin"; min = 0; max = 20; label = "Max visible apps";
  description = "0 shows every pinned app.";
*/
/*
  @widget-preset-field
  preset = "appsDock"; name = "barShowOverflowBadge";
  widget = "switch"; label = "Show overflow badge";
*/
/*
  @widget-preset-field
  preset = "appsDock"; name = "appsDockIconSizePercentage";
  widget = "spin"; min = 50; max = 200; unit = "%"; label = "Icon size";
*/
/*
  @widget-preset-field
  preset = "appsDock"; name = "appsDockSpacing";
  widget = "spin"; min = 0; max = 32; unit = "px";
  label = "Spacing"; description = "Gap between dock icons.";
*/
/*
  @widget-preset-field
  preset = "appsDock"; name = "barMaxVisibleRunningApps";
  widget = "spin"; min = 0; max = 30;
  label = "Max running apps"; description = "Running apps shown before overflow. 0 shows every app.";
*/
/*
  @widget-preset-field
  preset = "appsDock"; name = "launcherEnabled";
  widget = "switch";
  label = "Show launcher"; description = "Show the launcher button inside the dock.";
*/
/*
  @widget-preset-field
  preset = "appsDock"; name = "launcherLogoBrightness";
  widget = "slider"; min = 0.0; max = 1.0; step = 0.05;
  label = "Logo brightness"; description = "Brightness of the launcher logo color.";
*/
/*
  @widget-preset-field
  preset = "appsDock"; name = "launcherLogoColorOverride";
  widget = "text";
  label = "Logo color override"; description = "Color role name or hex value; empty follows the theme.";
*/
/*
  @widget-preset-field
  preset = "appsDock"; name = "launcherLogoContrast";
  widget = "slider"; min = 0.0; max = 2.0; step = 0.05;
  label = "Logo contrast"; description = "Contrast of the launcher logo color.";
*/
/*
  @widget-preset-field
  preset = "appsDock"; name = "launcherLogoCustomPath";
  widget = "text";
  label = "Custom logo path"; description = "Image used when the logo mode is custom.";
*/
/*
  @widget-preset-field
  preset = "appsDock"; name = "launcherLogoMode";
  widget = "dropdown"; choices = [ "apps" "os" "dank" "compositor" "custom" ];
  label = "Logo"; description = "Which artwork the dock launcher shows.";
*/
/*
  @widget-preset-field
  preset = "appsDock"; name = "launcherLogoSizeOffset";
  widget = "spin"; min = -12; max = 12; unit = "px";
  label = "Logo size offset"; description = "Grow or shrink the dock launcher logo.";
*/
/*
  @widget-preset-field
  preset = "appsDock"; name = "runningAppsCompactMode";
  widget = "switch";
  label = "Compact mode"; description = "Draw running apps as compact icons.";
*/
/*
  @widget-preset-field
  preset = "appsDock"; name = "runningAppsCurrentWorkspace";
  widget = "switch";
  label = "Current workspace"; description = "Only show apps from the active workspace.";
*/
/*
  @widget-preset-field
  preset = "appsDock"; name = "appsDockActiveColorMode";
  widget = "dropdown"; choices = [ "primary" "secondary" "primaryContainer" "error" "success" ];
  label = "Active color"; description = "Theme role used for the active app indicator.";
*/
/*
  @widget-preset-field
  preset = "appsDock"; name = "appsDockColorizeActive";
  widget = "switch";
  label = "Colorize active"; description = "Color the active app icon.";
*/
/*
  @widget-preset-field
  preset = "appsDock"; name = "appsDockEnlargeOnHover";
  widget = "switch";
  label = "Magnification"; description = "Enlarge icons near the cursor.";
*/
/*
  @widget-preset-field
  preset = "appsDock"; name = "appsDockEnlargePercentage";
  widget = "spin"; min = 100; max = 150; step = 5; unit = "%";
  label = "Magnification size"; description = "How large hovered icons grow.";
*/
/*
  @widget-preset-field
  preset = "appsDock"; name = "appsDockHideIndicators";
  widget = "switch";
  label = "Hide indicators"; description = "Hide the running app indicator dots.";
*/

/*
  @widget-preset
  id = "island"; label = "Island";
  description = "Live activities that grow out of the bar";
  icon = "view-pin-symbolic"; sections = [ "left" "right" "center" ];
  hasSettings = true;
  defaults.islandFloating = false;
  defaults.islandPlacement = "edge";
  defaults.islandReserveThickness = 40;
*/
/*
  @widget-preset-field
  preset = "island"; name = "islandFloating";
  widget = "switch"; label = "Floating";
  description = "Detach the island from the bar edge.";
*/
/*
  @widget-preset-field
  preset = "island"; name = "islandPlacement";
  widget = "dropdown"; choices = [ "edge" "free" ]; label = "Placement";
*/
/*
  @widget-preset-field
  preset = "island"; name = "islandReserveThickness";
  widget = "spin"; min = 0; max = 200; unit = "px"; label = "Reserve thickness";
*/
/*
  @widget-preset-field
  preset = "island"; name = "islandAlongOffset";
  widget = "spin"; min = -600; max = 600; unit = "px";
  label = "Along offset"; description = "Shift the island along the screen edge.";
*/
/*
  @widget-preset-field
  preset = "island"; name = "islandBatteryStyle";
  widget = "dropdown"; choices = [ "solid" "outline" "ring" "duo" ];
  label = "Battery style"; description = "Battery meter drawn on the home face.";
*/
/*
  @widget-preset-field
  preset = "island"; name = "islandChargingPulse";
  widget = "switch";
  label = "Charging pulse"; description = "Pulse the island when the charger is connected or removed.";
*/
/*
  @widget-preset-field
  preset = "island"; name = "islandCompactThickness";
  widget = "spin"; min = 24; max = 72; unit = "px";
  label = "Compact thickness"; description = "Island thickness in compact mode.";
*/
/*
  @widget-preset-field
  preset = "island"; name = "islandFreeEdgeMargin";
  widget = "spin"; min = 0; max = 64; unit = "px";
  label = "Edge margin"; description = "Gap kept from the display edge when free floating.";
*/
/*
  @widget-preset-field
  preset = "island"; name = "islandFreeIcon";
  widget = "text";
  label = "Icon"; description = "Icon name drawn inside a free floating island.";
*/
/*
  @widget-preset-field
  preset = "island"; name = "islandFreeIconColor";
  widget = "text";
  label = "Icon color"; description = "Color role name or hex value; empty follows the theme.";
*/
/*
  @widget-preset-field
  preset = "island"; name = "islandFreeIconMode";
  widget = "dropdown"; choices = [ "icon" "os" "dank" "compositor" "custom" ];
  label = "Icon mode"; description = "Which artwork the free floating island shows.";
*/
/*
  @widget-preset-field
  preset = "island"; name = "islandFreeIconPath";
  widget = "text";
  label = "Icon path"; description = "Image used when the free island icon mode is custom.";
*/
/*
  @widget-preset-field
  preset = "island"; name = "islandFreeIdleDelay";
  widget = "spin"; min = 0; max = 30000; step = 500; unit = "ms";
  label = "Idle delay"; description = "Time before the free floating island fades. 0 disables fading.";
*/
/*
  @widget-preset-field
  preset = "island"; name = "islandFreeIdleOpacity";
  widget = "slider"; min = 0.0; max = 1.0; step = 0.05;
  label = "Idle opacity"; description = "Opacity of the free floating island while idle.";
*/
/*
  @widget-preset-field
  preset = "island"; name = "islandFreeIdleScale";
  widget = "slider"; min = 0.2; max = 1.0; step = 0.01;
  label = "Idle size"; description = "How far the free floating island shrinks while idle.";
*/
/*
  @widget-preset-field
  preset = "island"; name = "islandFreeSize";
  widget = "spin"; min = 24; max = 160; unit = "px";
  label = "Size"; description = "Diameter of a free floating island.";
*/
/*
  @widget-preset-field
  preset = "island"; name = "islandHighContrast";
  widget = "switch";
  label = "High contrast"; description = "Draw the island with a higher contrast outline.";
*/
/*
  @widget-preset-field
  preset = "island"; name = "islandHomeBrightnessDisplay";
  widget = "dropdown"; choices = [ "icon" "percentage" "both" ];
  label = "Brightness style"; description = "How the home face shows brightness.";
*/
/*
  @widget-preset-field
  preset = "island"; name = "islandHomeClockDisplay";
  widget = "dropdown"; choices = [ "time" "date" "both" ];
  label = "Clock style"; description = "How the home face shows the clock.";
*/
/*
  @widget-preset-field
  preset = "island"; name = "islandHomeCompactTight";
  widget = "switch";
  label = "Tight compact"; description = "Use the narrower compact home face.";
*/
/*
  @widget-preset-field
  preset = "island"; name = "islandHomeStatusContent";
  widget = "dropdown"; choices = [ "battery" "connectivity" ];
  label = "Status"; description = "Status group shown on the home face.";
*/
/*
  @widget-preset-field
  preset = "island"; name = "islandHomeVolumeDisplay";
  widget = "dropdown"; choices = [ "icon" "percentage" "both" ];
  label = "Volume style"; description = "How the home face shows volume.";
*/
/*
  @widget-preset-field
  preset = "island"; name = "islandHoverCloseDelay";
  widget = "spin"; min = 0; max = 1000; step = 10; unit = "ms";
  label = "Hide delay"; description = "Delay before the hovered island closes.";
*/
/*
  @widget-preset-field
  preset = "island"; name = "islandHoverOpenDelay";
  widget = "spin"; min = 0; max = 1000; step = 10; unit = "ms";
  label = "Open delay"; description = "Delay before the hovered island opens.";
*/
/*
  @widget-preset-field
  preset = "island"; name = "islandInteractionMode";
  widget = "dropdown"; choices = [ "click" "hybrid" ];
  label = "Expansion mode"; description = "Click expands on click only, hybrid also peeks on hover.";
*/
/*
  @widget-preset-field
  preset = "island"; name = "islandMediaAutoSwitch";
  widget = "switch";
  label = "Switch to media"; description = "Switch the compact face to media when playback starts.";
*/
/*
  @widget-preset-field
  preset = "island"; name = "islandMediaClockVisible";
  widget = "switch";
  label = "Keep clock with media"; description = "Keep the clock visible on the media face.";
*/
/*
  @widget-preset-field
  preset = "island"; name = "islandMediaLyrics";
  widget = "switch";
  label = "Lyrics"; description = "Show synced lyrics on the media face.";
*/
/*
  @widget-preset-field
  preset = "island"; name = "islandNotch";
  widget = "switch";
  label = "Notch"; description = "Merge the island with the screen edge as a notch.";
*/
/*
  @widget-preset-field
  preset = "island"; name = "islandNotificationBadgeClearOnOpen";
  widget = "switch";
  label = "Clear badge on open"; description = "Clear the notification badge when the center opens.";
*/
/*
  @widget-preset-field
  preset = "island"; name = "islandNotificationExpand";
  widget = "switch";
  label = "Expand by default"; description = "Show arriving notifications expanded.";
*/
/*
  @widget-preset-field
  preset = "island"; name = "islandNotificationPopups";
  widget = "switch";
  label = "Standard popups"; description = "Show arriving notifications as regular popups instead of inside the island.";
*/
/*
  @widget-preset-field
  preset = "island"; name = "islandOuterGap";
  widget = "spin"; min = 0; max = 48; unit = "px";
  label = "Outer gap"; description = "Gap between the screen edge and the island.";
*/
/*
  @widget-preset-field
  preset = "island"; name = "islandPalette";
  widget = "dropdown"; choices = [ "default" "bright" "dim" ];
  label = "Palette"; description = "Surface tone used by the island.";
*/
/*
  @widget-preset-field
  preset = "island"; name = "islandRouteLauncher";
  widget = "switch";
  label = "Launcher"; description = "Open launcher inside the island instead of its bar popout.";
*/
/*
  @widget-preset-field
  preset = "island"; name = "islandRouteControlCenter";
  widget = "switch";
  label = "Control Center"; description = "Open control center inside the island instead of its bar popout.";
*/
/*
  @widget-preset-field
  preset = "island"; name = "islandRouteNotificationCenter";
  widget = "switch";
  label = "Notification Center"; description = "Open notification center inside the island instead of its bar popout.";
*/
/*
  @widget-preset-field
  preset = "island"; name = "islandRouteClipboard";
  widget = "switch";
  label = "Clipboard"; description = "Open clipboard inside the island instead of its bar popout.";
*/
/*
  @widget-preset-field
  preset = "island"; name = "islandRoutePowerMenu";
  widget = "switch";
  label = "Power menu"; description = "Open power menu inside the island instead of its bar popout.";
*/
/*
  @widget-preset-field
  preset = "island"; name = "islandRouteDash";
  widget = "switch";
  label = "Dashboard"; description = "Open dashboard inside the island instead of its bar popout.";
*/
/*
  @widget-preset-field
  preset = "island"; name = "islandRouteMedia";
  widget = "switch";
  label = "Media"; description = "Open media inside the island instead of its bar popout.";
*/
/*
  @widget-preset-field
  preset = "island"; name = "islandRouteWeather";
  widget = "switch";
  label = "Weather"; description = "Open weather inside the island instead of its bar popout.";
*/
/*
  @widget-preset-field
  preset = "island"; name = "islandRouteWallpaper";
  widget = "switch";
  label = "Wallpapers"; description = "Open wallpapers inside the island instead of its bar popout.";
*/
/*
  @widget-preset-field
  preset = "island"; name = "islandSatelliteBackground";
  widget = "switch";
  label = "Background"; description = "Draw a background behind the satellites.";
*/
/*
  @widget-preset-field
  preset = "island"; name = "islandSatelliteFollowInterfaceStyle";
  widget = "switch";
  label = "Follow interface opacity"; description = "Let satellites follow the global interface opacity.";
*/
/*
  @widget-preset-field
  preset = "island"; name = "islandSatelliteGap";
  widget = "spin"; min = 0; max = 48; unit = "px";
  label = "Gap"; description = "Gap between the island and its satellites.";
*/
/*
  @widget-preset-field
  preset = "island"; name = "islandSatelliteGothCorners";
  widget = "switch";
  label = "Goth corners"; description = "Square off the satellite corners.";
*/
/*
  @widget-preset-field
  preset = "island"; name = "islandSatellitePosition";
  widget = "dropdown"; choices = [ "island" "edges" ];
  label = "Position"; description = "Place satellites near the island or at the display edges.";
*/
/*
  @widget-preset-field
  preset = "island"; name = "islandSatelliteTransparency";
  widget = "slider"; min = 0.0; max = 1.0; step = 0.05;
  label = "Opacity"; description = "Opacity of the satellite background.";
*/
/*
  @widget-preset-field
  preset = "island"; name = "islandSatellitesEnabled";
  widget = "switch";
  label = "Show"; description = "Show widget satellites next to the island.";
*/
/*
  @widget-preset-field
  preset = "island"; name = "islandSharedRouting";
  widget = "dropdown"; choices = [ "normal" "always" "last-used" ];
  label = "Shared shortcuts"; description = "Which island handles global shortcuts.";
*/
/*
  @widget-preset-field
  preset = "island"; name = "islandSpringDamping";
  widget = "spin"; min = 10; max = 100; step = 1;
  label = "Spring damping"; description = "Damping of the island spring animation.";
*/
/*
  @widget-preset-field
  preset = "island"; name = "islandSpringMass";
  widget = "slider"; min = 0.25; max = 3.0; step = 0.05;
  label = "Spring mass"; description = "Mass of the island spring animation.";
*/
/*
  @widget-preset-field
  preset = "island"; name = "islandSpringStiffness";
  widget = "spin"; min = 100; max = 1200; step = 10;
  label = "Spring stiffness"; description = "Stiffness of the island spring animation.";
*/
/*
  @widget-preset-field
  preset = "island"; name = "islandSystemOsd";
  widget = "switch";
  label = "System OSD"; description = "Show volume and brightness changes inside the island.";
*/
/*
  @widget-preset-field
  preset = "island"; name = "islandUseOverlayLayer";
  widget = "switch";
  label = "Overlay layer"; description = "Draw the island on the overlay layer so windows can overlap it.";
*/
/*
  @widget-preset-field
  preset = "island"; name = "islandWidgetBackground";
  widget = "switch";
  label = "Background"; description = "Draw the bar widget background behind the compact face.";
*/

/*
  @widget-preset
  id = "clock"; label = "Clock";
  description = "Current time and date display";
  icon = "clock-applet-symbolic"; sections = [ "left" "right" "center" "dock" ];
  hasSettings = true;
  defaults.clockDateOrder = "timeFirst";
*/
/*
  @widget-preset-field
  preset = "clock"; name = "clockCompactMode";
  widget = "switch"; label = "Compact mode";
*/
/*
  @widget-preset-field
  preset = "clock"; name = "clockDateOrder";
  widget = "dropdown"; choices = [ "timeFirst" "dateFirst" ]; label = "Order";
  description = "Whether the time or the date comes first.";
*/
/*
  @widget-preset-field
  preset = "clock"; name = "clockNotificationBadge";
  widget = "switch"; label = "Notification badge";
  description = "Show the unread notification count next to the time.";
*/
/*
  @widget-preset
  id = "worldClock"; label = "World clock";
  description = "Multiple cities and time zones from the World Clock plugin";
  icon = "public"; sections = [ "left" "right" "center" "dock" ];
  hasSettings = false;
*/
/*
  @widget-preset
  id = "dankCalendarAgenda"; label = "Calendar agenda";
  description = "Dux Calendar next event and agenda";
  icon = "calendar_today"; sections = [ "left" "right" "center" "dock" ];
  hasSettings = false;
*/
/*
  @widget-preset
  id = "weather"; label = "Weather";
  description = "Current weather conditions and temperature";
  icon = "weather-clear-symbolic"; sections = [ "left" "right" "center" "dock" ];
  hasSettings = false;
*/
/*
  @widget-preset
  id = "music"; label = "Media";
  description = "Now playing and media controls";
  icon = "audio-x-generic-symbolic"; sections = [ "left" "right" "center" "dock" ];
  hasSettings = true;
  defaults.mediaStyle = "controls";
  defaults.audioScrollMode = "volume";
*/
/*
  @widget-preset-field
  preset = "music"; name = "mediaStyle";
  widget = "dropdown"; choices = [ "controls" "activity" ]; label = "Style";
*/
/*
  @widget-preset-field
  preset = "music"; name = "mediaSize";
  widget = "spin"; min = 0; max = 3; label = "Size";
*/
/*
  @widget-preset-field
  preset = "music"; name = "audioScrollMode";
  widget = "dropdown"; choices = [ "volume" "song" "nothing" ]; label = "Scroll wheel";
*/
/*
  @widget-preset-field
  preset = "music"; name = "mediaShowCoverArt";
  widget = "switch"; label = "Cover art";
*/
/*
  @widget-preset-field
  preset = "music"; name = "mediaAdaptiveWidthEnabled";
  widget = "switch";
  label = "Adaptive width"; description = "Fit the song title instead of keeping a fixed width.";
*/
/*
  @widget-preset-field
  preset = "music"; name = "mediaShowLyrics";
  widget = "switch";
  label = "Lyrics"; description = "Show the line being sung while synced lyrics are available.";
*/

/*
  @widget-preset
  id = "clipboard"; label = "Clipboard manager";
  description = "Access clipboard history";
  icon = "edit-paste-symbolic"; sections = [ "left" "right" "center" "dock" ];
  hasSettings = false;
*/
/*
  @widget-preset
  id = "cpuUsage"; label = "CPU usage";
  description = "CPU usage indicator";
  icon = "cpu-symbolic"; sections = [ "left" "right" "center" "dock" ];
  hasSettings = true;
  defaults.minimumWidth = true;
*/
/*
  @widget-preset-field
  preset = "cpuUsage"; name = "minimumWidth";
  widget = "switch"; label = "Force padding";
  description = "Keep a dynamic minimum width.";
*/
/*
  @widget-preset
  id = "memUsage"; label = "Memory usage";
  description = "Memory usage indicator";
  icon = "memory-symbolic"; sections = [ "left" "right" "center" "dock" ];
  hasSettings = true;
  defaults.minimumWidth = true;
*/
/*
  @widget-preset-field
  preset = "memUsage"; name = "minimumWidth";
  widget = "switch"; label = "Force padding";
*/
/*
  @widget-preset-field
  preset = "memUsage"; name = "showSwap";
  widget = "switch"; label = "Show swap";
*/
/*
  @widget-preset-field
  preset = "memUsage"; name = "showInGb";
  widget = "switch"; label = "Show in GB";
*/
/*
  @widget-preset
  id = "diskUsage"; label = "Disk usage";
  description = "Percentage";
  icon = "drive-harddisk-symbolic"; sections = [ "left" "right" "center" "dock" ];
  hasSettings = true;
  defaults.mountPath = "/";
  defaults.showMountPath = true;
*/
/*
  @widget-preset-field
  preset = "diskUsage"; name = "minimumWidth";
  widget = "switch"; label = "Force padding";
*/
/*
  @widget-preset-field
  preset = "diskUsage"; name = "mountPath";
  widget = "text"; label = "Mount";
  description = "Filesystem path to report.";
*/
/*
  @widget-preset-field
  preset = "diskUsage"; name = "diskUsageMode";
  widget = "spin"; min = 0; max = 3; label = "Disk usage format";
*/
/*
  @widget-preset-field
  preset = "diskUsage"; name = "showMountPath";
  widget = "switch"; label = "Show mount path";
*/
/*
  @widget-preset
  id = "cpuTemp"; label = "CPU temperature";
  description = "CPU temperature display";
  icon = "temp-symbolic"; sections = [ "left" "right" "center" "dock" ];
  hasSettings = true;
  defaults.minimumWidth = true;
*/
/*
  @widget-preset-field
  preset = "cpuTemp"; name = "minimumWidth";
  widget = "switch"; label = "Force padding";
*/
/*
  @widget-preset
  id = "gpuTemp"; label = "GPU temperature";
  description = "GPU temperature display";
  icon = "sensors-temperature-symbolic"; sections = [ "left" "right" "center" "dock" ];
  hasSettings = true;
  defaults.minimumWidth = true;
  defaults.selectedGpuIndex = 0;
*/
/*
  @widget-preset-field
  preset = "gpuTemp"; name = "minimumWidth";
  widget = "switch"; label = "Force padding";
*/
/*
  @widget-preset-field
  preset = "gpuTemp"; name = "selectedGpuIndex";
  widget = "spin"; min = 0; max = 8; label = "GPU";
  description = "Index of the GPU to monitor.";
*/
/*
  @widget-preset-field
  preset = "gpuTemp"; name = "pciId";
  widget = "text"; label = "PCI id";
  description = "Stable GPU identifier; set automatically when the index changes.";
*/
/*
  @widget-preset
  id = "systemTray"; label = "System tray";
  description = "System notification area icons";
  icon = "notifications-symbolic"; sections = [ "left" "right" "center" "dock" ];
  hasSettings = true;
  defaults.trayPopupSingleLine = true;
  defaults.trayAutoOverflow = true;
*/
/*
  @widget-preset-field
  preset = "systemTray"; name = "trayUseInlineExpansion";
  widget = "switch"; label = "Use inline expansion";
  description = "Hidden icons expand in place instead of in a popup.";
*/
/*
  @widget-preset-field
  preset = "systemTray"; name = "trayPopupSingleLine";
  widget = "switch"; label = "Single-line popup";
*/
/*
  @widget-preset-field
  preset = "systemTray"; name = "trayAutoOverflow";
  widget = "switch"; label = "Auto overflow";
*/
/*
  @widget-preset-field
  preset = "systemTray"; name = "trayMaxVisibleItems";
  widget = "spin"; min = 0; max = 20; label = "Max visible";
  description = "0 lets the tray decide.";
*/
/*
  @widget-preset-field
  preset = "systemTray"; name = "trayIconSpacing";
  widget = "spin"; min = 0; max = 20; unit = "px"; label = "Icon spacing";
*/
/*
  @widget-preset
  id = "privacyIndicator"; label = "Privacy indicator";
  description = "Shows when microphone, camera, or screen sharing is active";
  icon = "media-record-symbolic"; sections = [ "left" "right" "center" "dock" ];
  hasSettings = true;
*/
/*
  @widget-preset-field
  preset = "privacyIndicator"; name = "privacyShowMicIcon";
  widget = "switch"; label = "Microphone";
*/
/*
  @widget-preset-field
  preset = "privacyIndicator"; name = "privacyShowCameraIcon";
  widget = "switch"; label = "Camera";
*/
/*
  @widget-preset-field
  preset = "privacyIndicator"; name = "privacyShowScreenShareIcon";
  widget = "switch"; label = "Screen sharing";
*/
/*
  @widget-preset
  id = "controlCenterButton"; label = "Control Center";
  description = "Access to system controls and settings";
  icon = "preferences-system-symbolic"; sections = [ "left" "right" "center" "dock" ];
  hasSettings = true;
  defaults.showAudioPercent = true;
  defaults.showBatteryIcon = true;
  defaults.showBrightnessIcon = true;
  defaults.showBrightnessPercent = true;
  defaults.showDoNotDisturbIcon = true;
  defaults.showIdleInhibitorIcon = true;
  defaults.showMicIcon = true;
  defaults.showMicPercent = true;
*/
/*
  @widget-preset-field
  preset = "controlCenterButton"; name = "showNetworkIcon";
  widget = "switch"; label = "Show network icon";
*/
/*
  @widget-preset-field
  preset = "controlCenterButton"; name = "showVpnIcon";
  widget = "switch"; label = "Show VPN icon";
*/
/*
  @widget-preset-field
  preset = "controlCenterButton"; name = "showBluetoothIcon";
  widget = "switch"; label = "Show Bluetooth icon";
*/
/*
  @widget-preset-field
  preset = "controlCenterButton"; name = "showAudioIcon";
  widget = "switch"; label = "Show audio icon";
*/
/*
  @widget-preset-field
  preset = "controlCenterButton"; name = "showAudioPercent";
  widget = "switch"; label = "Show audio percent";
*/
/*
  @widget-preset-field
  preset = "controlCenterButton"; name = "showMicIcon";
  widget = "switch"; label = "Show microphone icon";
*/
/*
  @widget-preset-field
  preset = "controlCenterButton"; name = "showMicPercent";
  widget = "switch"; label = "Show microphone percent";
*/
/*
  @widget-preset-field
  preset = "controlCenterButton"; name = "showBrightnessIcon";
  widget = "switch"; label = "Show brightness icon";
*/
/*
  @widget-preset-field
  preset = "controlCenterButton"; name = "showBrightnessPercent";
  widget = "switch"; label = "Show brightness percent";
*/
/*
  @widget-preset-field
  preset = "controlCenterButton"; name = "showBatteryIcon";
  widget = "switch"; label = "Show battery icon";
*/
/*
  @widget-preset-field
  preset = "controlCenterButton"; name = "showPrinterIcon";
  widget = "switch"; label = "Show printer icon";
*/
/*
  @widget-preset-field
  preset = "controlCenterButton"; name = "showScreenSharingIcon";
  widget = "switch"; label = "Show screen sharing icon";
*/
/*
  @widget-preset-field
  preset = "controlCenterButton"; name = "showIdleInhibitorIcon";
  widget = "switch"; label = "Show idle inhibitor icon";
*/
/*
  @widget-preset-field
  preset = "controlCenterButton"; name = "showDoNotDisturbIcon";
  widget = "switch"; label = "Show do not disturb icon";
*/
/*
  @widget-preset-field
  preset = "controlCenterButton"; name = "controlCenterGroupOrder";
  widget = "list";
  label = "Indicator order"; description = "Order of the status indicators shown in the control center button.";
*/

/*
  @widget-preset
  id = "notificationButton"; label = "Notification Center";
  description = "Access to notifications and do not disturb";
  icon = "notifications-symbolic"; sections = [ "left" "right" "center" "dock" ];
  hasSettings = false;
*/
/*
  @widget-preset
  id = "battery"; label = "Battery";
  description = "Battery and power management";
  icon = "battery-symbolic"; sections = [ "left" "right" "center" "dock" ];
  hasSettings = true;
  defaults.showBatteryPercent = true;
  defaults.batteryStyle = "icon";
*/
/*
  @widget-preset-field
  preset = "battery"; name = "showBatteryPercent";
  widget = "switch"; label = "Show percentage";
*/
/*
  @widget-preset-field
  preset = "battery"; name = "showBatteryPercentOnlyOnBattery";
  widget = "switch"; label = "Only on battery";
  description = "Hide the percentage while charging.";
*/
/*
  @widget-preset-field
  preset = "battery"; name = "showBatteryTime";
  widget = "switch"; label = "Show remaining time";
*/
/*
  @widget-preset-field
  preset = "battery"; name = "batteryStyle";
  widget = "dropdown"; choices = [ "icon" "solid" "outline" "ring" "duo" ];
  label = "Battery style";
*/
/*
  @widget-preset-field
  preset = "battery"; name = "showBatteryPowerCharging";
  widget = "switch";
  label = "Show charge rate"; description = "Show how many watts are going into the battery while charging.";
*/
/*
  @widget-preset-field
  preset = "battery"; name = "showBatteryPowerDischarging";
  widget = "switch";
  label = "Show discharge rate"; description = "Show how many watts the system is drawing from the battery.";
*/
/*
  @widget-preset-field
  preset = "battery"; name = "showBatteryTimeOnlyOnBattery";
  widget = "switch";
  label = "Time only on battery"; description = "Hide the remaining time while charging.";
*/

/*
  @widget-preset
  id = "vpn"; label = "VPN";
  description = "VPN status and quick connect";
  icon = "network-vpn-symbolic"; sections = [ "left" "right" "center" "dock" ];
  hasSettings = false;
*/
/*
  @widget-preset
  id = "idleInhibitor"; label = "Idle inhibitor";
  description = "Prevent screen timeout";
  icon = "my-caffeine-on-symbolic"; sections = [ "left" "right" "center" "dock" ];
  hasSettings = false;
*/
/*
  @widget-preset
  id = "capsLockIndicator"; label = "Caps Lock indicator";
  description = "Shows when caps lock is active";
  icon = "caps-lock-symbolic"; sections = [ "left" "right" "center" "dock" ];
  hasSettings = false;
*/
/*
  @widget-preset
  id = "spacer"; label = "Spacer";
  description = "Customizable empty space";
  icon = "view-more-horizontal-symbolic"; sections = [ "left" "right" "center" "dock" ];
  hasSettings = false;
  defaults.size = 20;
*/
/*
  @widget-preset-field
  preset = "spacer"; name = "size";
  widget = "spin"; min = 0; max = 200; unit = "px";
  label = "Size"; description = "Width or height of the empty space.";
*/

/*
  @widget-preset
  id = "separator"; label = "Separator";
  description = "Visual divider between widgets";
  icon = "list-remove-symbolic"; sections = [ "left" "right" "center" "dock" ];
  hasSettings = false;
*/
/*
  @widget-preset
  id = "network_speed_monitor"; label = "Network speed monitor";
  description = "Network download and upload speed display";
  icon = "network-transmit-receive-symbolic"; sections = [ "left" "right" "center" "dock" ];
  hasSettings = true;
*/
/*
  @widget-preset-field
  preset = "network_speed_monitor"; name = "hideWhenIdle";
  widget = "switch"; label = "Hide when idle";
  description = "While download and upload are both under 1 KB/s.";
*/
/*
  @widget-preset-field
  preset = "network_speed_monitor"; name = "compactMode";
  widget = "switch"; label = "Compact mode";
  description = "Whole numbers, at most three digits.";
*/
/*
  @widget-preset
  id = "keyboard_layout_name"; label = "Keyboard layout";
  description = "Displays the active keyboard layout and allows switching";
  icon = "input-keyboard-symbolic"; sections = [ "left" "right" "center" "dock" ];
  hasSettings = true;
*/
/*
  @widget-preset-field
  preset = "keyboard_layout_name"; name = "keyboardLayoutNameCompactMode";
  widget = "switch"; label = "Compact mode";
*/
/*
  @widget-preset-field
  preset = "keyboard_layout_name"; name = "keyboardLayoutNameShowIcon";
  widget = "switch"; label = "Show icon";
*/
/*
  @widget-preset-field
  preset = "keyboard_layout_name"; name = "keyboardLayoutNameLabelOverrides";
  widget = "raw";
  label = "Label overrides"; description = "Map of displayed layout labels to replacement labels.";
*/

/*
  @widget-preset
  id = "notepadButton"; label = "Notepad";
  description = "Quick access to notepad";
  icon = "text-editor-symbolic"; sections = [ "left" "right" "center" "dock" ];
  hasSettings = false;
*/
/*
  @widget-preset
  id = "colorPicker"; label = "Color Picker";
  description = "Quick access to color picker";
  icon = "color-select-symbolic"; sections = [ "left" "right" "center" "dock" ];
  hasSettings = false;
*/
/*
  @widget-preset
  id = "systemUpdate"; label = "System update";
  description = "Check for system updates";
  icon = "software-update-available-symbolic"; sections = [ "left" "right" "center" "dock" ];
  hasSettings = true;
*/
/*
  @widget-preset-field
  preset = "systemUpdate"; name = "hideWhenIdle";
  widget = "switch"; label = "Hide when no updates";
*/
/*
  @widget-preset
  id = "powerMenuButton"; label = "Power";
  description = "Display the power system menu";
  icon = "system-shutdown-symbolic"; sections = [ "left" "right" "center" "dock" ];
  hasSettings = false;
*/

{ ... }: { }
