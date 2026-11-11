{ inputs, ... }: {

  flake.modules.nixos.applications-appimage-raven-backend =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.ojuny.raven;

      ravenDiagnostics = ''
            echo "Raven revision: ${inputs.raven.rev or "unknown"}"
            echo "Raven package: ${config.programs.raven.package.unwrapped.version or "unknown"}"
            echo "System:"
            echo "  Architecture: $(uname -m)"
            echo "  Kernel: $(uname -srm)"
            grep -E '^(PRETTY_NAME|VERSION_ID|ID|ID_LIKE)=' /etc/os-release | sed 's/^/  /' || true
            echo "  CPU: $(grep -m1 'model name' /proc/cpuinfo | cut -d: -f2- | sed 's/^ *//')"
            grep -E '^(MemTotal|MemAvailable):' /proc/meminfo | sed 's/^/  /' || true
            lspci -nn 2>/dev/null | grep -Ei 'vga|3d|display' | sed 's/^/  GPU: /' || true
            echo "  Compositor: ''${XDG_CURRENT_DESKTOP:-unknown}"
            echo "  Session: ''${XDG_SESSION_TYPE:-unknown}"
            echo "Environment:"
            env | LC_ALL=C sort | grep -E '^(RAVEN_|WAYLAND_|XDG_|DISPLAY=|HOME=|PATH=|LANG=|LC_|DESKTOP_|DBUS_SESSION_BUS_ADDRESS=)' | sed 's/^/  /' || true
      '';

      ravenReport = pkgs.writeShellApplication {
        name = "ojuny-raven-report";
        runtimeInputs = [ pkgs.coreutils pkgs.yad ];
        text = ''
          if [ "$#" -lt 4 ]; then
            echo "usage: ojuny-raven-report REPORT APP WRAPPER STATUS [ARG...]" >&2
            exit 2
          fi
          report="$1"
          app="$2"
          wrapper="$3"
          status="$4"
          shift 4
          app_name="$(basename "$app")"

          if [ -n "''${OJUNY_RAVEN_SURVEY:-}" ]; then
            if [ -n "''${WAYLAND_DISPLAY:-}''${DISPLAY:-}" ]; then
              yad --text-info --title="Raven failed: $app_name (survey mode)" --filename="$report" --width=900 --height=600 --class=ojuny-raven-report --name=ojuny-raven-report --center --on-top --button="Close:0" || true
            else
              cat "$report" >&2
            fi
            exit 0
          fi

          if [ -z "''${WAYLAND_DISPLAY:-}''${DISPLAY:-}" ] || [ -t 2 ]; then
            cat "$report" >&2
            exit 0
          fi

          set +e
          yad --text-info --title="Raven failed: $app_name (exit $status)" --filename="$report" --width=900 --height=600 --class=ojuny-raven-report --name=ojuny-raven-report --center --on-top \
            --button="Close:0" --button="Relaunch in survey mode:3"
          choice=$?
          set -e

          if [ "$choice" -ne 3 ]; then
            exit 0
          fi

          set +e
          yad --title="Raven survey mode" --class=ojuny-raven-report --name=ojuny-raven-report --center --on-top \
            --text="This may break your Raven configuration and might result in undefined behaviour.

Are you really sure?" \
            --button="Cancel:1" --button="Relaunch:0"
          confirm=$?
          set -e

          if [ "$confirm" -ne 0 ]; then
            exit 0
          fi

          export RAVEN_SURVEY_MISSING=1
          export OJUNY_RAVEN_SURVEY=1
          exec "$wrapper" "$@"
        '';
      };

      ravenRefresh = pkgs.writeShellApplication {
        name = "ojuny-raven-refresh";
        runtimeInputs = [
          pkgs.coreutils
          pkgs.findutils
          pkgs.gnugrep
          pkgs.gnused
          pkgs.util-linux
          pkgs.desktop-file-utils
        ];
        text = ''
          prefix="''${RAVEN_PREFIX:-$HOME/.local/share/raven/default}"
          drive="$prefix/drive_c"
          [ -d "$drive" ] || exit 0

          applications="''${XDG_DATA_HOME:-$HOME/.local/share}/applications"
          mkdir -p "$applications"
          rm -f "$applications"/ojuny-raven-*.desktop

          roots=()
          for root in \
            "$drive/Program Files" \
            "$drive/Program Files (x86)" \
            "$drive/ProgramData/Microsoft/Windows/Start Menu/Programs" \
            "$drive/Users/Public/Desktop"; do
            if [ -d "$root" ]; then
              roots+=("$root")
            fi
          done
          for root in "$drive"/Users/*/AppData/Local/Programs; do
            if [ -d "$root" ]; then
              roots+=("$root")
            fi
          done
          [ "''${#roots[@]}" -gt 0 ] || exit 0

          while IFS= read -r -d "" exe; do
            base="$(basename "$exe")"
            case "$base" in
              unins*|setup*|update*|crashpad*|helper*|*.tmp) continue ;;
            esac
            name="$(basename "$(dirname "$exe")")"
            if [ "$name" = "Program Files" ]; then
              name="''${base%.exe}"
            fi
            exec_path="''${exe//%/%%}"
            hash="$(printf '%s' "$exe" | sha256sum | cut -c1-16)"
            {
              echo "[Desktop Entry]"
              echo "Type=Application"
              echo "Name=$name"
              echo "Comment=Installed Windows application (Raven)"
              echo "Exec=/run/current-system/sw/bin/ojuny-raven \"$exec_path\""
              echo "Icon=application-x-executable"
              echo "Terminal=false"
              echo "Categories=Utility;"
              echo "NoDisplay=false"
            } > "$applications/ojuny-raven-$hash.desktop"
          done < <(find "''${roots[@]}" -type f -iname '*.exe' -print0 2>/dev/null)

          update-desktop-database "$applications" >/dev/null 2>&1 || true
        '';
      };

      ravenRun = pkgs.writeShellApplication {
        name = "ojuny-raven";
        runtimeInputs = [ pkgs.coreutils pkgs.gnused pkgs.gnugrep pkgs.pciutils ];
        text = ''
          if [ "$#" -eq 0 ]; then
            echo "usage: ojuny-raven FILE.exe" >&2
            exit 2
          fi
          original_args=("$@")
          host_file="$(realpath -- "$1")"
          shift
          win_dir="Z:$(dirname -- "$host_file" | sed 's|/|\\|g')"
          log_dir="''${XDG_STATE_HOME:-$HOME/.local/state}/ojuny/raven"
          mkdir -p "$log_dir"
          log="$log_dir/last.log"
          {
            echo "Raven launch"
            echo "Time: $(date -Is)"
            echo "Application: $host_file"
            echo "Wrapper: $0"
            echo "Raven command: ${config.programs.raven.package}/bin/raven --run-process --execution=native --timeout-ms=86400000 --desktop=wayland --directory=$win_dir $host_file"
            ${ravenDiagnostics}
            echo "Report this at https://github.com/mirkobrombin/raven/issues"
            echo
            echo "--- output ---"
          } > "$log"

          if [ -t 1 ] || [ -t 2 ]; then
            set +e
            ${config.programs.raven.package}/bin/raven --run-process --execution=native --timeout-ms=86400000 --desktop=wayland --directory="$win_dir" "$host_file" "$@" 2>&1 | tee -a "$log"
            status="''${PIPESTATUS[0]}"
            set -e
          else
            set +e
            ${config.programs.raven.package}/bin/raven --run-process --execution=native --timeout-ms=86400000 --desktop=wayland --directory="$win_dir" "$host_file" "$@" >> "$log" 2>&1
            status=$?
            set -e
          fi

          if [ "$status" -eq 0 ]; then
            ${ravenRefresh}/bin/ojuny-raven-refresh >/dev/null 2>&1 || true
            exit 0
          fi
          echo "Exit status: $status" >> "$log"
          if [ -t 1 ] || [ -t 2 ]; then
            exit "$status"
          fi
          report="$log_dir/$(date +%Y%m%d-%H%M%S)-failure.log"
          cp "$log" "$report"
          echo "Report file: $report" >> "$report"
          ${ravenReport}/bin/ojuny-raven-report "$report" "$host_file" "$0" "$status" "''${original_args[@]}"
          exit "$status"
        '';
      };

      ravenDesktop = pkgs.makeDesktopItem {
        name = "ojuny-raven";
        exec = "${ravenRun}/bin/ojuny-raven %f";
        desktopName = "Raven (experimental)";
        genericName = "Windows application runtime";
        comment = "Optional experimental runtime for Windows .exe files. Not guaranteed to run a given program.";
        noDisplay = true;
        icon = "application-x-executable";
        mimeTypes = [ "application/x-ms-dos-executable" ];
        categories = [ "Utility" ];
      };

      ravenMsiRun = pkgs.writeShellApplication {
        name = "ojuny-raven-msi";
        runtimeInputs = [ pkgs.coreutils pkgs.gnused pkgs.gnugrep pkgs.pciutils ];
        text = ''
          if [ "$#" -eq 0 ]; then
            echo "usage: ojuny-raven-msi FILE.msi" >&2
            exit 2
          fi
          original_args=("$@")
          host_file="$(realpath -- "$1")"
          shift
          win_file="Z:$(printf '%s' "$host_file" | sed 's|/|\\|g')"
          win_dir="Z:$(dirname -- "$host_file" | sed 's|/|\\|g')"
          log_dir="''${XDG_STATE_HOME:-$HOME/.local/state}/ojuny/raven"
          mkdir -p "$log_dir"
          log="$log_dir/last-msi.log"
          {
            echo "Raven MSI launch"
            echo "Time: $(date -Is)"
            echo "Application: $host_file"
            echo "Wrapper: $0"
            echo "Raven command: ${config.programs.raven.package}/bin/raven --run-process --execution=native --timeout-ms=86400000 --desktop=wayland --directory=$win_dir ${config.programs.raven.package.unwrapped}/libexec/raven/msiexec.exe -- /i $win_file"
            ${ravenDiagnostics}
            echo "Report this at https://github.com/mirkobrombin/raven/issues"
            echo
            echo "--- output ---"
          } > "$log"

          if [ -t 1 ] || [ -t 2 ]; then
            set +e
            ${config.programs.raven.package}/bin/raven --run-process --execution=native --timeout-ms=86400000 --desktop=wayland --directory="$win_dir" ${config.programs.raven.package.unwrapped}/libexec/raven/msiexec.exe -- /i "$win_file" 2>&1 | tee -a "$log"
            status="''${PIPESTATUS[0]}"
            set -e
          else
            set +e
            ${config.programs.raven.package}/bin/raven --run-process --execution=native --timeout-ms=86400000 --desktop=wayland --directory="$win_dir" ${config.programs.raven.package.unwrapped}/libexec/raven/msiexec.exe -- /i "$win_file" >> "$log" 2>&1
            status=$?
            set -e
          fi

          if [ "$status" -eq 0 ]; then
            ${ravenRefresh}/bin/ojuny-raven-refresh >/dev/null 2>&1 || true
            exit 0
          fi
          echo "Exit status: $status" >> "$log"
          if [ -t 1 ] || [ -t 2 ]; then
            exit "$status"
          fi
          report="$log_dir/$(date +%Y%m%d-%H%M%S)-msi-failure.log"
          cp "$log" "$report"
          echo "Report file: $report" >> "$report"
          ${ravenReport}/bin/ojuny-raven-report "$report" "$host_file" "$0" "$status" "''${original_args[@]}"
          exit "$status"
        '';
      };

      ravenMsiDesktop = pkgs.makeDesktopItem {
        name = "ojuny-raven-msi";
        exec = "${ravenMsiRun}/bin/ojuny-raven-msi %f";
        desktopName = "Raven MSI installer (experimental)";
        genericName = "Windows Installer package";
        comment = "Optional experimental Raven handler for .msi packages. Not guaranteed to run a given installer.";
        noDisplay = true;
        icon = "application-x-executable";
        mimeTypes = [ "application/x-msi" ];
        categories = [ "Utility" ];
      };

      ravenBatRun = pkgs.writeShellApplication {
        name = "ojuny-raven-bat";
        runtimeInputs = [ pkgs.coreutils pkgs.gnused pkgs.gnugrep pkgs.pciutils ];
        text = ''
          if [ "$#" -eq 0 ]; then
            echo "usage: ojuny-raven-bat FILE.bat" >&2
            exit 2
          fi
          original_args=("$@")
          host_file="$(realpath -- "$1")"
          shift
          win_file="Z:$(printf '%s' "$host_file" | sed 's|/|\\|g')"
          win_dir="Z:$(dirname -- "$host_file" | sed 's|/|\\|g')"
          log_dir="''${XDG_STATE_HOME:-$HOME/.local/state}/ojuny/raven"
          mkdir -p "$log_dir"
          log="$log_dir/last-bat.log"
          {
            echo "Raven batch launch"
            echo "Time: $(date -Is)"
            echo "Application: $host_file"
            echo "Wrapper: $0"
            echo "Raven command: ${config.programs.raven.package}/bin/raven --run-process --execution=native --timeout-ms=86400000 --desktop=wayland --directory=$win_dir ${config.programs.raven.package.unwrapped}/libexec/raven/cmd.exe -- /c $win_file"
            ${ravenDiagnostics}
            echo "Report this at https://github.com/mirkobrombin/raven/issues"
            echo
            echo "--- output ---"
          } > "$log"

          if [ -t 1 ] || [ -t 2 ]; then
            set +e
            ${config.programs.raven.package}/bin/raven --run-process --execution=native --timeout-ms=86400000 --desktop=wayland --directory="$win_dir" ${config.programs.raven.package.unwrapped}/libexec/raven/cmd.exe -- /c "$win_file" 2>&1 | tee -a "$log"
            status="''${PIPESTATUS[0]}"
            set -e
          else
            set +e
            ${config.programs.raven.package}/bin/raven --run-process --execution=native --timeout-ms=86400000 --desktop=wayland --directory="$win_dir" ${config.programs.raven.package.unwrapped}/libexec/raven/cmd.exe -- /c "$win_file" >> "$log" 2>&1
            status=$?
            set -e
          fi

          if [ "$status" -eq 0 ]; then
            ${ravenRefresh}/bin/ojuny-raven-refresh >/dev/null 2>&1 || true
            exit 0
          fi
          echo "Exit status: $status" >> "$log"
          if [ -t 1 ] || [ -t 2 ]; then
            exit "$status"
          fi
          report="$log_dir/$(date +%Y%m%d-%H%M%S)-bat-failure.log"
          cp "$log" "$report"
          echo "Report file: $report" >> "$report"
          ${ravenReport}/bin/ojuny-raven-report "$report" "$host_file" "$0" "$status" "''${original_args[@]}"
          exit "$status"
        '';
      };

      ravenBatDesktop = pkgs.makeDesktopItem {
        name = "ojuny-raven-bat";
        exec = "${ravenBatRun}/bin/ojuny-raven-bat %f";
        desktopName = "Raven batch file (experimental)";
        genericName = "Windows batch file";
        comment = "Optional experimental Raven handler for .bat files. Interactive scripts need a terminal and behavior is not guaranteed.";
        noDisplay = true;
        terminal = true;
        icon = "application-x-executable";
        mimeTypes = [ "application/x-bat" ];
        categories = [ "Utility" ];
      };
    in
    {
      config = {
        programs.raven.enable = cfg.enable;

        desktop.ojuny.mango.rules.window_rule = lib.mkIf cfg.enable [
          {
            app_id = "ojuny-raven-report";
            is_floating = 1;
          }
        ];

        environment.systemPackages = lib.mkIf cfg.enable [
          ravenRefresh
          ravenReport
          ravenRun
          ravenDesktop
          ravenMsiRun
          ravenMsiDesktop
          ravenBatRun
          ravenBatDesktop
        ];

        system.activationScripts.ojuny-raven-refresh = lib.mkIf cfg.enable {
          deps = [ "users" ];
          text = lib.concatMapStrings (
            user:
            ''
              if [ -d ${lib.escapeShellArg user.home} ]; then
                ${pkgs.util-linux}/bin/runuser -u ${lib.escapeShellArg user.name} -- ${pkgs.coreutils}/bin/env HOME=${lib.escapeShellArg user.home} ${ravenRefresh}/bin/ojuny-raven-refresh >/dev/null 2>&1 || true
              fi
            ''
          ) (lib.filter (user: user.isNormalUser && user.home != "/") (lib.attrValues config.users.users));
        };

        xdg.mime.defaultApplications = lib.mkIf cfg.enable {
          "application/x-ms-dos-executable" = lib.mkDefault "ojuny-raven.desktop";
          "application/x-msi" = lib.mkDefault "ojuny-raven-msi.desktop";
          "application/x-bat" = lib.mkDefault "ojuny-raven-bat.desktop";
        };
      };
    };

}
