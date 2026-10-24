{
  description = "newBorn";

  inputs = {
    nixpkgs.url = "https://channels.nixos.org/nixos-26.05/nixexprs.tar.zst";
    zen-browser.url = "github:0xc000022070/zen-browser-flake";
    catppuccin.url = "github:catppuccin/nix/release-26.05";
    
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs"; 
    };  
};

  outputs = { self, nixpkgs, catppuccin, home-manager,  ... }@inputs: {
    nixosConfigurations.kuss = nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs; };
      modules = [
        ./hosts/kuss/configuration.nix
	catppuccin.nixosModules.catppuccin
	home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.users.kuss = import ./home.nix;
        }
      ];
    };
  };
}
