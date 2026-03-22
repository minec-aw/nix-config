{ pkgs, lib, config, ...}: {
  options = {
    gaming.enable = lib.mkEnableOption "Gets steam, faugus, r2modman, protonplus and prismlauncher";
    gaming.vr = lib.mkEnableOption "Enable VR support with wivrn and CUDA";
  };
  config = lib.mkIf config.gaming.enable {
    environment.systemPackages = with pkgs; [
      faugus-launcher
      prismlauncher
      r2modman
      protonplus
    ] ++ lib.optionals config.gaming.vr [
      pkgs.wayvr
      bs-manager
    ];
    environment.sessionVariables = lib.mkIf config.gaming.vr {
        PRESSURE_VESSEL_IMPORT_OPENXR_1_RUNTIMES = 1;
    };
    programs.steam = {
      #gamescopeSession.enable = true;
      enable = true;
      protontricks.enable = true;
      /*package = with pkgs; steam.override {
        /*extraPkgs = pkgs: [
          attr
        ];
        extraEnv = {
          LD_AUDIT = "${inputs.sls-steam.packages.${pkgs.stdenv.hostPlatform.system}.sls-steam}/SLSsteam.so";
        };
        /*extraLibraries = (pkgs: [
          #(pkgs.callPackage ./LocalPackages/openssl {}).openssl_1_1
          pkgs.openssl
          pkgs.nghttp2
          pkgs.fontconfig
          pkgs.libidn2
          pkgs.rtmpdump
          pkgs.libpsl
          pkgs.curl
          pkgs.krb5
          pkgs.keyutils
        ]);
      };*/
      remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
      #dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    };
    services.wivrn = lib.mkIf config.gaming.vr {
      enable = true;
      defaultRuntime = true;
      openFirewall = true;
      package = pkgs.wivrn.override { cudaSupport = true; };
    };
  };
}
