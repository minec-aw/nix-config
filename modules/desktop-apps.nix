{ pkgs, lib, config, ...}: {
  options = {
    desktop-apps.enable = lib.mkEnableOption "Generic desktop apps";
  };
  environment.systemPackages = lib.mkIf config.desktop-apps.enable (with pkgs; [
    libreoffice-fresh
    nicotine-plus
    okteta
    pinta
    kdePackages.isoimagewriter
    kdiskmark
    btop
    baobab
    gnome-disk-utility
    scrcpy
    chromium
    vesktop
    tenacity
    qpwgraph
    (inputs.zen-browser.packages."${pkgs.stdenv.hostPlatform.system}".default.override {
      nativeMessagingHosts = [
        pkgs.firefoxpwa
        pkgs.kdePackages.plasma-browser-integration
      ];
    })
    firefoxpwa
    appimage-run
    pwvucontrol
    kdePackages.plasma-browser-integration
    apple-cursor
    krita
  ]);
}