{
	description = "the NixOS flake";

	inputs = {
		nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable"; #-24.11 #nixos-unstable
		#nixpkgs.follows = "nixos-cosmic/nixpkgs";
		# https://github.com/teatwig/nixpkgs/tree/wayfire-0.10.0
		localPackages = {
			url = "path:./LocalPackages";
			inputs.nixpkgs.follows = "nixpkgs";
		};
		zen-browser = {
			url = "github:0xc000022070/zen-browser-flake";
			inputs.nixpkgs.follows = "nixpkgs";
		};
		hjem = {
			url = "github:feel-co/hjem";
			inputs.nixpkgs.follows = "nixpkgs";
		};
		sls-steam = {
			url = "github:AceSLS/SLSsteam";
			inputs.nixpkgs.follows = "nixpkgs";
		};
		nixpkgs-xr.url = "github:nix-community/nixpkgs-xr";
	};


	outputs = { self, nixpkgs, localPackages, nixpkgs-xr, ... }@inputs:
	let 
		/*pkgs = import nixpkgs {
			inherit system;
		};*/
	in {
		nixosConfigurations = {
			minec = nixpkgs.lib.nixosSystem {
				system = "x86_64-linux";
				specialArgs = {
					inherit inputs;
					inherit localPackages;
				};
				modules = [
					inputs.hjem.nixosModules.default
					nixpkgs-xr.nixosModules.nixpkgs-xr
					./systems/minec/configuration.nix
				];
			};
			linec = nixpkgs.lib.nixosSystem {
				system = "x86_64-linux";
				specialArgs = {
					inherit inputs;
					inherit localPackages;
				};
				modules = [
					inputs.hjem.nixosModules.default
					./systems/linec/configuration.nix
				];
			};
		};
		
	};
}
