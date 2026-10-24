{config, pkgs, ...}:
{
  home.username = "kuss";
  home.homeDirectory = "/home/kuss";
  home.stateVersion = "26.05";
  home.packages = [ pkgs.fastfetch ];
}
