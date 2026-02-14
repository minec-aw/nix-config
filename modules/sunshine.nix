{ pkgs, lib, config, ...}: {
  options = {
    sunshine.enable = lib.mkEnableOption "Enables sunshine";
  };
  services.sunshine = lib.mkIf config.sunshine.enable {
    enable = true;
    settings = {
      sunshine_name = "Minec";
      adapter_name = "/dev/dri/renderD128";
      capture = "kms";
      native_pen_touch = false;
      encoder = "vaapi";
    };
    applications = {
      env = {
        PATH = "$(PATH):$(HOME)/.local/bin";
      };
      apps = [
        {
          name = "Desktop";
          exclude-global-prep-cmd = "false";
          auto-detach = "true";
        }
      ];
    };

    /*package = (pkgs.sunshine.override {
      cudaSupport = true;
    });*/
    capSysAdmin = true;
    openFirewall = true;
    autoStart = true;
  };
}