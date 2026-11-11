/*
  @menu
  displayname = "Multimedia";
  icon = "applications-multimedia-symbolic";
  order = 20;
  description = "Video, audio, image and creative applications. Craft app theming is deferred to the upstream craft-app PR.";
  category = "05-Applications";
*/

{ self, inputs, ... }: {

  flake.modules.nixos.applications-multimedia =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      imports = [
        self.modules.nixos.applications-multimedia-apps
        self.modules.nixos.applications-multimedia-backend
      ];

      config = {
        ojuny.apps.multimedia = {
          # @option widget = "dropdown"; label = "Media player"; group = "Viewers"; groupOrder = 10; order = 10; choices = [ "none" "mpv" "vlc" "haruna" ]; description = "Media player installed for local video and audio files.";
          player = "mpv";
          # @option widget = "dropdown"; label = "Image viewer"; group = "Viewers"; groupOrder = 10; order = 20; choices = [ "none" "imv" "qimgv" "gwenview" ]; description = "Image viewer for common image formats.";
          imageViewer = "imv";
          # @option widget = "switch"; label = "OBS Studio"; group = "Tools"; groupOrder = 20; order = 10;
          obs = false;
          # @option widget = "switch"; label = "Audacity"; group = "Tools"; groupOrder = 20; order = 20;
          audacity = false;
          # @option widget = "switch"; label = "GIMP"; group = "Tools"; groupOrder = 20; order = 30;
          gimp = false;
          # @option widget = "switch"; label = "Krita"; group = "Creative"; groupOrder = 30; order = 10; description = "Digital painting, themed through the Stylix Qt and KDE targets.";
          krita = false;
          # @option widget = "switch"; label = "Kdenlive"; group = "Creative"; groupOrder = 30; order = 20; description = "Video editor, themed through the Stylix Qt and KDE targets.";
          kdenlive = false;
          # @option widget = "switch"; label = "Blender"; group = "Creative"; groupOrder = 30; order = 30; description = "3D creation suite, themed through the Stylix Blender target.";
          blender = false;
          # @option widget = "dropdown"; label = "Calculator"; group = "Calculator"; groupOrder = 40; order = 10; choices = [ "none" "gnome-calculator" "qalculate-gtk" ]; description = "Calculator installed for quick arithmetic. No file type is associated with it.";
          calculator = "none";
        };

        # @option widget = "packages"; label = "Multimedia tools"; group = "Tools"; groupOrder = 20;
        environment.systemPackages = with pkgs; [
          ffmpeg
          imagemagick
          yt-dlp
          satty
        ];
      };
    };

}
