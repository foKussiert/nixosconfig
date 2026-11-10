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
        background-color = "#0d0000ee";
        text-color = "#e8dcdc";
        border-color = "#b3001b";
        border-size = 2;
        border-radius = 4;
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

    # Goth-Farben (ersetzt das Catppuccin-Theme)
    xdg.configFile."waybar/goth.css".text = ''
      @define-color m_accent      #b3001b;
      @define-color m_fg          #e8dcdc;
      @define-color m_bg_0        #0d0000;
      @define-color m_bg_1        #1a0505;
      @define-color m_bg_2        #2a0a0a;
      @define-color m_bg_3        #3d0a0e;
      @define-color m_border      #8a1c24;
      @define-color m_shadow      #050000;
      @define-color m_warning     #c9a227;
      @define-color m_critical    #ff0022;
      @define-color m_charging    #7a8a3a;
      @define-color m_bg_alt      #2a0a0a;
      @define-color m_fg_alt      alpha(#e8dcdc, 0.75);
    '';

    programs.waybar = {
      enable = true;
      systemd.enable = true;

      # Aussehen von mechabar, nur Farbdatei und Schrift getauscht
      style = builtins.replaceStrings
        [ ''@import "themes/catppuccin-mocha.css";'' ''"GoogleSansCode Nerd Font"'' ]
        [ ''@import "goth.css";'' ''"JetBrainsMono Nerd Font"'' ]
        (builtins.readFile "${mechabar}/style.css");

      settings = [{
        mode = "dock";
        position = "top";
        layer = "top";
        spacing = 0;
        reload_style_on_change = true;

        include = [
          "~/.config/waybar/modules/custom/*.jsonc"
          "~/.config/waybar/modules/hyprland/*.jsonc"
          "~/.config/waybar/modules/optional/tray.jsonc"
          "~/.config/waybar/modules/*.jsonc"
        ];

        modules-left = [
          "custom/user"
          "custom/left#bg_1" "hyprland/workspaces" "custom/right#bg_1"
          "hyprland/window"
        ];

        modules-center = [
          "custom/left#bg_1" "temperature"
          "custom/left#bg_2" "memory"
          "custom/left#bg_3" "cpu" "custom/left_inverse#bg_3"
          "custom/left#accent" "custom/distro" "custom/right#accent"
          "custom/right_inverse#bg_3" "idle_inhibitor" "clock#time" "custom/right#bg_3"
          "clock#date" "custom/right#bg_2"
          "network" "bluetooth" "custom/right#bg_1"
        ];

        modules-right = [
          "tray"
          "mpris"
          "custom/left#bg_1" "group/pulseaudio"
          "custom/left#bg_2" "backlight"
          "custom/left#bg_3" "battery" "custom/left_inverse#bg_3"
          "custom/power"
        ];

        # Eigene Anpassungen (überschreiben die mechabar-Vorgaben)
        "custom/distro" = { format = ""; tooltip = false; };
        "hyprland/workspaces" = {
          persistent-workspaces = { "*" = 5; };
          on-scroll-up = "hyprctl dispatch workspace r+1";
          on-scroll-down = "hyprctl dispatch workspace r-1";
        };
        "hyprland/window" = {
          rewrite = { "" = "Desktop"; "com.mitchellh.ghostty" = "Terminal"; };
        };
        "clock#date" = { format = "󰸗 {:%d.%m}"; };
        network = { on-click = "ghostty -e ${scripts}/network menu"; };
        bluetooth = { on-click = "ghostty -e ${scripts}/bluetooth menu"; };
        "custom/power" = { on-click = "ghostty -e ${scripts}/power"; };
      }];
    };
  };
}
