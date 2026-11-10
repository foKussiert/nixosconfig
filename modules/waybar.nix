{ pkgs, ...}:
{
  home-manager.users.kuss = {
    programs.waybar = {
      enable = true;
      systemd.enable = true;
    
      settings = [{
	layer = "top";
	position = "top";
	modules-left = ["hyprland/workspaces"];
	modules-center = [ "clock"];
	modules-right = ["network" "pulseaudio" "battery" ];
      }];
    
       style = ''
        * { font-family: "JetBrainsMono Nerd Font"; font-size: 13px; }
        window#waybar { background: #0d0000; color: #e8dcdc; }
      '';
    };
  };
}


