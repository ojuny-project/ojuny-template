/*
  @menu
  displayname = "Graphics";
  icon = "hardware-driver-symbolic";
  order = 40;
  description = "Graphics drivers, hybrids, compute accelerators and hardware acceleration";
  category = "07-System";
*/

{ self, inputs, ... }: {

  flake.modules.nixos.system-graphics =
    { config, lib, ... }:
    let
      gpuTarget = config.ojuny.gpu;
      managed = config.ojuny.hardware.gpu.managed;
      resolvedGpu =
        if gpuTarget == "auto" then config.ojuny.hardware.gpu.detected else gpuTarget;
      gpu = if resolvedGpu == "auto" || resolvedGpu == "unknown" then "none" else resolvedGpu;
      amdSelected = lib.elem gpu [
        "amd"
        "hybrid-amd-nvidia"
        "hybrid-intel-amd"
      ];
    in
    {
      imports = [ self.modules.nixos.system-graphics-backend ];

      config = {

        # @option widget = "dropdown"; label = "GPU vendor"; group = "Graphics"; groupOrder = 10; order = 10; description = "auto reads the GPU layout and bus IDs from the facter report. The other choices are manual overrides. Use none for a VM or a machine without a usable GPU: it enables software rendering, allows the wlroots software renderer and switches Qt to the basic render loop."; choices = [ "auto" "intel" "amd" "nvidia" "hybrid-intel-nvidia" "hybrid-amd-nvidia" "hybrid-intel-amd" "none" ]; visibleWhen.path = "ojuny.hardware.gpu.managed"; visibleWhen.equals = false;
        ojuny.gpu = "auto";

        # @option widget = "text"; label = "Intel bus ID"; group = "Hybrid"; order = 10; visibleWhen.path = "ojuny.gpu"; visibleWhen.equals = [ "hybrid-intel-nvidia" "hybrid-intel-amd" ];
        ojuny.gpuBusIds.intel = "PCI:0:2:0";

        # @option widget = "text"; label = "AMD bus ID"; group = "Hybrid"; order = 20; visibleWhen.path = "ojuny.gpu"; visibleWhen.equals = [ "hybrid-amd-nvidia" "hybrid-intel-amd" ];
        ojuny.gpuBusIds.amd = "PCI:5:0:0";

        # @option widget = "text"; label = "NVIDIA bus ID"; group = "Hybrid"; order = 30; visibleWhen.path = "ojuny.gpu"; visibleWhen.equals = [ "hybrid-intel-nvidia" "hybrid-amd-nvidia" ];
        ojuny.gpuBusIds.nvidia = "PCI:1:0:0";

        # @option widget = "text"; label = "Discrete GPU bus ID"; group = "Hybrid"; order = 40; visibleWhen.path = "ojuny.gpu"; visibleWhen.equals = [ "intel" "amd" ]; description = "Used by the Mesa offload wrapper for Intel+Intel and AMD+AMD.";
        ojuny.gpuBusIds.discrete = "PCI:5:0:0";

        # @option widget = "dropdown"; label = "NVIDIA driver branch"; group = "NVIDIA"; groupOrder = 40; order = 10; choices = [ "production" "latest" "legacy_580" "nouveau" ]; visibleWhen.path = "ojuny.gpu"; visibleWhen.equals = [ "nvidia" "hybrid-intel-nvidia" "hybrid-amd-nvidia" ]; description = "Production is the stable 595 branch. Latest is 615 and may break. Legacy 580 covers Maxwell, Pascal and Volta. Nouveau uses Mesa and NVK.";
        ojuny.gpuNvidia.branch = "production";

        # @option widget = "switch"; label = "NVIDIA open kernel modules"; group = "NVIDIA"; groupOrder = 40; order = 20; visibleWhen.path = "ojuny.gpu"; visibleWhen.equals = [ "nvidia" "hybrid-intel-nvidia" "hybrid-amd-nvidia" ]; description = "Use the open kernel modules for Turing and newer. Ignored for legacy 580 and Nouveau.";
        ojuny.gpuNvidia.open = false;

        # @option widget = "switch"; label = "Legacy Intel configuration"; group = "Intel"; groupOrder = 20; order = 10; visibleWhen.path = "ojuny.gpu"; visibleWhen.equals = [ "intel" "hybrid-intel-nvidia" "hybrid-intel-amd" ]; description = "Use the i965 VA-API stack for Haswell and older Intel graphics instead of iHD.";
        ojuny.gpuIntel.legacy = false;

        # @option widget = "switch"; label = "Legacy AMD configuration"; group = "AMD"; groupOrder = 30; order = 10; visibleWhen.path = "ojuny.gpu"; visibleWhen.equals = [ "amd" "hybrid-amd-nvidia" "hybrid-intel-amd" ]; description = "Use the radeon driver and r600 VA-API for pre-GCN AMD graphics.";
        ojuny.gpuAmd.legacy = false;

        # @option widget = "switch"; label = "GCN 1.0 and 2.0 support"; group = "AMD"; groupOrder = 30; order = 20; visibleWhen.path = "ojuny.gpu"; visibleWhen.equals = [ "amd" "hybrid-amd-nvidia" "hybrid-intel-amd" ]; description = "Use amdgpu on SI and CIK cards and disable the matching radeon support. Ignored when the legacy configuration is on.";
        ojuny.gpuAmd.siCik = false;

        # @option widget = "switch"; label = "Offload command"; group = "Hybrid"; order = 50; visibleWhen.path = "ojuny.gpu"; visibleWhen.equals = [ "hybrid-intel-nvidia" "hybrid-amd-nvidia" "hybrid-intel-amd" ]; description = "Install ojuny-offload. NVIDIA hybrids use the PRIME render-offload variables; Intel+AMD uses DRI_PRIME and MESA_VK_DEVICE_SELECT.";
        ojuny.gpuOffload.enable = true;

        # @option widget = "switch"; label = "Mesa offload command"; group = "Hybrid"; order = 60; visibleWhen.path = "ojuny.gpu"; visibleWhen.equals = [ "intel" "amd" ]; description = "Install ojuny-offload for Intel+Intel or AMD+AMD. Uses DRI_PRIME and MESA_VK_DEVICE_SELECT.";
        ojuny.gpuMesaOffload.enable = false;

        # @option widget = "dropdown"; label = "Compute accelerator"; group = "Compute"; groupOrder = 50; order = 10; choices = [ "none" "amd-instinct" "nvidia-datacenter" "intel-datacenter" ]; description = "Install ROCm, CUDA or oneAPI for a compute GPU without changing the display GPU. Datacenter GPUs are not display targets.";
        ojuny.gpuCompute = "none";

        # @option widget = "switch"; label = "Graphics acceleration"; group = "Graphics"; groupOrder = 10; order = 20;
        hardware.graphics.enable = true;

        # @option widget = "switch"; label = "32-bit graphics"; group = "Graphics"; groupOrder = 10; order = 30; description = "Install 32-bit graphics libraries for 32-bit games and Wine. A hardware profile that owns the GPU settings supplies its own value.";
        ojuny.gpu32Bit = false;

        # @option widget = "switch"; label = "Redistributable firmware"; group = "Graphics"; groupOrder = 10; order = 40; description = "Firmware blobs for Wi-Fi, GPUs and other devices.";
        hardware.enableRedistributableFirmware = true;

        # AMD
        # @option widget = "switch"; label = "AMDGPU in initrd"; group = "AMD"; groupOrder = 30; order = 30; visibleWhen.path = "ojuny.gpu"; visibleWhen.equals = [ "amd" "hybrid-amd-nvidia" "hybrid-intel-amd" ];
        hardware.amdgpu.initrd.enable = lib.mkIf (!managed && amdSelected && !config.ojuny.gpuAmd.legacy) true;

      };

    };

}
