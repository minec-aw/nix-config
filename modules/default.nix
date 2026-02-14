{pkgs, lib, config, ...}: {
  imports = [
    ./virtualization
    ./gaming.nix
    ./desktop-apps.nix
    ./nix-ld.nix
    ./sunshine.nix
    ./systemd-boot.nix
    ./tailscale.nix
  ];
  options = {
    fonts.enable = lib.mkEnableOption "downloads fonts";
  };
  virtualisation.waydroid.enable = lib.mkIf config.waydroid.enable true;

  fonts = {
		fontDir.enable = true;
		fontconfig.enable = true;
		fontconfig.cache32Bit = true;
		packages = lib.mkIf config.fonts.enable (with pkgs; [
			noto-fonts
			noto-fonts-cjk-sans
			noto-fonts-color-emoji
			liberation_ttf
			fira-code
			fira-code-symbols
			mplus-outline-fonts.githubRelease
			dina-font
			proggyfonts
			#nerdfonts
			nerd-fonts.fira-code
  		nerd-fonts.droid-sans-mono
			corefonts
			liberation_ttf
			vista-fonts
			jetbrains-mono
			#inputs.apple-fonts.packages.${pkgs.system}.sf-pro
		]);
	};
}