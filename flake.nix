{
	description = "the NixOS flake";

	inputs = {
		nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable"; #-24.11
		/*localPackages = {
			url = "path:./LocalPackages";
			inputs.nixpkgs.follows = "nixpkgs";
		};*/
		localPackages = {
			url = "path:./LocalPackages";
			inputs.nixpkgs.follows = "nixpkgs";
		};

		quickshell = {
			url = "git+https://git.outfoxxed.me/outfoxxed/quickshell";
			inputs.nixpkgs.follows = "nixpkgs";
		};
		zen-browser.url = "github:0xc000022070/zen-browser-flake";
		hjem = {
			url = "github:feel-co/hjem";
			# You may want hjem to use your defined nixpkgs input to
			# minimize redundancies.
			inputs.nixpkgs.follows = "nixpkgs";
		};
		#zen-browser.url = "path:./zen-browser";
		#apple-fonts.url = "github:Lyndeno/apple-fonts.nix/master";
		#nixMaster.url = "github:NixOS/nixpkgs/nixos-unstable-small";
	};

	outputs = { self, nixpkgs, localPackages, ... }@inputs:
	let 
		system = "x86_64-linux";
		pkgs = nixpkgs.legacyPackages.${system};
	#		unstable = nix-unstable.legacyPackages.${system};
	in {
		nixosConfigurations.minec = nixpkgs.lib.nixosSystem {
		inherit system;
			specialArgs = {
				inherit inputs;
				inherit localPackages;
				#inherit wezterm-pin;
				#inherit nixMaster;
			};
			modules = [
				inputs.hjem.nixosModules.default
				#nixpkgs-xr.nixosModules.nixpkgs-xr
				./configuration.nix

				#home-manager.nixosModules.home-manager
				#{
				#	home-manager.useGlobalPkgs = true;
				#	home-manager.useUserPackages = true;
				#	home-manager.extraSpecialArgs = { 
				#		inherit inputs;
				#		inherit localPackages;
				#		inherit unstable;
				#	};
				#	home-manager.users.minec = ./homes/minec/default.nix;
				#}
			];
		};
	/*homeConfigurations."minec" = home-manager.lib.homeManagerConfiguration {
	inherit pkgs;
	modules = [ 
	stylix.homeManagerModules.stylix 
	./homes/minec
	];
	extraSpecialArgs = {
	inherit localPackages inputs nix-stable;
	};
	};*/
	};
}
