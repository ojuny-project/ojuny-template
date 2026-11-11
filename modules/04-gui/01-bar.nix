/*
  @menu
  displayname = "Bar";
  icon = "view-list-symbolic";
  order = 10;
  description = "Bar layout, widgets and island style";
  category = "04-GUI";
*/

{ self, inputs, ... }: {

  flake.modules.nixos.desktop-bar =
    { config, lib, ... }:

    {
      imports = [ self.modules.nixos.desktop-bar-backend ];

      config = {

        # @option widget = "dropdown"; label = "Preset"; order = 1; choices = [ "default" "taskbar" "status" "sidebar-left" "sidebar-right" "caelestia" "goth" "simple-island" "simple-bar" "custom" "none" ]; description = "Active bar preset. Apply with Save and Rebuild.";
        ojuny.dux.barPreset = "default";

        # @option widget = "bar"; label = "Custom bar"; visibleWhen.path = "ojuny.dux.barPreset"; visibleWhen.equals = "custom";
        ojuny.dux.customBar = {

          # @option widget = "text"; label = "Name"; group = "Bar"; groupOrder = 10; description = "Display name for this bar.";
          name = "Custom bar";

          # @option widget = "dropdown"; label = "Position"; group = "Bar"; groupOrder = 10; choices = [ "0" "1" "2" "3" ]; description = "Screen edge: 0 = top, 1 = bottom, 2 = left, 3 = right."; applyCommand = "case %%val%% in 0) p=top;; 1) p=bottom;; 2) p=left;; 3) p=right;; esac; dms ipc call bar setPosition id custom \"$p\"";
          position = 0;

          # @option widget = "switch"; label = "Show on last display"; group = "Bar"; groupOrder = 10; description = "Keep the bar on the display it was last shown on.";
          showOnLastDisplay = true;

          # @option widget = "list"; label = "Screens"; group = "Bar"; groupOrder = 10; hidden = true; description = "Screen names, or \"all\".";
          screenPreferences = [ "all" ];

          # @option label = "Center widgets"; description = "Widgets shown in the bar centre. Position is the tile order. The island widget displaces centre widgets.";
          centerWidgets = [
            "music"
            "clock"
            "weather"
          ];

          # @option widget = "switch"; label = "Show on overview"; group = "Bar"; groupOrder = 10; description = "Keep the bar visible while the overview is open.";
          openOnOverview = false;

          # @option widget = "spin"; label = "Order"; group = "Bar"; groupOrder = 10; min = 1; max = 1000; hidden = true; description = "Sort order when several bars exist.";
          _order = 10;

          # @option widget = "switch"; label = "Auto hide"; group = "Auto hide"; groupOrder = 20; description = "Hide the bar until the pointer reaches the screen edge."; applyCommand = "if test %%val%% = true; then dms ipc call bar autoHide id custom; else dms ipc call bar manualHide id custom; fi";
          autoHide = false;

          # @option widget = "spin"; label = "Auto hide delay"; group = "Auto hide"; groupOrder = 20; min = 0; max = 5000; unit = "ms"; description = "Delay before the bar hides again."; visibleWhen.path = "ojuny.dux.customBar.autoHide"; visibleWhen.equals = true;
          autoHideDelay = 250;

          # @option widget = "switch"; label = "Attach to screen edge"; group = "Bar"; groupOrder = 10; description = "Snap the bar flush to the screen edge instead of floating.";
          attachToScreenEdge = false;

          # @option widget = "switch"; label = "Use overlay layer"; group = "Bar"; groupOrder = 10; advanced = true; description = "Draw the bar on the overlay layer so windows can overlap it.";
          useOverlayLayer = false;

          # @option widget = "slider"; label = "Transparency"; group = "Transparency"; groupOrder = 30; min = 0.0; max = 1.0; step = 0.05; description = "Opacity of the bar background.";
          transparency = 1;

          # @option widget = "slider"; label = "Widget transparency"; group = "Transparency"; groupOrder = 30; min = 0.0; max = 1.0; step = 0.05; description = "Opacity of the bar widgets.";
          widgetTransparency = 1;

          followInterfaceStyle = false;
          surfaceColor = "sch";
          widgetFollowInterfaceStyle = true;

          # @option widget = "slider"; label = "Icon scale"; group = "Scale and spacing"; groupOrder = 25; horizontal = true; min = 0.5; max = 2.0; step = 0.05; description = "Multiplier for widget icon sizes.";
          iconScale = 0.9;

          # @option widget = "slider"; label = "Font scale"; group = "Scale and spacing"; groupOrder = 25; horizontal = true; min = 0.5; max = 2.0; step = 0.05; description = "Multiplier for bar font sizes.";
          fontScale = 0.9;

          # @option widget = "spin"; label = "Spacing"; group = "Scale and spacing"; groupOrder = 25; horizontal = true; min = 0; max = 40; unit = "px"; description = "Gap between widgets.";
          spacing = 0;

          # @option widget = "spin"; label = "Bottom gap"; group = "Scale and spacing"; groupOrder = 25; horizontal = true; min = 0; max = 100; unit = "px"; description = "Gap between the bar and its screen edge.";
          bottomGap = 0;

          # @option widget = "spin"; label = "Inner padding"; group = "Scale and spacing"; groupOrder = 25; horizontal = true; min = 0; max = 40; unit = "px"; description = "Padding inside the bar around its content.";
          innerPadding = 0;

          # @option widget = "spin"; label = "Widget padding"; group = "Scale and spacing"; groupOrder = 25; horizontal = true; min = 0; max = 40; unit = "px"; description = "Padding around each widget.";
          widgetPadding = 9;

          # @option widget = "switch"; label = "Square corners"; group = "Appearance"; groupOrder = 35; description = "Use square bar corners instead of rounded ones.";
          squareCorners = true;

          # @option widget = "switch"; label = "No background"; group = "Appearance"; groupOrder = 35; description = "Draw no background surface; widgets sit directly on the wallpaper.";
          noBackground = false;

          # @option widget = "switch"; label = "Widget outline"; group = "Appearance"; groupOrder = 35; description = "Draw an outline around each widget.";
          widgetOutlineEnabled = true;

          # @option widget = "switch"; label = "Border"; group = "Appearance"; groupOrder = 35; description = "Draw a border around the bar.";
          borderEnabled = false;

          # @option widget = "dropdown"; label = "Border color"; group = "Appearance"; groupOrder = 35; choices = [ "primary" "primaryContainer" "secondary" "secondaryContainer" "tertiary" "tertiaryContainer" "surfaceText" "surfaceVariant" "s" "scll" "scl" "sc" "sch" "schh" "sth" "error" ]; description = "Theme role used for the bar border. sch = scheme high surface, s = surface."; visibleWhen.path = "ojuny.dux.customBar.borderEnabled"; visibleWhen.equals = true;
          borderColor = "primary";

          # @option widget = "slider"; label = "Border opacity"; group = "Appearance"; groupOrder = 35; min = 0.0; max = 1.0; step = 0.05; description = "Opacity of the bar border."; visibleWhen.path = "ojuny.dux.customBar.borderEnabled"; visibleWhen.equals = true;
          borderOpacity = 1;

          borderThickness = 1;

          # @option widget = "spin"; label = "Shadow intensity"; group = "Appearance"; groupOrder = 35; min = 0; max = 100; description = "Strength of the bar drop shadow.";
          shadowIntensity = 0;

          # @option widget = "spin"; label = "Shadow opacity"; group = "Appearance"; groupOrder = 35; min = 0; max = 100; unit = "%"; description = "Opacity of the bar drop shadow in percent.";
          shadowOpacity = 60;

          # @option widget = "switch"; label = "Automatic popup gaps"; group = "Scale and spacing"; groupOrder = 25; horizontal = true; description = "Compute popup gap size from the bar layout automatically.";
          popupGapsAuto = true;

          # @option widget = "spin"; label = "Popup gap"; group = "Scale and spacing"; groupOrder = 25; horizontal = true; min = 0; max = 40; unit = "px"; description = "Popup gap size when automatic gaps are off."; visibleWhen.path = "ojuny.dux.customBar.popupGapsAuto"; visibleWhen.equals = false;
          popupGapsManual = 4;

          # @option widget = "switch"; label = "Island"; group = "Island"; groupOrder = 40; description = "Draw the bar as a floating island detached from the screen edge.";
          island = true;

          # @option widget = "spin"; label = "Compact thickness"; group = "Island"; groupOrder = 40; min = 0; max = 200; unit = "px"; description = "Island thickness in compact mode.";
          islandCompactThickness = 31;

          # @option widget = "spin"; label = "Outer gap"; group = "Island"; groupOrder = 40; min = 0; max = 100; unit = "px"; description = "Gap between the island and the screen edge.";
          islandOuterGap = 3;

          # @option widget = "spin"; label = "Satellite gap"; group = "Island"; groupOrder = 40; min = 0; max = 100; unit = "px"; description = "Gap between the island and its satellite popouts.";
          islandSatelliteGap = 4;

          # @option widget = "switch"; label = "Satellite background"; group = "Island"; hidden = true;
          islandSatelliteBackground = false;

          # @option widget = "switch"; label = "Satellite goth corners"; group = "Island"; hidden = true;
          islandSatelliteGothCorners = false;

          # @option widget = "spin"; label = "Satellite hover gap"; group = "Island"; groupOrder = 40; min = 0; max = 100; unit = "px"; description = "Extra satellite gap while the island is hovered.";
          islandSatelliteHoverGap = 5;

          # @option widget = "spin"; label = "Hover open delay"; group = "Island"; groupOrder = 40; min = 0; max = 2000; unit = "ms"; description = "Delay before a hovered satellite opens.";
          islandHoverOpenDelay = 350;

          # @option widget = "spin"; label = "Hover close delay"; group = "Island"; groupOrder = 40; min = 0; max = 2000; unit = "ms"; description = "Delay before a hovered satellite closes.";
          islandHoverCloseDelay = 350;

          # @option widget = "spin"; label = "Spring stiffness"; group = "Island motion"; hidden = true; min = 0;
          islandSpringStiffness = 760;

          # @option widget = "spin"; label = "Spring damping"; group = "Island motion"; hidden = true; min = 0;
          islandSpringDamping = 47;

          # @option widget = "spin"; label = "Spring mass"; group = "Island motion"; hidden = true; min = 1;
          islandSpringMass = 2;

          # @option widget = "spin"; label = "Widget padding"; group = "Island"; groupOrder = 40; min = 0; max = 40; unit = "px"; description = "Padding around widgets inside the island.";
          islandWidgetPadding = 0;

          # @option widget = "switch"; label = "Widget outline"; group = "Island"; groupOrder = 40; description = "Outline the widgets inside the island.";
          islandWidgetOutlineEnabled = true;

          # @option widget = "dropdown"; label = "Widget outline color"; group = "Island"; groupOrder = 40; choices = [ "primary" "primaryContainer" "secondary" "secondaryContainer" "tertiary" "tertiaryContainer" "surfaceText" "surfaceVariant" "s" "scll" "scl" "sc" "sch" "schh" "sth" "error" ]; description = "Theme role used for the island widget outline. surfaceText = on-background text."; visibleWhen.path = "ojuny.dux.customBar.islandWidgetOutlineEnabled"; visibleWhen.equals = true;
          islandWidgetOutlineColor = "surfaceText";

          # @option widget = "slider"; label = "Widget outline opacity"; group = "Island"; groupOrder = 40; min = 0.0; max = 1.0; step = 0.05; description = "Opacity of the island widget outline."; visibleWhen.path = "ojuny.dux.customBar.islandWidgetOutlineEnabled"; visibleWhen.equals = true;
          islandWidgetOutlineOpacity = 0.5;

          # @option widget = "switch"; label = "Bar goth corners"; group = "Appearance"; groupOrder = 35; description = "Square off the regular (non-island) bar corners instead of rounding them.";
          gothCornersEnabled = false;

          # @option widget = "switch"; label = "Override bar goth corner radius"; group = "Appearance"; groupOrder = 35; description = "Use a custom radius for the bar's goth corners."; visibleWhen.path = "ojuny.dux.customBar.gothCornersEnabled"; visibleWhen.equals = true;
          gothCornerRadiusOverride = false;

          # @option widget = "spin"; label = "Bar goth corner radius"; group = "Appearance"; groupOrder = 35; min = 0; max = 100; unit = "px"; description = "Radius of the bar's goth corners."; visibleWhen.path = "ojuny.dux.customBar.gothCornerRadiusOverride"; visibleWhen.equals = true;
          gothCornerRadiusValue = 12;

          # @option widget = "spin"; label = "Inset padding"; group = "Scale and spacing"; groupOrder = 25; min = -1; max = 48; unit = "px"; horizontal = true; description = "Gap between the bar ends and the outermost widgets. -1 uses the default.";
          barInsetPadding = -1;

          # @option widget = "dropdown"; label = "Battery color"; group = "Appearance"; groupOrder = 35; choices = [ "theme" "level" ]; description = "Theme uses the accent color, level colors the battery by charge level.";
          batteryColorMode = "theme";

          # @option widget = "switch"; label = "Maximize widget icons"; group = "Scale and spacing"; groupOrder = 25; description = "Stretch widget icons to fill the bar.";
          maximizeWidgetIcons = false;

          # @option widget = "switch"; label = "Maximize widget text"; group = "Scale and spacing"; groupOrder = 25; description = "Stretch widget text to fill the bar.";
          maximizeWidgetText = false;

          # @option widget = "dropdown"; label = "Shadow color"; group = "Appearance"; groupOrder = 35; choices = [ "default" "surface" "primary" "custom" ]; description = "Source of the bar drop shadow color.";
          shadowColorMode = "default";

          # @option widget = "color"; label = "Custom shadow color"; group = "Appearance"; groupOrder = 35; visibleWhen.path = "ojuny.dux.customBar.shadowColorMode"; visibleWhen.equals = "custom"; description = "Shadow color used when the shadow color is set to custom.";
          shadowCustomColor = "#000000";

          # @option widget = "dropdown"; label = "Shadow direction source"; group = "Appearance"; groupOrder = 35; choices = [ "inherit" "autoBar" "manual" ]; description = "Inherit the global shadow direction, derive it from the bar, or set it manually.";
          shadowDirectionMode = "inherit";

          # @option widget = "dropdown"; label = "Shadow direction"; group = "Appearance"; groupOrder = 35; choices = [ "top" "topLeft" "topRight" "bottom" ]; visibleWhen.path = "ojuny.dux.customBar.shadowDirectionMode"; visibleWhen.equals = "manual"; description = "Shadow direction used when the direction source is manual.";
          shadowDirection = "top";

          # @option widget = "color"; label = "Custom background color"; group = "Appearance"; groupOrder = 35; visibleWhen.path = "ojuny.dux.customBar.surfaceColor"; visibleWhen.equals = "custom"; description = "Bar background color used when the background color is set to custom.";
          surfaceCustomColor = "#6750A4";

          # @option widget = "dropdown"; label = "Widget outline color"; group = "Appearance"; groupOrder = 35; choices = [ "surfaceText" "secondary" "primary" ]; description = "Theme role used for the widget outline.";
          widgetOutlineColor = "primary";

          # @option widget = "slider"; label = "Widget outline opacity"; group = "Appearance"; groupOrder = 35; min = 0.0; max = 1.0; step = 0.05; description = "Opacity of the widget outline.";
          widgetOutlineOpacity = 1.0;

          # @option widget = "spin"; label = "Widget outline thickness"; group = "Appearance"; groupOrder = 35; min = 1; max = 10; unit = "px"; description = "Outline width around each widget.";
          widgetOutlineThickness = 1;

          # @option widget = "dropdown"; label = "Widget style"; group = "Appearance"; groupOrder = 35; choices = [ "pills" "segments" "flat" ]; description = "How widgets are drawn inside the bar.";
          widgetStyle = "pills";

          # @option widget = "spin"; label = "Island along offset"; group = "Island"; groupOrder = 40; min = -600; max = 600; unit = "px"; description = "Shift the island along the screen edge.";
          islandAlongOffset = 0;

          # @option widget = "dropdown"; label = "Island battery style"; group = "Island"; groupOrder = 40; choices = [ "solid" "outline" "ring" "duo" ]; description = "Battery meter drawn on the island home face.";
          islandBatteryStyle = "duo";

          # @option widget = "switch"; label = "Charging pulse"; group = "Island"; groupOrder = 40; description = "Pulse the island when the charger is connected or removed.";
          islandChargingPulse = true;

          # @option widget = "switch"; label = "Island floating"; group = "Island"; groupOrder = 40; description = "Detach the island from the screen edge.";
          islandFloating = false;

          # @option widget = "spin"; label = "Island edge margin"; group = "Island"; groupOrder = 40; min = 0; max = 64; unit = "px"; description = "Gap kept from the display edge when the island is free floating.";
          islandFreeEdgeMargin = 2;

          # @option widget = "text"; label = "Island free icon"; group = "Island"; groupOrder = 40; description = "Icon name drawn inside a free floating island.";
          islandFreeIcon = "blur_on";

          # @option widget = "text"; label = "Island free icon color"; group = "Island"; groupOrder = 40; description = "Color role name or hex value for the free floating island icon.";
          islandFreeIconColor = "primary";

          # @option widget = "dropdown"; label = "Island free icon mode"; group = "Island"; groupOrder = 40; choices = [ "icon" "os" "dank" "compositor" "custom" ]; description = "Which artwork the free floating island shows.";
          islandFreeIconMode = "icon";

          # @option widget = "text"; label = "Island free icon path"; group = "Island"; groupOrder = 40; description = "Image path used when the free island icon mode is custom.";
          islandFreeIconPath = "";

          # @option widget = "spin"; label = "Island idle delay"; group = "Island"; groupOrder = 40; min = 0; max = 30000; unit = "ms"; description = "Time before the free floating island fades while idle. 0 disables fading.";
          islandFreeIdleDelay = 2500;

          # @option widget = "slider"; label = "Island idle opacity"; group = "Island"; groupOrder = 40; min = 0.0; max = 1.0; step = 0.05; description = "Opacity of the free floating island while idle.";
          islandFreeIdleOpacity = 0.45;

          # @option widget = "slider"; label = "Island idle size"; group = "Island"; groupOrder = 40; min = 0.2; max = 1.0; step = 0.01; description = "How far the free floating island shrinks while idle.";
          islandFreeIdleScale = 0.4;

          # @option widget = "spin"; label = "Island free size"; group = "Island"; groupOrder = 40; min = 24; max = 160; unit = "px"; description = "Diameter of a free floating island.";
          islandFreeSize = 48;

          # @option widget = "switch"; label = "Island high contrast"; group = "Island"; groupOrder = 40; description = "Draw the island with a higher contrast outline.";
          islandHighContrast = false;

          # @option widget = "dropdown"; label = "Island brightness style"; group = "Island"; groupOrder = 40; choices = [ "icon" "percentage" "both" ]; description = "How the home face shows brightness.";
          islandHomeBrightnessDisplay = "both";

          # @option widget = "dropdown"; label = "Island clock style"; group = "Island"; groupOrder = 40; choices = [ "time" "date" "both" ]; description = "How the home face shows the clock.";
          islandHomeClockDisplay = "both";

          # @option widget = "switch"; label = "Island tight compact"; group = "Island"; groupOrder = 40; description = "Use the narrower compact home face.";
          islandHomeCompactTight = false;

          # @option widget = "dropdown"; label = "Island status content"; group = "Island"; groupOrder = 40; choices = [ "battery" "connectivity" ]; description = "Status group shown on the home face.";
          islandHomeStatusContent = "battery";

          # @option widget = "dropdown"; label = "Island volume style"; group = "Island"; groupOrder = 40; choices = [ "icon" "percentage" "both" ]; description = "How the home face shows volume.";
          islandHomeVolumeDisplay = "both";

          # @option widget = "dropdown"; label = "Island expansion mode"; group = "Island"; groupOrder = 40; choices = [ "click" "hybrid" ]; description = "Click expands on click only, hybrid also peeks on hover.";
          islandInteractionMode = "hybrid";

          # @option widget = "switch"; label = "Island media auto switch"; group = "Island"; groupOrder = 40; description = "Switch the compact face to media when playback starts.";
          islandMediaAutoSwitch = false;

          # @option widget = "switch"; label = "Island media clock"; group = "Island"; groupOrder = 40; description = "Keep the clock visible on the media face.";
          islandMediaClockVisible = true;

          # @option widget = "switch"; label = "Island media lyrics"; group = "Island"; groupOrder = 40; description = "Show synced lyrics on the media face.";
          islandMediaLyrics = false;

          # @option widget = "switch"; label = "Island notch"; group = "Island"; groupOrder = 40; description = "Merge the island with the screen edge as a notch.";
          islandNotch = false;

          # @option widget = "switch"; label = "Island clear badge on open"; group = "Island"; groupOrder = 40; description = "Clear the notification badge when the notification center opens.";
          islandNotificationBadgeClearOnOpen = false;

          # @option widget = "switch"; label = "Island expand notifications"; group = "Island"; groupOrder = 40; description = "Show arriving notifications expanded.";
          islandNotificationExpand = false;

          # @option widget = "switch"; label = "Island standard popups"; group = "Island"; groupOrder = 40; description = "Show arriving notifications as regular popups instead of inside the island.";
          islandNotificationPopups = false;

          # @option widget = "dropdown"; label = "Island palette"; group = "Island"; groupOrder = 40; choices = [ "default" "bright" "dim" ]; description = "Surface tone used by the island.";
          islandPalette = "default";

          # @option widget = "dropdown"; label = "Island placement"; group = "Island"; groupOrder = 40; choices = [ "edge" "free" ]; description = "Dock the island to the edge or let it float freely.";
          islandPlacement = "edge";

          # @option widget = "spin"; label = "Island reserve thickness"; group = "Island"; groupOrder = 40; min = 24; max = 128; unit = "px"; description = "Reserved strip kept free for the island.";
          islandReserveThickness = 40;

          # @option widget = "dropdown"; label = "Island clipboard route"; group = "Island"; groupOrder = 40; choices = [ "island" "follow" ]; description = "Send the clipboard shortcut to the island or leave it on the bar popout.";
          islandRouteClipboard = "follow";

          # @option widget = "dropdown"; label = "Island control center route"; group = "Island"; groupOrder = 40; choices = [ "island" "follow" ]; description = "Send the control center shortcut to the island or leave it on the bar popout.";
          islandRouteControlCenter = "follow";

          # @option widget = "dropdown"; label = "Island dashboard route"; group = "Island"; groupOrder = 40; choices = [ "island" "follow" ]; description = "Send the dashboard shortcut to the island or leave it on the bar popout.";
          islandRouteDash = "island";

          # @option widget = "dropdown"; label = "Island launcher route"; group = "Island"; groupOrder = 40; choices = [ "island" "follow" ]; description = "Send the launcher shortcut to the island or leave it on the bar popout.";
          islandRouteLauncher = "follow";

          # @option widget = "dropdown"; label = "Island media route"; group = "Island"; groupOrder = 40; choices = [ "island" "follow" ]; description = "Send the media shortcut to the island or leave it on the bar popout.";
          islandRouteMedia = "island";

          # @option widget = "dropdown"; label = "Island notification center route"; group = "Island"; groupOrder = 40; choices = [ "island" "follow" ]; description = "Send the notification center shortcut to the island or leave it on the bar popout.";
          islandRouteNotificationCenter = "follow";

          # @option widget = "dropdown"; label = "Island power menu route"; group = "Island"; groupOrder = 40; choices = [ "island" "follow" ]; description = "Send the power menu shortcut to the island or leave it on the bar popout.";
          islandRoutePowerMenu = "follow";

          # @option widget = "dropdown"; label = "Island wallpaper route"; group = "Island"; groupOrder = 40; choices = [ "island" "follow" ]; description = "Send the wallpaper shortcut to the island or leave it on the bar popout.";
          islandRouteWallpaper = "island";

          # @option widget = "dropdown"; label = "Island weather route"; group = "Island"; groupOrder = 40; choices = [ "island" "follow" ]; description = "Send the weather shortcut to the island or leave it on the bar popout.";
          islandRouteWeather = "island";

          # @option widget = "switch"; label = "Island satellites follow interface"; group = "Island"; groupOrder = 40; description = "Let satellites follow the global interface opacity.";
          islandSatelliteFollowInterfaceStyle = true;

          # @option widget = "dropdown"; label = "Island satellite position"; group = "Island"; groupOrder = 40; choices = [ "island" "edges" ]; description = "Place satellites near the island or at the display edges.";
          islandSatellitePosition = "edges";

          # @option widget = "slider"; label = "Island satellite opacity"; group = "Island"; groupOrder = 40; min = 0.0; max = 1.0; step = 0.05; description = "Opacity of the satellite background.";
          islandSatelliteTransparency = 1.0;

          # @option widget = "switch"; label = "Island satellites"; group = "Island"; groupOrder = 40; description = "Show widget satellites next to the island.";
          islandSatellitesEnabled = true;

          # @option widget = "dropdown"; label = "Island shared shortcuts"; group = "Island"; groupOrder = 40; choices = [ "normal" "always" "last-used" ]; description = "Which island handles global shortcuts.";
          islandSharedRouting = "normal";

          # @option widget = "switch"; label = "Island system OSD"; group = "Island"; groupOrder = 40; description = "Show volume and brightness changes inside the island.";
          islandSystemOsd = true;

          # @option widget = "switch"; label = "Island overlay layer"; group = "Island"; groupOrder = 40; description = "Draw the island on the overlay layer so windows can overlap it.";
          islandUseOverlayLayer = false;

          # @option widget = "switch"; label = "Strict auto hide"; group = "Auto hide"; groupOrder = 20; description = "Hide the bar whenever the pointer leaves even if a popout is open.";
          autoHideStrict = false;

          # @option widget = "dropdown"; label = "Bar length"; group = "Scale and spacing"; groupOrder = 25; choices = [ "full" "percent" "fit" ]; description = "Span the whole edge, a percentage of it, or only the widgets.";
          barLengthMode = "full";

          # @option widget = "spin"; label = "Length padding"; group = "Scale and spacing"; groupOrder = 25; min = 0; max = 512; unit = "px"; description = "Shorten the bar at both ends when it spans the full edge.";
          barLengthPadding = 0;

          # @option widget = "spin"; label = "Bar length percent"; group = "Scale and spacing"; groupOrder = 25; min = 10; max = 100; unit = "%"; visibleWhen.path = "ojuny.dux.customBar.barLengthMode"; visibleWhen.equals = "percent"; description = "Percentage of the edge the bar spans.";
          barLengthPercent = 80;

          # @option widget = "text"; label = "Center overflow mode"; group = "Behavior"; groupOrder = 50; advanced = true; description = "How overflowing centre widgets are handled. Not part of the recorded settings defaults.";
          centerOverflowMode = "";

          # @option widget = "switch"; label = "Follow mouse"; group = "Behavior"; groupOrder = 50; description = "Open the control center at the cursor instead of the widget.";
          clickActionFollowMouse = false;

          # @option widget = "switch"; label = "Click through"; group = "Behavior"; groupOrder = 50; description = "Let clicks on empty bar space reach the windows below.";
          clickThrough = false;

          # @option widget = "spin"; label = "Hover popout delay"; group = "Behavior"; groupOrder = 50; min = 0; max = 1000; unit = "ms"; description = "Delay before a hovered popout opens.";
          hoverPopoutDelay = 150;

          # @option widget = "switch"; label = "Hover popouts"; group = "Behavior"; groupOrder = 50; description = "Open popouts when the pointer hovers a widget.";
          hoverPopouts = false;

          # @option widget = "text"; label = "Left overflow mode"; group = "Behavior"; groupOrder = 50; advanced = true; description = "How overflowing left widgets are handled. Not part of the recorded settings defaults.";
          leftOverflowMode = "";

          # @option widget = "switch"; label = "Maximize detection"; group = "Behavior"; groupOrder = 50; description = "Track maximized windows so the bar can react to them.";
          maximizeDetection = true;

          # @option widget = "dropdown"; label = "Middle click"; group = "Behavior"; groupOrder = 50; choices = [ "none" "control-center" "spotlight" "close-window" "settings" ]; description = "What middle clicking empty bar space does.";
          middleClickAction = "none";

          # @option widget = "dropdown"; label = "Right click"; group = "Behavior"; groupOrder = 50; choices = [ "none" "control-center" "spotlight" "close-window" "settings" ]; description = "What right clicking empty bar space does.";
          rightClickAction = "none";

          # @option widget = "text"; label = "Right overflow mode"; group = "Behavior"; groupOrder = 50; advanced = true; description = "How overflowing right widgets are handled. Not part of the recorded settings defaults.";
          rightOverflowMode = "";

          # @option widget = "switch"; label = "Scroll wheel"; group = "Behavior"; groupOrder = 50; description = "Change workspaces or focus by scrolling over the bar.";
          scrollEnabled = true;

          # @option widget = "dropdown"; label = "Scroll X axis"; group = "Behavior"; groupOrder = 50; choices = [ "none" "workspace" "focusWindow" ]; description = "What horizontal scrolling over the bar does.";
          scrollXBehavior = "focusWindow";

          # @option widget = "dropdown"; label = "Scroll Y axis"; group = "Behavior"; groupOrder = 50; choices = [ "none" "workspace" "focusWindow" ]; description = "What vertical scrolling over the bar does.";
          scrollYBehavior = "workspace";

          # @option widget = "switch"; label = "Show when windows open"; group = "Auto hide"; groupOrder = 20; description = "Reveal the bar when a window opens.";
          showOnWindowsOpen = false;
          # @option label = "Left widgets"; description = "Widgets shown on the left of the bar. Position is the tile order.";
          leftWidgets = {

            workspaceSwitcher = {
              enabled = true;
              _order = 10;
              showOccupiedWorkspacesOnly = true;
              showWorkspaceIndex = true;
              showWorkspacePadding = true;
              workspacePaddingCount = 5;
              workspaceIndicatorCompact = true;
              dwlShowAllTags = false;
            };

            dankKDEConnect = {
              enabled = true;
              _order = 20;
            };

            layout = {
              enabled = true;
              _order = 30;
            };

            dankCalendarAgenda = {
              enabled = config.desktop.ojuny.dux.plugins.dankCalendarAgenda.enable;
              _order = 35;
            };

            scratchpadHelper = {
              enabled = true;
              _order = 40;
            };

          };

          # @option label = "Right widgets"; description = "Widgets shown on the right of the bar. Position is the tile order.";
          rightWidgets = {

            systemTray = {
              enabled = true;
              _order = 10;
            };

            clipboard = {
              enabled = true;
              _order = 20;
            };

            developerUtilities = {
              enabled = true;
              _order = 30;
            };

            nixMonitor = {
              enabled = true;
              _order = 40;
            };

            localServices = {
              enabled = true;
              _order = 50;
            };

            controlCenterButton = {
              enabled = true;
              showAudioPercent = true;
              showBatteryIcon = true;
              showBrightnessIcon = true;
              showBrightnessPercent = true;
              showDoNotDisturbIcon = true;
              showIdleInhibitorIcon = true;
              showMicIcon = true;
              showMicPercent = true;
              _order = 60;
            };

          };

        };

        # @option widget = "switch"; label = "Elevation shadow"; group = "Bar"; advanced = true; description = "Draw a drop shadow under the bar."; applyCommand = "dms ipc call settings set barElevationEnabled %%val%%";
        desktop.ojuny.dux.settings.barElevationEnabled = false;

        # @option widget = "spin"; label = "Shared inset padding"; group = "Bar"; groupOrder = 10; min = -1; max = 48; unit = "px"; advanced = true; description = "Inset padding applied to every bar when sync is on."; applyCommand = "dms ipc call settings set barInsetPaddingShared %%val%%";
        desktop.ojuny.dux.settings.barInsetPaddingShared = -1;

        # @option widget = "switch"; label = "Sync inset padding"; group = "Bar"; groupOrder = 10; advanced = true; description = "Apply one inset padding value to every bar."; applyCommand = "dms ipc call settings set barInsetPaddingSyncAll %%val%%";
        desktop.ojuny.dux.settings.barInsetPaddingSyncAll = false;

        # @option widget = "color"; label = "Custom card surface color"; group = "Surfaces"; groupOrder = 60; visibleWhen.path = "desktop.ojuny.dux.settings.cardSurfaceColor"; visibleWhen.equals = "custom"; description = "Card surface color used when the card surface color is custom."; applyCommand = "dms ipc call settings set cardSurfaceCustomColor %%val%%";
        desktop.ojuny.dux.settings.cardSurfaceCustomColor = "#6750a4";

        # @option widget = "color"; label = "Custom chip surface color"; group = "Surfaces"; groupOrder = 60; visibleWhen.path = "desktop.ojuny.dux.settings.chipSurfaceColor"; visibleWhen.equals = "custom"; description = "Chip surface color used when the chip surface color is custom."; applyCommand = "dms ipc call settings set chipSurfaceCustomColor %%val%%";
        desktop.ojuny.dux.settings.chipSurfaceCustomColor = "#6750a4";

        # @option widget = "dropdown"; label = "Nested chip surface color"; group = "Surfaces"; groupOrder = 60; choices = [ "default" "s" "sc" "sch" "schh" "inverseSurface" "primaryContainer" "secondaryContainer" "tertiaryContainer" "custom" ]; description = "Color role used for controls nested inside a chip."; applyCommand = "dms ipc call settings set chipSurfaceNestedColor %%val%%";
        desktop.ojuny.dux.settings.chipSurfaceNestedColor = "default";

        # @option widget = "color"; label = "Custom nested chip color"; group = "Surfaces"; groupOrder = 60; visibleWhen.path = "desktop.ojuny.dux.settings.chipSurfaceNestedColor"; visibleWhen.equals = "custom"; description = "Nested chip surface color used when the nested chip color is custom."; applyCommand = "dms ipc call settings set chipSurfaceNestedCustomColor %%val%%";
        desktop.ojuny.dux.settings.chipSurfaceNestedCustomColor = "#6750A4";

        # @option widget = "spin"; label = "Frame bar inset padding"; group = "Frame"; groupOrder = 55; min = -1; max = 100; unit = "px"; advanced = true; description = "Inset padding used when the bar is drawn by the frame."; applyCommand = "dms ipc call settings set frameBarInsetPadding %%val%%";
        desktop.ojuny.dux.settings.frameBarInsetPadding = -1;

        # @option widget = "spin"; label = "Frame bar size"; group = "Frame"; groupOrder = 55; min = 24; max = 100; unit = "px"; advanced = true; description = "Thickness of the bar strip drawn by the frame."; applyCommand = "dms ipc call settings set frameBarSize %%val%%";
        desktop.ojuny.dux.settings.frameBarSize = 40;

        # @option widget = "switch"; label = "Frame blur"; group = "Frame"; groupOrder = 55; advanced = true; description = "Blur the background behind the frame bar."; applyCommand = "dms ipc call settings set frameBlurEnabled %%val%%";
        desktop.ojuny.dux.settings.frameBlurEnabled = true;

        # @option widget = "spin"; label = "Frame radius"; group = "Frame"; groupOrder = 55; min = 0; max = 100; unit = "px"; advanced = true; description = "Corner radius of the frame."; applyCommand = "dms ipc call settings set frameRounding %%val%%";
        desktop.ojuny.dux.settings.frameRounding = 23;

        # @option widget = "spin"; label = "Frame thickness"; group = "Frame"; groupOrder = 55; min = 2; max = 100; unit = "px"; advanced = true; description = "Border thickness of the frame."; applyCommand = "dms ipc call settings set frameThickness %%val%%";
        desktop.ojuny.dux.settings.frameThickness = 16;

        # @option widget = "color"; label = "Custom host surface color"; group = "Surfaces"; groupOrder = 60; visibleWhen.path = "desktop.ojuny.dux.settings.hostSurfaceColor"; visibleWhen.equals = "custom"; description = "Host surface color used when the host surface color is custom."; applyCommand = "dms ipc call settings set hostSurfaceCustomColor %%val%%";
        desktop.ojuny.dux.settings.hostSurfaceCustomColor = "#6750a4";

        # @option widget = "dropdown"; label = "Tooltip surface color"; group = "Surfaces"; groupOrder = 60; choices = [ "default" "s" "sc" "sch" "schh" "inverseSurface" "primaryContainer" "secondaryContainer" "tertiaryContainer" "custom" ]; advanced = true; description = "Color role used for tooltips."; applyCommand = "dms ipc call settings set tooltipSurfaceColor %%val%%";
        desktop.ojuny.dux.settings.tooltipSurfaceColor = "default";

        # @option widget = "color"; label = "Custom tooltip surface color"; group = "Surfaces"; groupOrder = 60; visibleWhen.path = "desktop.ojuny.dux.settings.tooltipSurfaceColor"; visibleWhen.equals = "custom"; advanced = true; description = "Tooltip surface color used when the tooltip surface color is custom."; applyCommand = "dms ipc call settings set tooltipSurfaceCustomColor %%val%%";
        desktop.ojuny.dux.settings.tooltipSurfaceCustomColor = "#6750A4";

        # @option widget = "color"; label = "Custom widget background"; group = "Surfaces"; groupOrder = 60; visibleWhen.path = "desktop.ojuny.dux.settings.widgetBackgroundColor"; visibleWhen.equals = "custom"; description = "Widget background color used when the widget background color is custom."; applyCommand = "dms ipc call settings set widgetBackgroundCustomColor %%val%%";
        desktop.ojuny.dux.settings.widgetBackgroundCustomColor = "#6750a4";

        # @option widget = "slider"; label = "Custom background strength"; group = "Surfaces"; groupOrder = 60; min = 0.0; max = 1.0; step = 0.05; description = "How strongly the custom widget background color is applied."; applyCommand = "dms ipc call settings set widgetBackgroundCustomStrength %%val%%";
        desktop.ojuny.dux.settings.widgetBackgroundCustomStrength = 0.5;

        # @option widget = "switch"; label = "Frame close gaps"; group = "Frame"; groupOrder = 55; advanced = true; description = "Fill the gaps between the frame strips."; applyCommand = "dms ipc call settings set frameCloseGaps %%val%%";
        desktop.ojuny.dux.settings.frameCloseGaps = true;

        # @option widget = "switch"; label = "Frame launcher arc extender"; group = "Frame"; groupOrder = 55; advanced = true; description = "Extend the launcher arc into the frame bar."; applyCommand = "dms ipc call settings set frameLauncherArcExtender %%val%%";
        desktop.ojuny.dux.settings.frameLauncherArcExtender = false;

        # @option widget = "switch"; label = "Frame launcher edge hover"; group = "Frame"; groupOrder = 55; advanced = true; description = "Open the launcher when hovering the frame edge."; applyCommand = "dms ipc call settings set frameLauncherEdgeHover %%val%%";
        desktop.ojuny.dux.settings.frameLauncherEdgeHover = false;

        # @option widget = "dropdown"; label = "Frame launcher emerge side"; group = "Frame"; groupOrder = 55; choices = [ "bottom" "top" ]; advanced = true; description = "Edge the frame launcher emerges from."; applyCommand = "dms ipc call settings set frameLauncherEmergeSide %%val%%";
        desktop.ojuny.dux.settings.frameLauncherEmergeSide = "bottom";

        # @option widget = "dropdown"; label = "Frame mode"; group = "Frame"; groupOrder = 55; choices = [ "connected" "separate" ]; advanced = true; description = "Draw the frame as one connected surface or as separate strips."; applyCommand = "dms ipc call settings set frameMode %%val%%";
        desktop.ojuny.dux.settings.frameMode = "connected";

        # @option widget = "switch"; label = "Frame on overview"; group = "Frame"; groupOrder = 55; advanced = true; description = "Keep the frame visible while the overview is open."; applyCommand = "dms ipc call settings set frameShowOnOverview %%val%%";
        desktop.ojuny.dux.settings.frameShowOnOverview = false;

        # @option widget = "spin"; label = "Tray tint saturation"; group = "System tray"; groupOrder = 65; min = 0; max = 100; advanced = true; description = "Saturation applied to tinted tray icons."; applyCommand = "dms ipc call settings set systemTrayIconTintSaturation %%val%%";
        desktop.ojuny.dux.settings.systemTrayIconTintSaturation = 50;

        # @option widget = "spin"; label = "Tray tint strength"; group = "System tray"; groupOrder = 65; min = 0; max = 200; advanced = true; description = "Strength applied to tinted tray icons."; applyCommand = "dms ipc call settings set systemTrayIconTintStrength %%val%%";
        desktop.ojuny.dux.settings.systemTrayIconTintStrength = 135;

        # @option widget = "list"; label = "Frame screens"; group = "Frame"; groupOrder = 55; advanced = true; description = "Screen names the frame is drawn on, or \"all\". Settings IPC rejects object values; write this one in the settings file.";
        desktop.ojuny.dux.settings.frameScreenPreferences = [ "all" ];

      };

    };

}
