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
                  "qwen3.5g-9b" = {
                    model = "/media/Storage/AI Models/Jackrong-Qwen3.5/Gemini-3.1/Qwen3.5-9B.Q6_K.gguf";
                    mmproj = "/media/Storage/AI Models/Jackrong-Qwen3.5/Gemini-3.1/Qwen3.5-9B.BF16-mmproj.gguf";
                    ctx-size = "98304";
                    n-gpu-layers = "99";
                    flash-attn = "on";
                    temp = "0.6";
                    top-p = "0.95";
                    top-k = "20";
                    cache-type-k = "bf16";
                    cache-type-v = "bf16";
                    min-p = "0.01";

                  };
                  "qwen3.5o-9b" = {
                    model = "/media/Storage/AI Models/Jackrong-Qwen3.5/Opus/Qwen3.5-9B.Q6_K.gguf";
                    mmproj = "/media/Storage/AI Models/Jackrong-Qwen3.5/Opus/Qwen3.5-9B.BF16-mmproj.gguf";
                    ctx-size = "98304";
                    n-gpu-layers = "99";
                    flash-attn = "on";
                    temp = "0.6";
                    top-p = "0.95";
                    top-k = "20";
                    cache-type-k = "bf16"; 
                    cache-type-v = "bf16";
                    min-p = "0.01";
                  };
                };
            };
        };
    };
}
