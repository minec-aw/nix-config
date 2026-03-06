{ pkgs, lib, inputs, config, ...}: {
  options = {
    coding.enable = lib.mkEnableOption "Coding & development & debug & system utilities";
  };
  config = lib.mkIf config.coding.enable {
    environment.systemPackages = (with pkgs; [
      nixd
      alejandra
      jq
      socat
      sysstat
      imagemagick
      wget
      lshw
      chntpw
      lsof
      psmisc
      android-tools
      inputs.zed.packages.${stdenv.hostPlatform.system}.default
      vscodium-fhs
      direnv
      git
      python3
      nodejs
      libqalculate
      bun
    ]);
  };
}
