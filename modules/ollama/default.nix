{ pkgs, lib, config, ...}: {
  options = {
    ollama.enable = lib.mkEnableOption "Enables llamacpp for local AI";
  };
  config = lib.mkIf config.ollama.enable {
    services = {
      ollama = {
        enable = true;
        host = "0.0.0.0";
        package = pkgs.callPackage ./package.nix {
          acceleration = "cuda";
        };
        environmentVariables = {
          OLLAMA_KV_CACHE_TYPE = "q8_0";
          OLLAMA_FLASH_ATTENTION = "1";
        };
      };
    };
  };
}
