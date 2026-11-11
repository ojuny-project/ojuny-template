/*
  @menu
  displayname = "Hardware profile";
  icon = "computer-symbolic";
  order = 46;
  description = "Detected hardware and nixos-hardware profile. Coverage: docs/hardware-coverage.md. Apply a change with: nix run .#regenerate-hardware -- --profile-only";
  category = "07-System";
  hidden = false;
*/

{ self, ... }:

{
  flake.modules.nixos.system-facter =
    { ... }:
    {
      imports = [ self.modules.nixos.system-facter-backend ];

      config = {
        # @option widget = "facter"; label = "Hardware profile"; description = "Reads the generated facter.json and shows the detected model, profile, coverage state and effective GPU. Apply a profile change with: nix run .#regenerate-hardware -- --profile-only";
        ojuny.hardware.profile = "auto";
      };
    };
}
