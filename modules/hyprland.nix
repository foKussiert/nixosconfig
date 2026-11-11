{ pkgs, ... }:
{
  programs.hyprland.enable = true;
  programs.hyprlock.enable = true;
  fonts.packages = [
    pkgs.cinzel
    pkgs.noto-fonts-cjk-serif
    (pkgs.google-fonts.override { fonts = [ "UnifrakturMaguntia" "PirataOne" "GrenzeGotisch" "NewRocker" "MetalMania" ]; })
  ];
  home-manager.users.kuss = {
    home.packages = [ pkgs.ghostty ];

    programs.hyprlock = {
      enable = true;
      settings = {
        general = {
          hide_cursor = true;
        };

        background = [{
          path = "screenshot";
          color = "rgba(0a0000ff)";
          blur_passes = 4;
          blur_size = 7;
          brightness = 0.25;
          contrast = 1.2;
          vibrancy = 0.1;
          noise = 0.02;
        }];

        label = [
          {
            text = "戦え";
            font_family = "Noto Serif CJK JP";
            font_size = 90;
            color = "rgba(b3001bff)";
            shadow_passes = 3;
            shadow_size = 8;
            shadow_color = "rgba(ff0022aa)";
            shadow_boost = 1.4;
            position = "0, 260";
            halign = "center";
            valign = "center";
          }
          {
            text = "$TIME";
            font_family = "Cinzel";
            font_size = 110;
            color = "rgba(e8dcdcff)";
            shadow_passes = 2;
            shadow_size = 6;
            shadow_color = "rgba(000000ff)";
            position = "0, 90";
            halign = "center";
            valign = "center";
          }
          # Datum
          {
            text = ''cmd[update:60000] date +"%-d · %m · %Y"'';
            font_family = "UnifrakturMaguntia";
            font_size = 30;
            color = "rgba(8a1c24ff)";
            shadow_passes = 2;
            shadow_size = 5;
            shadow_color = "rgba(b3001b88)";
            position = "0, -10";
            halign = "center";
            valign = "center";
          }
          # Benutzername unter dem Feld
          {
            text = "— $USER —";
            font_family = "Cinzel";
            font_size = 14;
            color = "rgba(6b6060ff)";
            position = "0, -190";
            halign = "center";
            valign = "center";
          }
        ];

        # Dünner roter Strich unter dem Datum
        shape = [{
          size = "260, 2";
          color = "rgba(b3001bcc)";
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
          outer_color = "rgba(b3001bff)";
          inner_color = "rgba(0d0000ee)";
          font_color = "rgba(e8dcdcff)";
          font_family = "Cinzel";
          check_color = "rgba(5a0010ff)";
          fail_color = "rgba(ff0022ff)";
          fail_text = "<i>falsch</i>";
          placeholder_text = "<i>passwort</i>";
          dots_size = 0.25;
          dots_spacing = 0.4;
          dots_center = true;
          fade_on_empty = false;
          shadow_passes = 2;
          shadow_size = 10;
          shadow_color = "rgba(b3001b66)";
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
            bg0: #0D0000F2;
            bg1: #1A0505;
            bg2: #3D0A0E80;
            bg3: #B3001BF2;
            fg0: #E8DCDC;
            fg1: #FFFFFF;
            fg2: #8A1C24;
            fg3: #4A3A3A;
        }
        @import "${themes}/themes/template/rounded-template.rasi"
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
          "col.active_border" = "rgba(b3001bff) rgba(1a0000ff) 45deg";
          "col.inactive_border" = "rgba(1a1a1aff)";
          layout = "dwindle";
        };

        decoration = {
          rounding = 3;
          dim_inactive = true;
          dim_strength = 0.25;

          shadow = {
            enabled = true;
            range = 15;
            color = "rgba(b3001b55)";
          };

          blur = {
            enabled = true;
            size = 6;
            passes = 3;
          };
        };

        animations = {
          enabled = true;
          bezier = [ "sharp, 0.25, 1, 0.5, 1" ];
          animation = [
            "windows, 1, 3, sharp, popin 80%"
            "fade, 1, 3, sharp"
            "border, 1, 5, default"
            "workspaces, 1, 3, sharp, slide"
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
        ];

        bindm = [
          "$mod, mouse:272, movewindow"
          "$mod, mouse:273, resizewindow"
        ];
      };
    };
  };
}
