/*
  @menu
  displayname = "Dux tools";
  icon = "applications-utilities-symbolic";
  order = 10;
  description = "Search, files, calendar and system resource settings";
  category = "06-Utility";
*/

{ self, inputs, ... }: {

  flake.modules.nixos.desktop-dux-tools =
    { config, lib, ... }:
    {
      imports = [ self.modules.nixos.desktop-dux-tools-backend ];

      config = {
        # @option widget = "switch"; label = "Enable dsearch"; group = "Search"; groupOrder = 10; order = 10; description = "Run the dsearch indexer as a user service.";
        ojuny.tools.dsearch.enable = true;

        # @option widget = "list"; label = "Index paths"; group = "Search"; groupOrder = 10; order = 20; itemLabel = "Path"; addLabel = "Add path"; description = "Paths indexed by dsearch.";
        ojuny.tools.dsearch.indexPaths = [ "~" ];

        # @option widget = "spin"; label = "Max depth"; group = "Search"; groupOrder = 10; order = 30; min = 0; max = 64; description = "Maximum directory depth per index path. 0 means unlimited.";
        ojuny.tools.dsearch.maxDepth = 6;

        # @option widget = "switch"; label = "Exclude hidden"; group = "Search"; groupOrder = 10; order = 40;
        ojuny.tools.dsearch.excludeHidden = true;

        # @option widget = "switch"; label = "Extract EXIF"; group = "Search"; groupOrder = 10; order = 50;
        ojuny.tools.dsearch.extractExif = true;

        # @option widget = "spin"; label = "Workers"; group = "Search"; groupOrder = 10; order = 60; min = 1; max = 32;
        ojuny.tools.dsearch.workerCount = 4;

        # @option widget = "switch"; label = "HTTP API"; group = "Search"; groupOrder = 10; order = 70; description = "The HTTP API has no authentication. Leave off unless another client needs it.";
        ojuny.tools.dsearch.httpEnabled = false;

        # @option widget = "spin"; label = "Max file size"; group = "Search"; groupOrder = 10; order = 80; min = 1024; max = 1073741824; step = 1024; unit = "B"; 
        ojuny.tools.dsearch.maxFileBytes = 2097152;

        # @option widget = "dropdown"; label = "Theme"; group = "Files"; groupOrder = 20; order = 10; choices = [ "auto" "dark" "light" ];
        ojuny.tools.duxFiles.themeMode = "auto";

        # @option widget = "switch"; label = "Show title bar"; group = "Files"; groupOrder = 20; order = 15; description = "The Dux Files top bar is off by default. The app default is on.";
        ojuny.tools.duxFiles.showTitleBar = false;

        # @option widget = "dropdown"; label = "Default view"; group = "Files"; groupOrder = 20; order = 20; choices = [ "list" "grid" ];
        ojuny.tools.duxFiles.defaultView = "list";

        # @option widget = "switch"; label = "Show hidden files"; group = "Files"; groupOrder = 20; order = 30;
        ojuny.tools.duxFiles.showHidden = false;

        # @option widget = "switch"; label = "Folders first"; group = "Files"; groupOrder = 20; order = 40;
        ojuny.tools.duxFiles.foldersFirst = true;

        # @option widget = "switch"; label = "Confirm trash"; group = "Files"; groupOrder = 20; order = 50;
        ojuny.tools.duxFiles.confirmTrash = false;

        # @option widget = "text"; label = "Terminal"; group = "Files"; groupOrder = 20; order = 60; description = "Leave empty to auto-detect a terminal.";
        ojuny.tools.duxFiles.terminal = "";

        # @option widget = "switch"; label = "Register file manager"; group = "Files"; groupOrder = 20; order = 70;
        ojuny.tools.duxFiles.registerFileManager = true;

        # @option widget = "switch"; label = "Recent files"; group = "Files"; groupOrder = 20; order = 80;
        ojuny.tools.duxFiles.recentFiles = true;

        # @option widget = "list"; label = "Search excludes"; group = "Files"; groupOrder = 20; order = 90; advanced = true; itemLabel = "Name or path"; addLabel = "Add exclude";
        ojuny.tools.duxFiles.searchExcludes = [ ];

        # @option widget = "dropdown"; label = "Sort by"; group = "Files"; groupOrder = 20; order = 100; choices = [ "name" "size" "mtime" "type" ];
        ojuny.tools.duxFiles.defaultSort = "name";

        # @option widget = "switch"; label = "Sort descending"; group = "Files"; groupOrder = 20; order = 110;
        ojuny.tools.duxFiles.defaultSortDescending = false;

        # @option widget = "dropdown"; label = "Density"; group = "Files"; groupOrder = 20; order = 120; choices = [ "spacious" "comfortable" "compact" "dense" ];
        ojuny.tools.duxFiles.density = "comfortable";

        # @option widget = "switch"; label = "Show extensions"; group = "Files"; groupOrder = 20; order = 130;
        ojuny.tools.duxFiles.showExtensions = true;

        # @option widget = "switch"; label = "Remember folder views"; group = "Files"; groupOrder = 20; order = 140;
        ojuny.tools.duxFiles.rememberFolderViews = true;

        # @option widget = "switch"; label = "Folder counts"; group = "Files"; groupOrder = 20; order = 150;
        ojuny.tools.duxFiles.folderCounts = true;

        # @option widget = "dropdown"; label = "Click to open"; group = "Files"; groupOrder = 20; order = 160; choices = [ "single" "double" ];
        ojuny.tools.duxFiles.clickToOpen = "double";

        # @option widget = "switch"; label = "Thumbnails"; group = "Files"; groupOrder = 20; order = 170;
        ojuny.tools.duxFiles.thumbnails = true;

        # @option widget = "spin"; label = "Thumbnail size limit"; group = "Files"; groupOrder = 20; order = 180; min = 1; max = 10240; unit = "MB"; visibleWhen.path = "ojuny.tools.duxFiles.thumbnails"; visibleWhen.equals = true;
        ojuny.tools.duxFiles.thumbnailSizeLimitMb = 64;

        # @option widget = "switch"; label = "Collapse sidebar"; group = "Files"; groupOrder = 20; order = 190;
        ojuny.tools.duxFiles.sidebarCollapsed = false;

        # @option widget = "switch"; label = "Devices sidebar"; group = "Files"; groupOrder = 20; order = 200;
        ojuny.tools.duxFiles.showDevicesSidebar = true;

        # @option widget = "switch"; label = "Network sidebar"; group = "Files"; groupOrder = 20; order = 210;
        ojuny.tools.duxFiles.showNetworkSidebar = true;

        # @option widget = "switch"; label = "Games sidebar"; group = "Files"; groupOrder = 20; order = 220;
        ojuny.tools.duxFiles.showGamesSidebar = true;

        # @option widget = "dropdown"; label = "Close behavior"; group = "Files"; groupOrder = 20; order = 230; choices = [ "hide" "quit" ];
        ojuny.tools.duxFiles.closeBehavior = "quit";

        # @option widget = "text"; label = "Opener"; group = "Files"; groupOrder = 20; order = 240; description = "Leave empty to use the default application.";
        ojuny.tools.duxFiles.opener = "";

        # @option widget = "switch"; label = "Vim keys"; group = "Files"; groupOrder = 20; order = 250;
        ojuny.tools.duxFiles.vimKeys = false;

        # @option widget = "switch"; label = "Enable Dux Calendar"; group = "Calendar"; groupOrder = 30; order = 10; description = "Run the calendar daemon and install its session service.";
        ojuny.tools.calendar.enable = true;

        # @option widget = "dropdown"; label = "Time format"; group = "Calendar"; groupOrder = 30; order = 20; choices = [ "auto" "12h" "24h" ];
        ojuny.tools.calendar.timeFormat = "auto";

        # @option widget = "dropdown"; label = "First day of week"; group = "Calendar"; groupOrder = 30; order = 30; choices = [ "-1" "0" "1" "2" "3" "4" "5" "6" ]; description = "-1 follows the locale, 0 Sunday to 6 Saturday.";
        ojuny.tools.calendar.firstDayOfWeek = -1;

        # @option widget = "switch"; label = "Show tasks"; group = "Calendar"; groupOrder = 30; order = 40;
        ojuny.tools.calendar.showTasks = true;

        # @option widget = "switch"; label = "Reminders"; group = "Calendar"; groupOrder = 30; order = 50;
        ojuny.tools.calendar.remindersEnabled = true;

        # @option widget = "spin"; label = "Default reminder"; group = "Calendar"; groupOrder = 30; order = 60; min = 0; max = 1440; unit = "min";
        ojuny.tools.calendar.defaultReminderMinutes = 10;

        # @option widget = "spin"; label = "Snooze"; group = "Calendar"; groupOrder = 30; order = 70; min = 1; max = 1440; unit = "min";
        ojuny.tools.calendar.snoozeMinutes = 5;

        # @option widget = "switch"; label = "Notification sounds"; group = "Calendar"; groupOrder = 30; order = 80;
        ojuny.tools.calendar.notificationSounds = false;

        # @option widget = "switch"; label = "Week numbers"; group = "Calendar"; groupOrder = 30; order = 90;
        ojuny.tools.calendar.showWeekNumbers = false;

        # @option widget = "spin"; label = "Default event duration"; group = "Calendar"; groupOrder = 30; order = 100; min = 5; max = 1440; unit = "min";
        ojuny.tools.calendar.defaultEventDurationMinutes = 30;

        # @option widget = "switch"; label = "Persistent reminders"; group = "Calendar"; groupOrder = 30; order = 110;
        ojuny.tools.calendar.reminderPersist = true;

        # @option widget = "switch"; label = "All-day reminders"; group = "Calendar"; groupOrder = 30; order = 120;
        ojuny.tools.calendar.allDayReminders = false;

        # @option widget = "text"; label = "All-day reminder time"; group = "Calendar"; groupOrder = 30; order = 130; visibleWhen.path = "ojuny.tools.calendar.allDayReminders"; visibleWhen.equals = true; description = "Local time as HH:mm.";
        ojuny.tools.calendar.allDayReminderTime = "09:00";

        # @option widget = "dropdown"; label = "Close behavior"; group = "Calendar"; groupOrder = 30; order = 140; choices = [ "minimize" "quit" ];
        ojuny.tools.calendar.closeBehavior = "minimize";

        # @option widget = "switch"; label = "dgop HTTP API"; group = "System resources"; groupOrder = 40; order = 10; description = "Dux Modular Shell uses the embedded dgop library. Enable this only for clients that call the HTTP API.";
        ojuny.tools.gop.enable = false;

        # @option widget = "spin"; label = "API port"; group = "System resources"; groupOrder = 40; order = 20; min = 1024; max = 65535; visibleWhen.path = "ojuny.tools.gop.enable"; visibleWhen.equals = true;
        ojuny.tools.gop.apiPort = 63484;
      };
    };

}
