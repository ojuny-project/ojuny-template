/*
  @menu
  displayname = "Monocle and deck";
  icon = "preferences-system-windows-symbolic";
  order = 35;
  description = "Monocle, deck and title message layout options";
  category = "03-Desktop";
*/

{ self, inputs, ... }: {

  flake.modules.nixos.desktop-monocledeck =
    { config, lib, ... }:
    {
      imports = [ self.modules.nixos.desktop-monocledeck-backend ];

      config = {
        # Monocle layout
        # @option widget = "switch"; label = "Tabbed monocle"; group = "Monocle layout"; groupOrder = 10; description = "Lay out monocle windows as tabs instead of stacked fullscreen."; applyCommand = "mmsg dispatch setoption,monocle_tab_mode,$(case %%val%% in true) echo 1;; *) echo 0;; esac)";
        ojuny.mango.flag.monocle_tab_mode = true;

        # @option widget = "switch"; label = "No border"; group = "Monocle layout"; groupOrder = 10; description = "Hide window borders in the monocle layout."; applyCommand = "mmsg dispatch setoption,monocle_no_border,$(case %%val%% in true) echo 1;; *) echo 0;; esac)";
        ojuny.mango.flag.monocle_no_border = false;

        # @option widget = "switch"; label = "No gaps"; group = "Monocle layout"; groupOrder = 10; description = "Remove gaps around monocle windows."; applyCommand = "mmsg dispatch setoption,monocle_no_gap,$(case %%val%% in true) echo 1;; *) echo 0;; esac)";
        ojuny.mango.flag.monocle_no_gap = false;

        # @option widget = "switch"; label = "No corner radius"; group = "Monocle layout"; groupOrder = 10; description = "Square off monocle window corners."; applyCommand = "mmsg dispatch setoption,monocle_no_radius,$(case %%val%% in true) echo 1;; *) echo 0;; esac)";
        ojuny.mango.flag.monocle_no_radius = false;

        # Deck layout
        # @option widget = "switch"; label = "Tabbed deck"; group = "Deck layout"; groupOrder = 20; description = "Lay out deck windows as tabs instead of a horizontal row."; applyCommand = "mmsg dispatch setoption,deck_tab_mode,$(case %%val%% in true) echo 1;; *) echo 0;; esac)";
        ojuny.mango.flag.deck_tab_mode = true;

        # @option widget = "switch"; label = "Right click closes tab"; group = "Monocle layout"; groupOrder = 10; description = "Right-clicking a tab in the monocle tab bar closes that window."; applyCommand = "mmsg dispatch setoption,monocle_right_button_close,$(case %%val%% in true) echo 1;; *) echo 0;; esac)";
        ojuny.mango.flag.monocle_right_button_close = false;

        # Title messages
        # @option widget = "spin"; label = "Title message bar height"; group = "Title messages"; groupOrder = 30; min = 0; max = 200; unit = "px"; description = "Height of the bar that shows title messages."; applyCommand = "mmsg dispatch setoption,title_message_bar_height,%%val%%";
        desktop.ojuny.mango.global.title_message_bar_height = 52;

        # @option widget = "spin"; label = "Title message bar gap"; group = "Title messages"; groupOrder = 30; min = 0; max = 200; unit = "px"; description = "Gap between the title message bar and the screen edge."; applyCommand = "mmsg dispatch setoption,title_message_bar_gap,%%val%%";
        desktop.ojuny.mango.global.title_message_bar_gap = 20;

        # @option widget = "spin"; label = "Border width"; group = "Title messages"; groupOrder = 30; advanced = true; min = 0; max = 20; unit = "px"; applyCommand = "mmsg dispatch setoption,title_message_bar_decorate_border_width,%%val%%";
        desktop.ojuny.mango.global.title_message_bar_decorate_border_width = 0;

        # @option widget = "spin"; label = "Corner radius"; group = "Title messages"; groupOrder = 30; advanced = true; min = 0; max = 50; unit = "px"; applyCommand = "mmsg dispatch setoption,title_message_bar_decorate_corner_radius,%%val%%";
        desktop.ojuny.mango.global.title_message_bar_decorate_corner_radius = 15;

        # @option widget = "spin"; label = "Horizontal padding"; group = "Title messages"; groupOrder = 30; advanced = true; min = 0; max = 64; unit = "px"; applyCommand = "mmsg dispatch setoption,title_message_bar_decorate_padding_x,%%val%%";
        desktop.ojuny.mango.global.title_message_bar_decorate_padding_x = 0;

        # @option widget = "spin"; label = "Vertical padding"; group = "Title messages"; groupOrder = 30; advanced = true; min = 0; max = 64; unit = "px"; applyCommand = "mmsg dispatch setoption,title_message_bar_decorate_padding_y,%%val%%";
        desktop.ojuny.mango.global.title_message_bar_decorate_padding_y = 0;

        # @option widget = "text"; label = "Font"; group = "Title messages"; groupOrder = 30; advanced = true; description = "Font description, for example monospace Bold 13."; applyCommand = "mmsg dispatch setoption,title_message_bar_decorate_font_desc,%%val%%";
        desktop.ojuny.mango.global.title_message_bar_decorate_font_desc = "monospace Bold 13";
      };
    };
}
