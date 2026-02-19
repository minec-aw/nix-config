{ pkgs, lib, config, ...}: {
  options = {
    ollama.enable = lib.mkEnableOption "Enables ollama for local AI";
  };
  config = lib.mkIf config.ollama.enable {
    services.ollama = {
        enable = true;
        package = pkgs.ollama-cuda;
    };
  };
}