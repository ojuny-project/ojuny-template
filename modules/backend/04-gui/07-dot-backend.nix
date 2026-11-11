{ ... }: {

  flake.modules.nixos.desktop-dot-backend =
    { config, lib, ... }:

    let
      routeMap = {
        routeLauncher = "islandRouteLauncher";
        routeControlCenter = "islandRouteControlCenter";
        routeNotificationCenter = "islandRouteNotificationCenter";
        routeClipboard = "islandRouteClipboard";
        routePowerMenu = "islandRoutePowerMenu";
        routeDashboard = "islandRouteDash";
        routeMedia = "islandRouteMedia";
        routeWeather = "islandRouteWeather";
        routeWallpaper = "islandRouteWallpaper";
      };

      routesFor =
        settings:
        lib.mapAttrs' (
          option: route:
          lib.nameValuePair route (if settings.${option} then "island" else "follow")
        ) routeMap;
    in
    {
      options.ojuny.dux.dot = lib.mkOption {
        type = lib.types.toml;
        default = { };
        description = "Standalone dot bar config. Dux Modular Shell finds it through the dot flag and it never changes the selected bar.";
      };

      options.ojuny.dux.floatingIsland = lib.mkOption {
        type = lib.types.toml;
        default = { };
        description = "Standalone free-floating island bar config. Separate from the island inside the selected bar.";
      };

      config = {

        desktop.ojuny.dux.barConfigs.dot =
          removeAttrs config.ojuny.dux.dot (builtins.attrNames routeMap)
          // routesFor config.ojuny.dux.dot
          // {
            dot = true;
            island = false;
            visible = true;
            autoHide = false;
          };

        desktop.ojuny.dux.barConfigs.floatingIsland =
          removeAttrs config.ojuny.dux.floatingIsland (builtins.attrNames routeMap)
          // routesFor config.ojuny.dux.floatingIsland
          // {
            dot = false;
            island = true;
            islandFloating = true;
            islandPlacement = "free";
            visible = true;
            autoHide = false;
          };

      };
    };
}
