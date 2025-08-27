{
	description = "organically procured packages";
	inputs = {
		nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
	};
	outputs = { self, nixpkgs }:
	{
		tilp = nixpkgs.legacyPackages.x86_64-linux.callPackage ./tilp {};
		openssl = nixpkgs.legacyPackages.x86_64-linux.callPackage ./openssl {};
		macos-hyprcursor = nixpkgs.legacyPackages.x86_64-linux.callPackage ./macos-hyprcursor {};
	};
}