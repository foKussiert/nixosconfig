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
in
{
  programs.hyprland.enable = true;
  programs.hyprlock.enable = true;
  fonts.packages = [
    pkgs.cinzel
    pkgs.noto-fonts-cjk-serif
    japanFont
    (pkgs.google-fonts.override { fonts = [ "UnifrakturMaguntia" "PirataOne" "GrenzeGotisch" "NewRocker" "MetalMania" ]; })
  ];
  home-manager.users.kuss = {
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
        "$terminal" = "ghostty";
        "$mod" = "SUPER";
        monitor = [ "eDP-1,preferred,auto,1.25" ];

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
            "federn, 0.34, 1.3, 0.64, 1"
            "raus, 0.7, 0, 0.84, 0"
          ];
          animation = [
            "windowsIn, 1, 4, federn, popin 90%"
            "windowsOut, 1, 2.5, raus, popin 95%"
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
