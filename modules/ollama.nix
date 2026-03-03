{ pkgs, lib, config, ...}: {
  options = {
    ollama.enable = lib.mkEnableOption "Enables ollama for local AI";
  };
  config = lib.mkIf config.ollama.enable {
    services.llama-cpp = {
      enable = true;
      port = 10085;
      package = (pkgs.llama-cpp.override {
        cudaSupport = true;
      });
      modelsPreset = {
        "qwen3-30b-moe" = {
          hf-repo = "Qwen/Qwen3-VL-30B-A3B-Instruct-GGUF";
          hf-file = "Qwen3VL-30B-A3B-Instruct-Q4_K_M.gguf";
          
          ctx-size = "8192";
          n-gpu-layers = "25";
          flash-attn = "on";
        };
        "qwen3.5-35b" = {
          hf-repo = "unsloth/Qwen3.5-35B-A3B-GGUF";
          hf-file = "Qwen3.5-35B-A3B-UD-Q4_K_M.gguf";

          ctx-size = "16384";
          n-gpu-layers = "15";
          flash-attn = "on";
        };
        "qwen2.5-14b" = {
          hf-repo = "Qwen/Qwen2.5-Coder-14B-Instruct-GGUF";
          hf-file = "qwen2.5-coder-14b-instruct-q4_k_m.gguf";

          ctx-size = "16384";
          n-gpu-layers = "99";
          flash-attn = "on";
        };
      };
    };
  };
}