{
	description = "the NixOS flake";

	inputs = {
		nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable"; #-24.11 #nixos-unstable
		nixpkgs-mesa-pin.url = "github:NixOS/nixpkgs/a683adc19ff5228af548c6539dbc3440509bfed3";
		# https://github.com/teatwig/nixpkgs/tree/wayfire-0.10.0
		nixpkgs-wayfire-new.url = "github:minec-aw/nixpkgs/wayfire-0.10.0";
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
		nixpkgs-xr.url = "github:nix-community/nixpkgs-xr";
	};
	#nixConfig.extra-substituters = [ "https://vicinae.cachix.org" ];
	#nixConfig.extra-trusted-public-keys = [ "vicinae.cachix.org-1:1kDrfienkGHPYbkpNj1mWTr7Fm1+zcenzgTizIcI3oc=" ];


	outputs = { self, nixpkgs, localPackages, nixpkgs-mesa-pin, nixpkgs-wayfire-new, nixpkgs-xr, ... }@inputs:
	let 
		system = "x86_64-linux";
		/*pkgs = import nixpkgs {
			inherit system;
		};*/
		pkgs-wayfire = nixpkgs-wayfire-new.legacyPackages.${system};
		pkgs-mesa-pin = nixpkgs-mesa-pin.legacyPackages.${system};
	in {
		nixosConfigurations.minec = nixpkgs.lib.nixosSystem {
		inherit system;
			specialArgs = {
				inherit inputs;
				inherit localPackages;
				inherit pkgs-mesa-pin;
				inherit pkgs-wayfire;
			};
			modules = [
				inputs.hjem.nixosModules.default
				nixpkgs-xr.nixosModules.nixpkgs-xr
				./configuration.nix
			];
		};
	};
}
