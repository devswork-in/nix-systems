{ pkgs, ... }:

{
  # Ollama service with ROCm GPU acceleration for AMD 780M iGPU
  # 
  # IMPORTANT: BIOS Configuration Required
  # Before using GPU acceleration, configure VRAM allocation in BIOS:
  # 1. Reboot and enter BIOS/UEFI setup
  # 2. Navigate to Advanced → UMA Frame Buffer Size (or similar setting)
  # 3. Set to minimum 1GB (required for detection), recommended 8GB+ for larger models
  # 4. Save and reboot
  #
  # Without sufficient VRAM allocation, Ollama will show:
  # "ROCm unsupported integrated GPU detected" and fall back to CPU inference
  #
  # Service is disabled at boot to improve boot time
  # To start when needed: sudo systemctl start ollama
  # To enable at boot: Set enable = true below
  
  services.ollama = {
    enable = true;
    acceleration = "rocm";  # Enable ROCm GPU acceleration
    
    # GFX version override for AMD 780M (gfx1103 → gfx1100)
    # The 780M reports as gfx1103 but ROCm requires override to gfx1100 (RDNA3)
    rocmOverrideGfx = "11.0.0";
    
    # Environment variables for ROCm configuration
    environmentVariables = {
      # HSA override for AMD 780M compatibility
      # This tells ROCm to treat gfx1103 as gfx1100 (RDNA3 architecture)
      HSA_OVERRIDE_GFX_VERSION = "11.0.0";
      
      # Enable unified memory for better iGPU performance
      # Allows GPU to access system RAM beyond BIOS-allocated VRAM
      # With this enabled, the GPU can use nearly all available system RAM
      # This is especially beneficial for AMD iGPUs with limited VRAM allocation
      GGML_CUDA_ENABLE_UNIFIED_MEMORY = "ON";
    };
  };
  
  # Verification commands after starting service:
  # 1. Check ROCm detection: rocminfo | grep -A 10 "Agent 2"
  # 2. Check OpenCL: clinfo | grep "Device Name"
  # 3. Check Ollama logs: journalctl -u ollama -f
  # 4. Expected log: "inference compute" with library="rocm"
  # 5. Run test model: ollama run tinyllama "test"
  # 6. Check GPU usage: ollama ps (should show "100% GPU")
  # 7. Monitor GPU: amdgpu_top or rocm-smi
}
