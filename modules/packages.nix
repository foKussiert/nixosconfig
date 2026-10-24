# Programs installed for all users.
# Search for packages at https://search.nixos.org/
{ pkgs, inputs, ... }:

{
  nixpkgs.config.allowUnfree = true;

  programs.firefox.enable = true;

  environment.systemPackages = with pkgs; [
    vim
    wget
    git
    bat
    claude-code  
    vscodium
    inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}
