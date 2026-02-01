{
	description = "organically procured packages";
	inputs = {
		nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
	};
	outputs = { self, nixpkgs }:
	let 
		callPackage = nixpkgs.legacyPackages.x86_64-linux.callPackage;
		mkHyprlandPlugin = nixpkgs.legacyPackages.x86_64-linux.hyprlandPlugins.mkHyprlandPlugin;
	in
	{
		tilp = callPackage ./tilp {};
		openssl = callPackage ./openssl {};
		macos-hyprcursor = callPackage ./macos-hyprcursor {};
		csd-titlebar-move = callPackage ./hyprcsd { inherit mkHyprlandPlugin; };
		hyprfreeze = nixpkgs.legacyPackages.x86_64-linux.writeShellScriptBin "hyprfreeze" (builtins.readFile ./hyprfreeze);
		cosmic-ext-applet-clipboard-manager = callPackage ./cosmic-ext-applet-clipboard-manager {};
		nvidia-bind-vfio = nixpkgs.legacyPackages.x86_64-linux.writeShellScriptBin "nvidia-bind-vfio" (builtins.readFile ./nvidia-bind-vfio);
		nvidia-unbind-vfio = nixpkgs.legacyPackages.x86_64-linux.writeShellScriptBin "nvidia-unbind-vfio" (builtins.readFile ./nvidia-unbind-vfio);
	};
}