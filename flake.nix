{
  description = "sas's NixOS config";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs = { self, nixpkgs, home-manager, ... }: {
    nixosConfigurations = {
      silco = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hosts/silco/configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.sasan = import ./home/sasan/home.nix;
          }
        ];
      };
			jinx = nixpkgs.lib.nixosSystem {
				system = "x86_64-linux";
				modules = [
				  ./hosts/jinx/configuration.nix
					home-manager.nixosModules.home-manager
					{
				    home-manager.useGlobalPkgs = true;
						home-manager.useUserPackages = true;
						home-manager.users.sasan = import ./home/sasan/home.nix;
					}
				];
      };
			
    };
  };
}
