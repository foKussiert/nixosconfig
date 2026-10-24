{
  description = "newBorn";

  inputs = {
    nixpkgs.url = "https://channels.nixos.org/nixos-26.05/nixexprs.tar.zst";
    zen-browser.url = "github:0xc000022070/zen-browser-flake";
    catppuccin.url = "github:catppuccin/nix/release-26.05";
  };

  outputs = { self, nixpkgs, catppuccin, ... }@inputs: {
    nixosConfigurations.kuss = nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs; };
      modules = [
        ./hosts/kuss/configuration.nix
        catppuccin.nixosModules.catppuccin
      ];
    };
  };
}
