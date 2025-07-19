{
	description = "organically procured packages";
	inputs = {
		nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
	};
	outputs = { self, nixpkgs }:
	{
		klassy = nixpkgs.legacyPackages.x86_64-linux.callPackage ./klassy {};
		looking-glass = nixpkgs.legacyPackages.x86_64-linux.callPackage ./looking-glass {};
		vesktop = nixpkgs.legacyPackages.x86_64-linux.callPackage ./veskdown {};
		lightlyShaders = nixpkgs.legacyPackages.x86_64-linux.callPackage ./LightlyShaders {};
		lightly = nixpkgs.legacyPackages.x86_64-linux.callPackage ./Lightly {};
		forceblur = nixpkgs.legacyPackages.x86_64-linux.callPackage ./forceblur {};
		kvmfr = nixpkgs.legacyPackages.x86_64-linux.callPackage ./kvmfr {};
		tilp = nixpkgs.legacyPackages.x86_64-linux.callPackage ./tilp {};
		openssl = nixpkgs.legacyPackages.x86_64-linux.callPackage ./openssl {};
    	kde-material-you-colors = nixpkgs.legacyPackages.x86_64-linux.callPackage ./kde-material-you-colors {};
		macos-hyprcursor = nixpkgs.legacyPackages.x86_64-linux.callPackage ./macos-hyprcursor {};
		wayvr-dashboard = nixpkgs.legacyPackages.x86_64-linux.callPackage ./wayvr-dashboard {};
		

		#kdeconnect = nixpkgs.legacyPackages.x86_64-linux.kdePackages.kdeconnect-kde.overrideAttrs (finalAttrs: previousAttrs: {
		#	extraCmakeFlags = ["-DBLUETOOTH_ENABLED=ON"];
		#});
	};
}