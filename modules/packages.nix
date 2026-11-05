# Programs installed for all users.
# Search for packages at https://search.nixos.org/
{ pkgs, inputs, ... }:

let
  unstable = import inputs.nixpkgs-unstable {
    system = pkgs.stdenv.hostPlatform.system;
    config.allowUnfree = true;
  };
in
{
  nixpkgs.config.allowUnfree = true;

  programs.firefox.enable = true;

  environment.systemPackages = with pkgs; [
    discord
    jdk21
    maven
    vim
    wget
    git
    bat
    unstable.claude-code  
    vscodium
    inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}
