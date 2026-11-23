# Waybar: Design "mechabar" (github.com/sejjy/mechabar, MIT)
# angepasst: Goth-Farben, NixOS-Logo, Ghostty, Hyprland-Syntax, ohne Arch-Update-Anzeige
{ pkgs, ... }:
let
  mechabar = pkgs.fetchFromGitHub {
    owner = "sejjy";
    repo = "mechabar";
    rev = "360e581f99a23a841d9eb2dfabe69c667fcbb844";
    hash = "sha256-N83IBs1Gfh4ou2xHThq7UdYzsvbl4dIPXeOC8MfO7bI=";
  };
  scripts = "~/.config/waybar/scripts";
in
{
  # Schrift mit Symbolen
  fonts.packages = [ pkgs.nerd-fonts.jetbrains-mono ];

  home-manager.users.kuss = {
    # Programme, die die mechabar-Skripte brauchen
    home.packages = with pkgs; [ fzf bluez brightnessctl libnotify pulseaudio ];

    # Benachrichtigungen (z. B. "WLAN verbunden", Lautstärke)
    services.mako = {
      enable = true;
      settings = {
        background-color = "#12070af7";
        text-color = "#e6dfd3";
        border-color = "#ff1f3d";
        border-size = 2;
        border-radius = 0;
        default-timeout = 4000;
        font = "JetBrainsMono Nerd Font 11";
      };
    };

    # Module und Skripte aus mechabar
    xdg.configFile."waybar/modules".source = "${mechabar}/modules";
    # Skripte: "every(2)" braucht ein neueres fzf als in NixOS, daher Liste nur beim Start laden
    xdg.configFile."waybar/scripts".source = pkgs.runCommand "mechabar-scripts" { } ''
      cp -r ${mechabar}/scripts $out
      chmod -R u+w $out
      sed -i "s/start,every(2):/start:/" $out/network $out/bluetooth
    '';

    # Farben "Tinte und Blut" (ersetzt das Catppuccin-Theme)
    xdg.configFile."waybar/goth.css".text = ''
      @define-color m_accent      #b3001b;
      @define-color m_fg          #e6dfd3;
      @define-color m_bg_0        #12070a;
      @define-color m_bg_1        #24090e;
      @define-color m_bg_2        #360c13;
      @define-color m_bg_3        #4d1019;
      @define-color m_border      #8a1c24;
      @define-color m_shadow      #0a0305;
      @define-color m_warning     #dec48a;
      @define-color m_critical    #f0626b;
      @define-color m_charging    #a8b88a;
      @define-color m_bg_alt      #4d1019;
      @define-color m_fg_alt      #c4aeac;
    '';

    programs.waybar = {
      enable = true;
      systemd.enable = true;

      # Aussehen von mechabar, nur Farbdatei und Schrift getauscht
      style = builtins.replaceStrings
        [ ''@import "themes/catppuccin-mocha.css";'' ''"GoogleSansCode Nerd Font"'' ]
        [ ''@import "goth.css";'' ''"JetBrainsMono Nerd Font"'' ]
        (builtins.readFile "${mechabar}/style.css")
        + ''
          #power-profiles-daemon {
            padding: 0 4px;
            background-color: @m_bg_1;
          }
          #power-profiles-daemon:hover {
            color: @m_fg_alt;
          }

          /* Tinte und Blut: Rot als Grundton */
          .modules-center { padding-left: 0; }
          tooltip, menu { border-width: 1px; }

          #workspaces button {
            border-radius: 0;
            padding: 0 8px;
            min-width: 14px;
          }
          #workspaces button label {
            font-family: "Noto Serif CJK JP";
            font-size: 14px;
            color: @m_fg_alt;
          }
          #workspaces button:hover {
            background-color: @m_bg_alt;
            background-image: none;
          }
          #workspaces button.active,
          #workspaces button.focused {
            background-color: @m_accent;
          }
          #workspaces button.active label,
          #workspaces button.focused label {
            font-size: 14px;
            color: @m_fg;
          }

          #custom-distro {
            font-size: 18.75px;
            padding: 0 8px;
            color: @m_fg;
          }

          #cpu, #memory, #temperature {
            padding: 0 6px;
            background-color: transparent;
          }
          #battery { background-color: @m_bg_1; }
          #custom-power {
            border-radius: 0;
            color: @m_critical;
          }
          #custom-power:hover { color: @m_fg; }
        '';

      settings = [{
        mode = "dock";
        position = "top";
        layer = "top";
        spacing = 0;
        reload_style_on_change = true;

        include = [
          "~/.config/waybar/modules/custom/*.jsonc"
          "~/.config/waybar/modules/hyprland/window.jsonc"
          "~/.config/waybar/modules/optional/tray.jsonc"
          "~/.config/waybar/modules/*.jsonc"
        ];

        modules-left = [
          "custom/user"
          "custom/left#bg_1" "hyprland/workspaces" "custom/right#bg_1"
          "hyprland/window"
        ];

        modules-center = [
          "custom/left#bg_1" "network" "bluetooth" "power-profiles-daemon"
          "custom/left#bg_2" "clock#date"
          "custom/left#bg_3" "idle_inhibitor" "custom/left_inverse#bg_3"
          "custom/left#accent" "custom/distro" "custom/right#accent"
          "custom/right_inverse#bg_3" "clock#time" "custom/right#bg_3"
          "backlight" "custom/right#bg_2"
          "group/pulseaudio" "custom/right#bg_1"
        ];

        # CPU, RAM und Temperatur erscheinen nur bei Warnungen
        modules-right = [
          "tray"
          "mpris"
          "cpu" "memory" "temperature"
          "custom/left#bg_1" "battery" "custom/right#bg_1"
          "custom/power"
        ];

        # Eigene Anpassungen (überschreiben die mechabar-Vorgaben)
        "custom/distro" = { format = ""; tooltip = false; };
        "hyprland/workspaces" = {
          persistent-workspaces = { "*" = 5; };
          format = "{icon}";
          format-icons = { "1" = "一"; "2" = "二"; "3" = "三"; "4" = "四"; "5" = "五"; };
          on-scroll-up = "hyprctl dispatch workspace r+1";
          on-scroll-down = "hyprctl dispatch workspace r-1";
          cursor = true;
        };
        cpu = { format = ""; };
        memory = { format = ""; };
        temperature = { format = ""; };
        "hyprland/window" = {
          rewrite = { "" = "Desktop"; "com.mitchellh.ghostty" = "Terminal"; };
        };
        "clock#date" = { format = "󰸗 {:%d.%m}"; };
        "power-profiles-daemon" = {
          format = "{icon}";
          min-length = 2;
          max-length = 2;
          format-icons = {
            performance = "󰓅";
            balanced = "󰾅";
            power-saver = "󰌪";
          };
        };
        network = { on-click = "ghostty -e ${scripts}/network menu"; };
        bluetooth = { on-click = "ghostty -e ${scripts}/bluetooth menu"; };
        "custom/power" = { on-click = "ghostty -e ${scripts}/power"; };
      }];
    };
  };
}
