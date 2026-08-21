{
  flake.nixosModules.gog-wine =
    { self', username, ... }:
    {
      home-manager.users.${username}.home.packages = [ self'.packages.gog-wine-install ];
    };

  perSystem = { unstable, ... }: {
    packages.gog-wine-install = unstable.callPackage
      ({ writeShellApplication
       , innoextract
       , umu-launcher
       , proton-ge-bin
       , jq
       , coreutils
       , findutils
       , gnugrep
       , gnused
       , gawk
       , desktop-file-utils
       ,
       }:

        writeShellApplication {
          name = "gog-wine-install";

          runtimeInputs = [
            innoextract
            jq
            coreutils
            findutils
            gnugrep
            gnused
            gawk
            desktop-file-utils
          ];

          text = ''
            UMU_RUN="${umu-launcher}/bin/umu-run"
            PROTON_DEFAULT="${proton-ge-bin.steamcompattool}"

            ROOT="''${GOG_WINE_ROOT:-$HOME/Games/gog}"
            LAUNCH_DIR="''${GOG_WINE_LAUNCH_DIR:-$HOME/Games/launch}"
            APPS_DIR="''${XDG_DATA_HOME:-$HOME/.local/share}/applications"

            die() { echo "gog-wine-install: $*" >&2; exit 1; }

            usage() {
              cat <<'USAGE'
            Usage: gog-wine-install --game <setup.exe> [--dlc <path>]...

            Install a GOG.com Windows game into its own Proton prefix, unpacked where
            Windows would put it (C:\GOG Games\<Name>), and generate a launcher.

            Options:
              --game <setup.exe>    Base game installer. Multi-part .bin slices are
                                    picked up automatically from beside it. Required.
              --dlc <path>          A DLC .exe, or a directory whose *.exe files are
                                    all installed into the same game directory.
                                    May be given more than once.
              --name <str>          Override the Windows install directory name.
              --exe <rel/path.exe>  Override the executable the launcher runs.
              --gameid <id>         Override the umu GAMEID (default umu-<gog id>).
              --force               Re-extract installers already recorded as done.
              --no-desktop          Skip launcher wrapper and .desktop generation.
              --no-merge-app        Keep the extracted app/ subdirectory as-is instead
                                    of merging it into the game root.
              -h, --help            Show this help.

            Environment:
              GOG_WINE_ROOT         Prefix root        (default ~/Games/gog)
              GOG_WINE_LAUNCH_DIR   Launcher scripts   (default ~/Games/launch)
              PROTONPATH            Proton to use      (default bundled GE-Proton)
            USAGE
            }

            GAME_INSTALLER=""
            NAME_OVERRIDE=""
            EXE_OVERRIDE=""
            GAMEID_OVERRIDE=""
            FORCE=0
            MAKE_DESKTOP=1
            MERGE_APP=1
            DLC_ARGS=()

            need() { [ "$1" -ge 2 ] || die "$2 requires an argument"; }

            while [ $# -gt 0 ]; do
              case "$1" in
                --game)       need $# --game;    GAME_INSTALLER="$2";   shift 2 ;;
                --dlc)        need $# --dlc;     DLC_ARGS+=("$2");      shift 2 ;;
                --name)       need $# --name;    NAME_OVERRIDE="$2";    shift 2 ;;
                --exe)        need $# --exe;     EXE_OVERRIDE="$2";     shift 2 ;;
                --gameid)     need $# --gameid;  GAMEID_OVERRIDE="$2";  shift 2 ;;
                --force)      FORCE=1;      shift ;;
                --no-desktop)  MAKE_DESKTOP=0; shift ;;
                --no-merge-app) MERGE_APP=0;   shift ;;
                -h|--help)    usage; exit 0 ;;
                *) echo "gog-wine-install: unknown argument: $1" >&2; usage >&2; exit 2 ;;
              esac
            done

            [ -n "$GAME_INSTALLER" ] || { usage >&2; die "--game is required"; }
            [ -f "$GAME_INSTALLER" ] || die "not a file: $GAME_INSTALLER"
            GAME_INSTALLER="$(realpath "$GAME_INSTALLER")"

            NAME="$(innoextract -i --color=0 "$GAME_INSTALLER" 2>/dev/null |
                      sed -n 's/^Inspecting "\(.*\)" - .*$/\1/p' | head -n1)"
            GOGID="$(innoextract --gog-game-id --silent "$GAME_INSTALLER" 2>/dev/null |
                       tr -cd '[:alnum:]')"

            [ -n "$GOGID" ] ||
              die "could not read a GOG game id from $(basename "$GAME_INSTALLER"); is this a GOG installer?"

            [ -z "$NAME_OVERRIDE" ] || NAME="$NAME_OVERRIDE"
            [ -n "$NAME" ] || die "could not determine the game name; pass --name"
            # Strip characters that are illegal in Windows paths; GOG names carry ™, : etc.
            NAME="$(printf '%s' "$NAME" | tr -d '\\/:*?"<>|' | sed 's/[[:space:]]*$//')"

            SLUG="$(printf '%s' "$NAME" | tr '[:upper:]' '[:lower:]' |
                      sed -e 's/[^a-z0-9]\+/-/g' -e 's/^-//' -e 's/-$//')"
            [ -n "$SLUG" ] || die "could not derive a slug from the game name '$NAME'"

            GAME_ROOT="$ROOT/$SLUG"
            PREFIX="$GAME_ROOT/prefix"
            DRIVE_C="$PREFIX/pfx/drive_c"
            GAMEDIR="$DRIVE_C/GOG Games/$NAME"
            MANIFEST="$GAME_ROOT/.installed"
            GAMEID="''${GAMEID_OVERRIDE:-umu-$GOGID}"
            PROTON="''${PROTONPATH:-$PROTON_DEFAULT}"

            echo "==> $NAME (gog id $GOGID, slug $SLUG)"
            echo "    prefix: $PREFIX"
            echo "    game:   $GAMEDIR"

            mkdir -p "$GAME_ROOT" "$LAUNCH_DIR"

            avail_kb="$(df -Pk "$GAME_ROOT" | awk 'NR==2 {print $4}')"
            if [ "''${avail_kb:-0}" -lt 5242880 ]; then
              echo "    warning: only $((avail_kb / 1048576)) GiB free on $GAME_ROOT" >&2
            fi

            if [ ! -d "$PREFIX/pfx" ]; then
              echo "==> creating Proton prefix (first run downloads the Steam Linux Runtime)"
              # createprefix hands Proton an empty EXE, so Proton bootstraps the
              # prefix and then exits non-zero complaining it cannot find it. That
              # is umu's documented behaviour; judge success by the prefix instead.
              WINEPREFIX="$PREFIX" GAMEID="$GAMEID" STORE=gog PROTONPATH="$PROTON" \
                "$UMU_RUN" createprefix || true
              [ -d "$PREFIX/pfx" ] ||
                die "Proton did not create a prefix at $PREFIX (note: umu runs inside a bubblewrap sandbox with a private /tmp, so GOG_WINE_ROOT must live under \$HOME)"
            fi

            installers=("$GAME_INSTALLER")
            for d in "''${DLC_ARGS[@]}"; do
              if [ -d "$d" ]; then
                while IFS= read -r -d "" f; do
                  installers+=("$f")
                done < <(find "$d" -maxdepth 1 -type f -iname '*.exe' -print0 | sort -z)
              elif [ -f "$d" ]; then
                installers+=("$(realpath "$d")")
              else
                die "--dlc: no such file or directory: $d"
              fi
            done

            mkdir -p "$GAMEDIR"
            touch "$MANIFEST"

            for installer in "''${installers[@]}"; do
              base="$(basename "$installer")"
              if [ "$FORCE" -eq 0 ] && grep -qxF "$base" "$MANIFEST"; then
                echo "==> skip (already installed): $base"
                continue
              fi
              echo "==> extracting: $base"
              innoextract --gog --exclude-temp --collisions=overwrite \
                -d "$GAMEDIR" "$installer"
              grep -qxF "$base" "$MANIFEST" || printf '%s\n' "$base" >> "$MANIFEST"
            done

            # innoextract drops {app} at the output root but gives other Inno
            # constants their own sibling directories; put those where Windows wants.
            if [ -d "$GAMEDIR/commonappdata" ]; then
              echo "==> relocating commonappdata -> C:\\ProgramData"
              mkdir -p "$DRIVE_C/ProgramData"
              cp -a "$GAMEDIR/commonappdata/." "$DRIVE_C/ProgramData/"
              rm -rf "$GAMEDIR/commonappdata"
            fi
            rm -rf "$GAMEDIR/tmp"

            # innoextract renders most {app} entries at the output root, but some land
            # in a literal app/ subdirectory instead (Stellaris ships five 0-byte
            # placeholders that way, and the game reports them missing if left there).
            # Merge them back up, but never clobber a file that is already at the root.
            if [ "$MERGE_APP" -eq 1 ] && [ -d "$GAMEDIR/app" ]; then
              conflicts=0
              while IFS= read -r -d "" f; do
                rel="''${f#"$GAMEDIR/app/"}"
                if [ -e "$GAMEDIR/$rel" ]; then
                  echo "    warning: app/$rel also exists at the game root" >&2
                  conflicts=$((conflicts + 1))
                fi
              done < <(find "$GAMEDIR/app" -type f -print0)

              if [ "$conflicts" -eq 0 ]; then
                n="$(find "$GAMEDIR/app" -type f | wc -l)"
                echo "==> merging app/ into the game root ($n files)"
                cp -a "$GAMEDIR/app/." "$GAMEDIR/"
                rm -rf "$GAMEDIR/app"
              else
                echo "    warning: leaving $GAMEDIR/app in place ($conflicts conflicts); pass --no-merge-app to silence" >&2
              fi
            fi

            INFO="$GAMEDIR/goggame-$GOGID.info"
            GAME_TITLE="$NAME"
            EXE=""

            if [ -n "$EXE_OVERRIDE" ]; then
              EXE="$EXE_OVERRIDE"
            elif [ -f "$INFO" ]; then
              EXE="$(jq -r '
                [.playTasks[]? | select(.category == "game")] as $t
                | (($t | map(select(.isPrimary == true)) | first) // ($t | first))
                | .path // empty' "$INFO")"
            fi
            [ -n "$EXE" ] || die "could not determine the executable to launch; pass --exe"
            EXE="''${EXE//\\//}"

            if [ -f "$INFO" ]; then
              t="$(jq -r '.name // empty' "$INFO")"
              if [ -n "$t" ]; then GAME_TITLE="$t"; fi
            fi

            ICON=""
            if [ -f "$GAMEDIR/app/goggame-$GOGID.ico" ]; then
              ICON="$GAMEDIR/app/goggame-$GOGID.ico"
            fi

            jq -n \
              --arg name "$GAME_TITLE" --arg slug "$SLUG" --arg gogId "$GOGID" \
              --arg gameId "$GAMEID" --arg prefix "$PREFIX" --arg gameDir "$GAMEDIR" \
              --arg exe "$EXE" --arg proton "$PROTON" --arg icon "$ICON" \
              '$ARGS.named' > "$GAME_ROOT/meta.json"

            if [ "$MAKE_DESKTOP" -eq 1 ]; then
              WRAPPER="$LAUNCH_DIR/$SLUG"
              cat > "$WRAPPER" <<EOF
            #!/bin/sh
            # Generated by gog-wine-install for $GAME_TITLE. Re-run it to regenerate.
            # With no arguments this launches the game; anything else runs in the same
            # prefix instead, e.g. \`$SLUG winecfg\` or \`$SLUG ./other.exe\`.
            export WINEPREFIX="$PREFIX"
            export GAMEID="$GAMEID"
            export STORE="gog"
            export PROTONPATH="\''${PROTONPATH:-$PROTON}"
            cd "$GAMEDIR" || exit 1
            [ \$# -gt 0 ] && exec "$UMU_RUN" "\$@"
            exec "$UMU_RUN" "./$EXE"
            EOF
              chmod +x "$WRAPPER"

              DESKTOP="$LAUNCH_DIR/$SLUG.desktop"
              {
                echo "[Desktop Entry]"
                echo "Type=Application"
                echo "Name=$GAME_TITLE"
                echo "Comment=GOG.com Windows game running under Proton"
                echo "Exec=$WRAPPER"
                echo "Path=$GAMEDIR"
                [ -z "$ICON" ] || echo "Icon=$ICON"
                echo "Terminal=false"
                echo "StartupNotify=true"
                echo "Categories=Game;"
              } > "$DESKTOP"

              mkdir -p "$APPS_DIR"
              ln -sfn "$DESKTOP" "$APPS_DIR/gog-$SLUG.desktop"
              if command -v update-desktop-database >/dev/null 2>&1; then
                update-desktop-database "$APPS_DIR" || true
              fi

              echo "==> launcher: $WRAPPER"
              echo "==> desktop:  $APPS_DIR/gog-$SLUG.desktop"
            fi

            echo "==> done: $GAME_TITLE"
          '';

          meta = {
            description = "Install a GOG.com Windows game into its own Proton prefix";
            mainProgram = "gog-wine-install";
            platforms = [ "x86_64-linux" ];
          };
        })
      { };
  };
}
