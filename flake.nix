{
  description = "newBorn";

  inputs = {
    nixpkgs.url = "https://channels.nixos.org/nixos-26.05/nixexprs.tar.zst";
    zen-browser.url = "github:0xc000022070/zen-browser-flake"; 
 };

  outputs = { self, nixpkgs, zen-browser, ... }@inputs: {
    nixosConfigurations.kuss = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";    

      specialArgs = { inherit inputs; }; 
      modules = [ ./configuration.nix ];
	};
  };
}
