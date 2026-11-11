/*
  @menu
  displayname = "Gestures";
  icon = "input-touchpad-symbolic";
  order = 40;
  description = "Touchpad swipe gestures and swipe tuning";
  category = "02-Core";
*/

{ self, inputs, ... }: {

  flake.modules.nixos.desktop-gestures =
    { ... }:

    {
      imports = [ self.modules.nixos.desktop-gestures-backend ];

      config = {

        # @option widget = "table-attrset"; label = "Swipe gestures"; group = "Gestures"; groupOrder = 10; columns = [ "enable" "dispatcher" "args" ]; columnTypes = [ "bool" "str" "str" ];
        ojuny.mango.gesture = {
          "3-finger left swipe" = {
            enable = true;
            dispatcher = "viewtoright";
            args = "0";
          };
          "3-finger right swipe" = {
            enable = true;
            dispatcher = "viewtoleft";
            args = "0";
          };
          "3-finger down swipe" = {
            enable = true;
            dispatcher = "spawn";
            args = "dms ipc call spotlight toggle";
          };
          "3-finger up swipe" = {
            enable = true;
            dispatcher = "spawn";
            args = "dms ipc call dankMenu toggle root";
          };
          "4-finger left swipe" = {
            enable = false;
            dispatcher = "viewnext_have_client";
            args = "0";
          };
          "4-finger right swipe" = {
            enable = false;
            dispatcher = "viewprev_have_client";
            args = "0";
          };
          "4-finger down swipe" = {
            enable = false;
            dispatcher = "toggleoverview";
            args = "0";
          };
          "4-finger up swipe" = {
            enable = false;
            dispatcher = "toggleoverview";
            args = "0";
          };
        };

        # Swipe tuning
        # @option widget = "switch"; label = "Live gesture transitions"; group = "Swipe tuning"; groupOrder = 20; order = 10; description = "Follow the swipe while the fingers are still down."; applyCommand = "mmsg dispatch setoption,gesture_live,$(case %%val%% in true) echo 1;; *) echo 0;; esac)";
        ojuny.mango.flag.gesture_live = true;

        # @option widget = "spin"; label = "Swipe min threshold"; group = "Swipe tuning"; groupOrder = 20; order = 20; min = 0; max = 100; applyCommand = "mmsg dispatch setoption,swipe_min_threshold,%%val%%";
        desktop.ojuny.mango.global.swipe_min_threshold = 1;

        # @option widget = "spin"; label = "Gesture swipe distance"; group = "Swipe tuning"; groupOrder = 20; order = 30; min = 0; max = 2000; unit = "px"; applyCommand = "mmsg dispatch setoption,gesture_swipe_distance,%%val%%";
        desktop.ojuny.mango.global.gesture_swipe_distance = 300;

        # @option widget = "slider"; label = "Gesture cancel ratio"; group = "Swipe tuning"; groupOrder = 20; order = 40; min = 0.0; max = 1.0; step = 0.05; applyCommand = "mmsg dispatch setoption,gesture_swipe_cancel_ratio,%%val%%";
        desktop.ojuny.mango.global.gesture_swipe_cancel_ratio = 0.5;

        # @option widget = "spin"; label = "Gesture force-commit speed"; group = "Swipe tuning"; groupOrder = 20; order = 50; min = 0; max = 200; unit = "px"; applyCommand = "mmsg dispatch setoption,gesture_swipe_min_speed_to_force,%%val%%";
        desktop.ojuny.mango.global.gesture_swipe_min_speed_to_force = 10;

      };
    };

}
