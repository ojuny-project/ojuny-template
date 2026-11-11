/*
  @menu
  displayname = "Dwindle layout";
  icon = "preferences-system-windows-symbolic";
  order = 40;
  description = "Dwindle tiling layout";
  category = "03-Desktop";
*/

{ self, inputs, ... }: {

  flake.modules.nixos.desktop-mangodwindle =
    { config, lib, ... }:
    {
      imports = [ self.modules.nixos.desktop-mangodwindle-backend ];

      config = {
        # Dwindle layout
        # @option widget = "slider"; label = "Split ratio"; group = "Dwindle layout"; min = 0.05; max = 0.95; step = 0.05; applyCommand = "mmsg dispatch setoption,dwindle_split_ratio,%%val%%";
        desktop.ojuny.mango.global.dwindle_split_ratio = 0.5;

        # @option widget = "switch"; label = "Split axis from cursor"; group = "Dwindle layout"; applyCommand = "mmsg dispatch setoption,dwindle_smart_split,$(case %%val%% in true) echo 1;; *) echo 0;; esac)";
        ojuny.mango.flag.dwindle_smart_split = false;

        # @option widget = "dropdown"; label = "Horizontal split position"; group = "Dwindle layout"; choices = [ "follow-cursor" "right" "left" ]; applyCommand = "case %%val%% in follow-cursor) v=0;; right) v=1;; left) v=2;; esac; mmsg dispatch setoption,dwindle_horizontal_split,$v";
        ojuny.mango.enum.dwindle_horizontal_split = "right";

        # @option widget = "dropdown"; label = "Vertical split position"; group = "Dwindle layout"; choices = [ "follow-cursor" "below" "above" ]; applyCommand = "case %%val%% in follow-cursor) v=0;; below) v=1;; above) v=2;; esac; mmsg dispatch setoption,dwindle_vertical_split,$v";
        ojuny.mango.enum.dwindle_vertical_split = "below";

        # @option widget = "switch"; label = "Preserve sibling split on close"; group = "Dwindle layout"; applyCommand = "mmsg dispatch setoption,dwindle_preserve_split,$(case %%val%% in true) echo 1;; *) echo 0;; esac)";
        ojuny.mango.flag.dwindle_preserve_split = true;

        # @option widget = "switch"; label = "Smart resize toward cursor"; group = "Dwindle layout"; applyCommand = "mmsg dispatch setoption,dwindle_smart_resize,$(case %%val%% in true) echo 1;; *) echo 0;; esac)";
        ojuny.mango.flag.dwindle_smart_resize = false;

        # @option widget = "switch"; label = "Two-zone drop preview"; group = "Dwindle layout"; applyCommand = "mmsg dispatch setoption,dwindle_drop_simple_split,$(case %%val%% in true) echo 1;; *) echo 0;; esac)";
        ojuny.mango.flag.dwindle_drop_simple_split = false;

        # @option widget = "switch"; label = "Manual split mode"; group = "Dwindle layout"; applyCommand = "mmsg dispatch setoption,dwindle_manual_split,$(case %%val%% in true) echo 1;; *) echo 0;; esac)";
        ojuny.mango.flag.dwindle_manual_split = false;
      };
    };
}
