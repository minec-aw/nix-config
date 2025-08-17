{
	description = "the NixOS flake";

	inputs = {
		nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable"; #-24.11
		localPackages = {
			url = "path:./LocalPackages";
			inputs.nixpkgs.follows = "nixpkgs";
		};
		quickshell = {
			url = "git+https://git.outfoxxed.me/outfoxxed/quickshell";
			inputs.nixpkgs.follows = "nixpkgs";
		};
		zen-browser = {
			url = "github:youwen5/zen-browser-flake";
			inputs.nixpkgs.follows = "nixpkgs";
		};
		hjem = {
			url = "github:feel-co/hjem";
			inputs.nixpkgs.follows = "nixpkgs";
		};
		firefox = {
			url = "github:nix-community/flake-firefox-nightly";
			inputs.nixpkgs.follows = "nixpkgs";
		};
		nixpkgs-xr.url = "github:nix-community/nixpkgs-xr";
	};

	outputs = { self, nixpkgs, localPackages, nixpkgs-xr, ... }@inputs:
	let 
		system = "x86_64-linux";
		pkgs = nixpkgs.legacyPackages.${system};
	in {
		nixosConfigurations.minec = nixpkgs.lib.nixosSystem {
		inherit system;
			specialArgs = {
				inherit inputs;
				inherit localPackages;
			};
			modules = [
				inputs.hjem.nixosModules.default
				nixpkgs-xr.nixosModules.nixpkgs-xr
				./configuration.nix
			];
		};
	};
}
