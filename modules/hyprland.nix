{ pkgs, ... }:
{
  programs.hyprland.enable = true;

  home-manager.users.kuss = {
    home.packages = [ pkgs.ghostty ];

    wayland.windowManager.hyprland = {
      enable = true;
      package = null;
      portalPackage = null;
      configType = "hyprlang";

      settings = {
        "$terminal" = "ghostty";
        input = {
          kb_layout = "de";
        };
      };
    };
  };
}
