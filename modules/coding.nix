{ pkgs, lib, config, ...}: {
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
      
      zed-editor
      vscode
      direnv
      git
      python3
      nodejs
      libqalculate
      bun
    ]);
  };
}