{ pkgs, lib, config, ...}: {
    options = {
        llama-cpp.enable = lib.mkEnableOption "Enables llamacpp for local AI";
    };
    config = lib.mkIf config.llama-cpp.enable {
        services = {
            /*
            ollama = {
                enable = true;
                host = "0.0.0.0";
                package = pkgs.callPackage ./ollama.nix {
                    acceleration = "cuda";
                };
                environmentVariables = {
                    OLLAMA_KV_CACHE_TYPE = "q8_0";
                    OLLAMA_FLASH_ATTENTION = "1";
                };
            };
            open-webui = {
                enable = true;
                host = "0.0.0.0";
                port = 10086;
            };
            */
            llama-cpp = {
                enable = true;
                host = "0.0.0.0";
                port = 10087;
                package = pkgs.callPackage ./llamacpp.nix {
                    cudaSupport = true;
                };
                modelsPreset = {
                  "crow-9b" = {
                    model = "/media/Storage/AI Models/Crow/Qwen3.5-9B-heretic-v2.Q5_K_M.gguf";
                    mmproj = "/media/Storage/AI Models/Crow/Qwen3.5-9B-heretic-v2.BF16-mmproj.gguf";
                    alias = "crow/crow-9b";
                    ctx-size = "65536";
                    n-gpu-layers = "99";
                    flash-attn = "on";
                    temp = "0.6";
                    top-p = "0.95";
                    top-k = "20";
                  };
                };
            };
        };
    };
}
