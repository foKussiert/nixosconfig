{
  description = "newBorn";

  inputs = {
    nixpkgs.url = "https://channels.nixos.org/nixos-26.05/nixexprs.tar.zst";
    zen-browser.url = "github:0xc000022070/zen-browser-flake"; 
    catppuccin.url = "github:catppuccin/nix/release-26.05";
 };

  outputs = { self, nixpkgs, zen-browser, catppuccin, ... }@inputs: {
    nixosConfigurations.kuss = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";    

      specialArgs = { inherit inputs; }; 
      modules = [ 
            ./configuration.nix 
            catppuccin.nixosModules.catppuccin  
	  ];
	};
  };
}
