{ pkgs, lib, config, ...}: {
    options = {
        llama-cpp.enable = lib.mkEnableOption "Enables llamacpp for local AI";
    };
    config = lib.mkIf config.llama-cpp.enable {
        services = {
            searx = {
                enable = true;
                settings.server = {
                    port = "10082";
                    bind_address = "127.0.0.1";
                    secret_key = "noiujkhlfdgsfjhfiujqehf3r9p8furfg89p0uyg3597ph35p9umtxcn34590";
                };
            };
            ollama = {
                enable = true;
                host = "0.0.0.0";
                package = pkgs.callPackage ./ollama.nix {
                    acceleration = "cuda";
                };
                environmentVariables = {
                    OLLAMA_KV_CACHE_TYPE = "bf16";
                    OLLAMA_FLASH_ATTENTION = "1";
                    OLLAMA_NUM_PARALLEL = "1";
                };
            };
            /*open-webui = {
                enable = true;
                host = "0.0.0.0";
                port = 10086;
            };*/

        };
    };
}
