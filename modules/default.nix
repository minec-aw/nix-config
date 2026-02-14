{pkgs, lib, config, ...}: {
  imports = [
    ./virtualization
    ./gaming.nix
    ./desktop-apps.nix
		./coding.nix
    ./nix-ld.nix
    ./sunshine.nix
    ./systemd-boot.nix
    ./tailscale.nix
  ];
  options = {
    font-config.enable = lib.mkEnableOption "downloads fonts";
  };

   config = lib.mkIf config.font-config.enable {
		fonts = {
			fontDir.enable = true;
			fontconfig.enable = true;
			fontconfig.cache32Bit = true;
			packages = (with pkgs; [
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
	};
}