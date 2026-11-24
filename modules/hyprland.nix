{ pkgs, ... }:
let
  japanFont = pkgs.google-fonts.override { fonts = [ "ShipporiMincho" ]; };

  # Wallpaper: dunkelroter Verlauf mit Blutmond und 戦え (Tatakae, "Kämpfe!")
  wallpaper = pkgs.runCommand "sumi-wallpaper.png" { nativeBuildInputs = [ pkgs.imagemagick ]; } ''
    magick -size 1920x1080 -define gradient:center=1380,520 -define gradient:radii=1350,1350 radial-gradient:'#5a0a18-#0d0406' \
      -fill '#B3001B' -draw 'circle 1380,520 1380,220' \
      -font ${japanFont}/share/fonts/truetype/ShipporiMincho-Bold.ttf \
      -fill '#0D0406' -pointsize 230 -gravity center -annotate +420-140 '戦' -annotate +420+100 'え' \
      png:$out
  '';

  # Super + Enter: Terminal mit zufälligem Hintergrund-Effekt
  terminalZufall = pkgs.writeShellScript "terminal-zufall" ''
    effekte=(
      ${./terminal-effekte/higanbana.glsl}
      ${./terminal-effekte/tusche.glsl}
      ${./terminal-effekte/glut.glsl}
      ${./terminal-effekte/schrift.glsl}
    )
    exec ${pkgs.ghostty}/bin/ghostty --gtk-single-instance=false \
      --custom-shader="''${effekte[RANDOM % ''${#effekte[@]}]}" "$@"
  '';

  # Super + A: Effekte in allen Terminals an/aus (die Datei überschreibt den Shader)
  effekteUmschalten = pkgs.writeShellScript "effekte-umschalten" ''
    aus="$HOME/.local/state/ghostty/effekte-aus.conf"
    ${pkgs.coreutils}/bin/mkdir -p "$HOME/.local/state/ghostty"
    if [ -e "$aus" ]; then
      ${pkgs.coreutils}/bin/rm "$aus"
    else
      echo "custom-shader =" > "$aus"
    fi
    ${pkgs.procps}/bin/pkill -USR2 -x '.ghostty-wrappe'
  '';

  # Bootscreen: 戦え pulsiert auf Schwarzrot
  tatakaeBoot = pkgs.runCommand "tatakae-plymouth" { nativeBuildInputs = [ pkgs.imagemagick ]; } ''
    t=$out/share/plymouth/themes/tatakae
    mkdir -p $t
    magick -size 300x520 xc:none \
      -font ${japanFont}/share/fonts/truetype/ShipporiMincho-Bold.ttf \
      -fill '#D9434E' -pointsize 190 -gravity center \
      -annotate +0-125 '戦' -annotate +0+115 'え' $t/tatakae.png
    cat > $t/tatakae.plymouth <<EOF
    [Plymouth Theme]
    Name=Tatakae
    Description=戦え auf Schwarzrot
    ModuleName=script

    [script]
    ImageDir=$t
    ScriptFile=$t/tatakae.script
    EOF
    cat > $t/tatakae.script <<'EOF'
    Window.SetBackgroundTopColor(0.07, 0.027, 0.039);
    Window.SetBackgroundBottomColor(0.07, 0.027, 0.039);
    global.bild = Image("tatakae.png");
    global.zeichen = Sprite(global.bild);
    global.zeichen.SetX(Window.GetWidth() / 2 - global.bild.GetWidth() / 2);
    global.zeichen.SetY(Window.GetHeight() / 2 - global.bild.GetHeight() / 2);
    global.t = 0;
    fun refresh_callback() {
      global.t = global.t + 1;
      global.zeichen.SetOpacity(0.55 + 0.45 * Math.Sin(global.t / 35));
    }
    Plymouth.SetRefreshFunction(refresh_callback);
    EOF
  '';

  # Mauszeiger: spitzer Bibata-Zeiger, schwarz mit rotem Rand
  blutCursor = pkgs.runCommand "blut-cursor" {
    nativeBuildInputs = [ pkgs.xcur2png pkgs.xcursorgen pkgs.imagemagick ];
  } ''
    src=${pkgs.bibata-cursors}/share/icons/Bibata-Original-Classic
    ziel=$out/share/icons/Blut-Cursor
    mkdir -p $ziel/cursors
    printf '[Icon Theme]\nName=Blut-Cursor\nComment=Schwarz mit rotem Rand\nInherits=hicolor\n' > $ziel/index.theme
    for f in $src/cursors/*; do
      n=$(basename "$f")
      if [ -L "$f" ]; then
        ln -s "$(basename "$(readlink "$f")")" "$ziel/cursors/$n"
        continue
      fi
      tmp=$(mktemp -d)
      xcur2png -q -d "$tmp" -c "$tmp/c.conf" "$f"
      magick mogrify -channel RGB +level-colors '#12070A,#FF1F3D' "$tmp"/*.png
      xcursorgen "$tmp/c.conf" "$ziel/cursors/$n"
      rm -rf "$tmp"
    done
  '';

  # Super + Esc: Ausschalt-Menü im Vollbild
  energieMenue = pkgs.writeShellScript "energie-menue" ''
    stil='window { fullscreen: true; location: center; anchor: center; y-offset: 0; background-color: #0B0405F2; border: 0; }
      mainbox { padding: 0 12%; children: [ "listview" ]; }
      inputbar { enabled: false; }
      listview { columns: 5; lines: 1; spacing: 16px; margin: calc(50% - 94px) 0 0 0; }
      element { orientation: vertical; padding: 24px; }
      element-icon { enabled: false; }
      element-text { horizontal-align: 0.5; vertical-align: 0.5; }'
    e() { printf "<span font='Shippori Mincho 56'>%s</span>\n<span size='small'>%s</span>" "$1" "$2"; }
    menue() { rofi -dmenu -sep '|' -markup-rows -format i -no-custom -eh 7 -theme-str "$stil$1"; }
    sicher() {
      a=$(printf '%s' "$(e 否 Abbrechen)|$(e "$1" "$2")" | menue ' listview { columns: 2; } mainbox { padding: 0 30%; }') || return 1
      [ "$a" = 1 ]
    }
    i=$(printf '%s' "$(e 鎖 Sperren)|$(e 眠 Schlafen)|$(e 退 Abmelden)|$(e 蘇 Neustart)|$(e 死 Ausschalten)" | menue "") || exit 0
    case "$i" in
      0) hyprlock ;;
      1) systemctl suspend ;;
      2) sicher 退 Abmelden && hyprctl dispatch exit ;;
      3) sicher 蘇 Neustart && systemctl reboot ;;
      4) sicher 死 Ausschalten && systemctl poweroff ;;
    esac
  '';

  # Super + Shift + 7 (also Super + /): zeigt alle Tastenkürzel durchsuchbar an
  tastenFilter = pkgs.writeText "tasten.jq" ''
    def hat($b): ((.modmask / $b | floor) % 2) == 1;
    def taste:
      ({"Return":"Enter","left":"←","right":"→","up":"↑","down":"↓","Escape":"Esc","TAB":"Tab","Tab":"Tab",
        "mouse:272":"Linke Maus","mouse:273":"Rechte Maus","XF86AudioRaiseVolume":"Lauter-Taste",
        "XF86AudioLowerVolume":"Leiser-Taste","XF86AudioMute":"Stumm-Taste",
        "XF86MonBrightnessUp":"Heller-Taste","XF86MonBrightnessDown":"Dunkler-Taste"}[.key]) // (.key | ascii_upcase);
    def tasten: [(if hat(64) then "Super" else empty end), (if hat(4) then "Strg" else empty end),
      (if hat(8) then "Alt" else empty end), (if hat(1) then "Shift" else empty end), taste] | join(" + ");
    def was:
      .dispatcher as $d | .arg as $a |
      if $d == "exec" then
        if ($a | test("terminal-zufall")) then "Terminal öffnen"
        elif ($a | test("effekte-umschalten")) then "Terminal-Effekte an/aus"
        elif ($a | test("energie-menue")) then "Ausschalt-Menü"
        elif ($a | test("tastenkuerzel")) then "Diese Liste"
        elif ($a | test("hyprlock")) then "Bildschirm sperren"
        elif ($a | test("rofi")) then "Apps suchen"
        elif ($a | test("flameshot")) then "Screenshot"
        elif ($a | test("zen")) then "Browser"
        elif ($a | test("yazi")) then "Dateimanager"
        elif ($a | test("5%\\+")) then (if ($a | test("wpctl")) then "Lauter" else "Heller" end)
        elif ($a | test("5%-")) then (if ($a | test("wpctl")) then "Leiser" else "Dunkler" end)
        elif ($a | test("set-mute")) then "Ton an/aus"
        else $a end
      elif $d == "killactive" then "Fenster schließen"
      elif $d == "exit" then "Hyprland beenden"
      elif $d == "togglefloating" then "Fenster schwebend/fest"
      elif $d == "fullscreen" then "Vollbild"
      elif $d == "movefocus" then "Fokus bewegen"
      elif $d == "movewindow" then (if .mouse then "Fenster ziehen" else "Fenster verschieben" end)
      elif $d == "resizewindow" then "Fenstergröße ändern"
      elif $d == "workspace" then "Zu Workspace \($a)"
      elif $d == "movetoworkspace" then "Fenster auf Workspace \($a)"
      elif $d == "submap" then "Größe ändern (Modus)"
      elif $d == "overview:toggle" then "Workspace-Übersicht"
      else "\($d) \($a)" end;
    .[] | select(.submap == "") | tasten as $k |
      "\($k)\(" " * ([28 - ($k | length), 1] | max))\(was)"
  '';
  tastenkuerzel = pkgs.writeShellScript "tastenkuerzel" ''
    hyprctl -j binds | ${pkgs.jq}/bin/jq -r -f ${tastenFilter} |
      rofi -dmenu -i -p "戦" -no-custom -theme-str 'window { width: 720px; } listview { lines: 14; }'
  '';
in
{
  programs.hyprland.enable = true;
  programs.hyprlock.enable = true;

  # Bootscreen statt Textzeilen (das Catppuccin-Theme würde ihn sonst überschreiben)
  catppuccin.plymouth.enable = false;
  boot = {
    plymouth = {
      enable = true;
      theme = "tatakae";
      themePackages = [ tatakaeBoot ];
    };
    consoleLogLevel = 3;
    initrd.verbose = false;
    kernelParams = [ "quiet" "udev.log_level=3" "systemd.show_status=auto" ];
  };

  fonts.packages = [
    pkgs.cinzel
    pkgs.noto-fonts-cjk-serif
    japanFont
    (pkgs.google-fonts.override { fonts = [ "UnifrakturMaguntia" "PirataOne" "GrenzeGotisch" "NewRocker" "MetalMania" ]; })
  ];
  home-manager.users.kuss = {
    home.pointerCursor = {
      package = blutCursor;
      name = "Blut-Cursor";
      size = 24;
    };

    systemd.user.services.wallpaper = {
      Unit = {
        Description = "Wallpaper";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
      };
      Service = {
        ExecStart = "${pkgs.swaybg}/bin/swaybg -i ${wallpaper} -m fill";
        Restart = "on-failure";
      };
      Install.WantedBy = [ "graphical-session.target" ];
    };

    # Terminal im Design "Tinte und Blut"
    programs.ghostty = {
      enable = true;
      settings = {
        background-opacity = 0.94;
        # Hintergrund-Effekte laufen nur im aktiven Terminal
        custom-shader-animation = true;
        config-file = "?/home/kuss/.local/state/ghostty/effekte-aus.conf";
        app-notifications = "no-config-reload";
        background = "#12070A";
        foreground = "#E6DFD3";
        cursor-color = "#FF1F3D";
        selection-background = "#5A0F18";
        selection-foreground = "#E6DFD3";
        window-padding-x = 10;
        window-padding-y = 8;
        palette = [
          "0=#1F0D10"
          "1=#D9434E"
          "2=#8A9A6B"
          "3=#C9A86A"
          "4=#7C8CA3"
          "5=#A87C8E"
          "6=#7D9C98"
          "7=#BDB4A9"
          "8=#8F7475"
          "9=#F0626B"
          "10=#A8B88A"
          "11=#DEC48A"
          "12=#9AAAC0"
          "13=#C79AAB"
          "14=#9CBAB6"
          "15=#E6DFD3"
        ];
      };
    };

    programs.hyprlock = {
      enable = true;
      settings = {
        general = {
          hide_cursor = true;
        };

        background = [{
          path = "${wallpaper}";
          color = "rgba(12070aff)";
          blur_passes = 2;
          blur_size = 6;
          brightness = 0.6;
        }];

        label = [
          {
            text = "戦え";
            font_family = "Shippori Mincho";
            font_size = 90;
            color = "rgba(d9434eff)";
            position = "0, 260";
            halign = "center";
            valign = "center";
          }
          {
            text = "$TIME";
            font_family = "Shippori Mincho";
            font_size = 110;
            color = "rgba(e6dfd3ff)";
            position = "0, 90";
            halign = "center";
            valign = "center";
          }
          # Datum
          {
            text = ''cmd[update:60000] date +"%-d · %m · %Y"'';
            font_family = "Shippori Mincho";
            font_size = 26;
            color = "rgba(c4aeacff)";
            position = "0, -10";
            halign = "center";
            valign = "center";
          }
          # Benutzername unter dem Feld
          {
            text = "— $USER —";
            font_family = "Shippori Mincho";
            font_size = 14;
            color = "rgba(c4aeacff)";
            position = "0, -190";
            halign = "center";
            valign = "center";
          }
        ];

        # Dünner roter Strich unter dem Datum
        shape = [{
          size = "260, 2";
          color = "rgba(ff1f3dff)";
          rounding = 0;
          position = "0, -40";
          halign = "center";
          valign = "center";
        }];

        input-field = [{
          size = "300, 52";
          position = "0, -120";
          halign = "center";
          valign = "center";
          outline_thickness = 2;
          rounding = 0;
          outer_color = "rgba(ff1f3dff)";
          inner_color = "rgba(24090eff)";
          font_color = "rgba(e6dfd3ff)";
          font_family = "Shippori Mincho";
          check_color = "rgba(c4aeacff)";
          fail_color = "rgba(f0626bff)";
          fail_text = "<i>falsch</i>";
          placeholder_text = "<i>passwort</i>";
          dots_size = 0.25;
          dots_spacing = 0.4;
          dots_center = true;
          fade_on_empty = false;
        }];
      };
    };
    # App-Starter: Theme "rounded-red-dark" von newmanls/rofi-themes-collection, Farben angepasst
    programs.rofi = {
      enable = true;
      theme = let
        themes = pkgs.fetchFromGitHub {
          owner = "newmanls";
          repo = "rofi-themes-collection";
          rev = "911cc27afe9c66d7e2cb06a47c905d046ea3dfd2";
          hash = "sha256-YdsuzmpU/fokvF1/vKuiK/eOLFGfhJcFu8HvUIqx9Ao=";
        };
      in "${pkgs.writeText "rounded-goth.rasi" ''
        * {
            bg0: #12070AF7;
            bg1: #24090E;
            bg2: #8A1C24;
            bg3: #B3001B;
            fg0: #E6DFD3;
            fg1: #FFFFFF;
            fg2: #F0626B;
            fg3: #C4AEAC;
        }
        @import "${themes}/themes/template/rounded-template.rasi"

        /* Tinte und Blut: eckig, feine Linien */
        * { font: "JetBrainsMono Nerd Font 12"; }
        window { border-radius: 0; border: 2px; border-color: @bg2; }
        inputbar { border-radius: 0; border: 0 0 2px; border-color: @bg2; }
        message { border-radius: 0; }
        element { border-radius: 0; }
      ''}";
    };

    wayland.windowManager.hyprland = {
      enable = true;
      package = null;
      portalPackage = null;
      configType = "hyprlang";

      # Workspace-Übersicht (Super + Tab). Direkt in der Config geladen,
      # damit Hyprland das Tastenkürzel dafür nicht als Fehler meldet.
      extraConfig = ''
        plugin = ${pkgs.hyprlandPlugins.hyprspace}/lib/libhyprspace.so
      '';

      submaps.resize.settings = {
        binde = [
          ", right, resizeactive, 30 0"
          ", left, resizeactive, -30 0"
          ", up, resizeactive, 0 -30"
          ", down, resizeactive, 0 30"
        ];
        bind = [
          ", escape, submap, reset"
          ", Return, submap, reset"
        ];
      };

      settings = {
        "$terminal" = "${terminalZufall}";
        "$mod" = "SUPER";
        monitor = [ "eDP-1,preferred,auto,1.25" ];
        env = [ "XCURSOR_THEME,Blut-Cursor" "XCURSOR_SIZE,24" ];
        exec = [ "hyprctl setcursor Blut-Cursor 24" ];

        plugin.overview = {
          panelColor = "rgba(12070aee)";
          panelBorderColor = "rgba(8a1c24ff)";
          panelBorderWidth = 2;
          workspaceActiveBackground = "rgba(3d0a10ff)";
          workspaceInactiveBackground = "rgba(1a0a0dff)";
          workspaceActiveBorder = "rgba(ff1f3dff)";
          workspaceInactiveBorder = "rgba(4a1016ff)";
          workspaceBorderSize = 2;
          centerAligned = true;
          autoDrag = true;
          exitOnClick = true;
          exitOnSwitch = true;
          showNewWorkspace = false;
        };

        input = {
          kb_layout = "de";
        };

        general = {
          gaps_in = 4;
          gaps_out = 8;
          border_size = 2;
          "col.active_border" = "rgba(ff1f3dff) rgba(8a0016ff) 45deg";
          "col.inactive_border" = "rgba(4a1016ff)";
          layout = "dwindle";
        };

        decoration = {
          rounding = 0;
          dim_inactive = true;
          dim_strength = 0.25;

          shadow = {
            enabled = true;
            range = 14;
            render_power = 3;
            color = "rgba(b3001b77)";
            color_inactive = "rgba(00000000)";
          };

          blur = {
            enabled = true;
            size = 6;
            passes = 3;
          };
        };

        misc = {
          disable_hyprland_logo = true;
          disable_splash_rendering = true;
          force_default_wallpaper = 0;
          background_color = "rgb(12070a)";
        };

        # Dauer in Zehntelsekunden: 4 = 0,4 s
        animations = {
          enabled = true;
          bezier = [
            "gleiten, 0.16, 1, 0.3, 1"
            "raus, 0.7, 0, 0.84, 0"
          ];
          animation = [
            # Schnitt: Fenster klappen aus einer Linie auf und schließen sich wieder dorthin
            "windowsIn, 1, 3.5, gleiten, gnomed"
            "windowsOut, 1, 2.5, raus, gnomed"
            "windowsMove, 1, 4, gleiten"
            "fadeIn, 1, 3, gleiten"
            "fadeOut, 1, 2, raus"
            "fadeDim, 1, 3, gleiten"
            "border, 1, 4, gleiten"
            "workspaces, 1, 4, gleiten, slidefade 20%"
            "layersIn, 1, 3, gleiten, popin 95%"
            "layersOut, 1, 2, raus, fade"
            "fadeLayersIn, 1, 3, gleiten"
            "fadeLayersOut, 1, 2, raus"
          ];
        };

        bind = [
          "$mod, Return, exec, $terminal"
          "$mod SHIFT, left, movewindow, l"
          "$mod SHIFT, right, movewindow, r"
          "$mod SHIFT, up, movewindow, u"
          "$mod SHIFT, down, movewindow, d"
          "$mod, R, submap, resize"
          "$mod, L, exec, hyprlock"
	  "$mod, Q, killactive"
          "$mod, M, exit"
          "$mod, V, togglefloating"
          "$mod, F, fullscreen"
          "$mod, E, exec, ghostty -e yazi"
          "$mod, B, exec, zen-beta"
          "$mod, D, exec, rofi -show drun -show-icons"
          "$mod, A, exec, ${effekteUmschalten}"
          "$mod, Escape, exec, ${energieMenue}"
          "$mod SHIFT, 7, exec, ${tastenkuerzel}"
          "$mod, TAB, overview:toggle"
	  "$mod, S, exec, flameshot gui --clipboard --accept-on-select"
	 
          "$mod, left, movefocus, l"
          "$mod, right, movefocus, r"
          "$mod, up, movefocus, u"
          "$mod, down, movefocus, d"

          "$mod, 1, workspace, 1"
          "$mod, 2, workspace, 2"
          "$mod, 3, workspace, 3"
          "$mod, 4, workspace, 4"
          "$mod, 5, workspace, 5"

          "$mod SHIFT, 1, movetoworkspace, 1"
          "$mod SHIFT, 2, movetoworkspace, 2"
          "$mod SHIFT, 3, movetoworkspace, 3"
          "$mod SHIFT, 4, movetoworkspace, 4"
          "$mod SHIFT, 5, movetoworkspace, 5"

          ", XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
          ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
          ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
	  ", XF86MonBrightnessUp, exec, brightnessctl set 5%+"
	  ", XF86MonBrightnessDown, exec, brightnessctl set 5%-"
        ];

        bindm = [
          "$mod, mouse:272, movewindow"
          "$mod, mouse:273, resizewindow"
        ];
      };
    };
  };
}
