{pkgs, lib, config, ...}: {
  options = {
    niri.enable = lib.mkEnableOption "Enables Niri compositor for use";
  };
  config = lib.mkIf config.niri.enable {
    programs = {
      nautilus-open-any-terminal = {
        enable = true;
        terminal = "footclient";
      };
      niri.enable = true;
      foot = {
        enable = true;
        settings = {
          main = {
            font = "jetbrains mono:size=12";
            resize-keep-grid = "no";
          };
          csd.size = 28;
          scrollback.lines = 100000;
          cursor = {
            style = "beam";
            blink = "yes";
            beam-thickness = 1.5;
          };
          colors.background = "000000";
          key-bindings.search-start = "Control+f";
          search-bindings = {
            find-prev = "Up";
            find-next = "Down";
          };
        };
      };
    };
    services = {
      tuned.enable = true;
      gvfs.enable = true;
      udisks2.enable = true;
      upower.enable = true;
      keyd = {
        enable = true;
        keyboards.default = {
          ids = [ "*" ];
          settings.main = {
            leftmeta = "overload(meta, macro(leftmeta+o))"; # Make left meta tap open anyrun keybind
          };
        };
      };
      iio-niri.enable = true;
    };
    environment.systemPackages = with pkgs; [
      noctalia-shell
      cliphist
      libnotify
      wl-clipboard
      kdePackages.qt6ct
      nwg-look
      nautilus
      nautilus-open-any-terminal
      xwayland-satellite

      adwaita-qt
      adwaita-qt6
      adwaita-icon-theme
      bazaar
      adw-gtk3
      loupe
      showtime
      decibels

    ];
  };
}
