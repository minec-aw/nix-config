{ pkgs, lib, config, ...}: {
  options = {
    nix-ld.enable = lib.mkEnableOption "Enables nix-ld";
  };
  config = lib.mkIf config.nix-ld.enable {
    programs = {
      nix-ld.enable = true;
      nix-ld.libraries = with pkgs; [
        # Graphics / OpenGL
        libGL
        libGLU
        libXi
        libX11
        libXext
        libXrender
        libXtst
        libXrandr
        libXcursor
        libXcomposite
        alsa-lib
        libpulseaudio
        mesa
        libXxf86vm
        # Audio
        libpulseaudio
        libvorbis
        stdenv.cc.cc.lib
      ];
    };
  };
}