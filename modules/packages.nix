# Programs installed for all users.
# Search for packages at https://search.nixos.org/
{ pkgs, inputs, ... }:

{
  programs.firefox.enable = true;

  environment.systemPackages = with pkgs; [
    vim
    wget
    git
    bat
    vscodium
    inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}
