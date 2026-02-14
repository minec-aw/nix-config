{ pkgs, lib, config, ...}: {
  options = {
    coding.enable = lib.mkEnableOption "Coding & development & debug & system utilities";
  };
  environment.systemPackages = lib.mkIf config.desktop-apps.enable (with pkgs; [
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
}