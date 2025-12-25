{
  description = "CUDA C++ development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config = {
            allowUnfree = true;
            cudaSupport = true;
          };
        };
        
        # Check if system supports CUDA
        isCudaSupported = pkgs.stdenv.isLinux && (pkgs.stdenv.isx86_64 || pkgs.stdenv.isAarch64);
        
      in
      {
        devShells.default = pkgs.mkShell {
          name = "cuda-dev-env";
          
          buildInputs = with pkgs; [
            # Build tools (available on all platforms)
            gnumake
            gcc
            git
            
            # Development utilities
            rsync
            openssh
          ] ++ pkgs.lib.optionals isCudaSupported [
            # CUDA Toolkit (only on supported Linux systems)
            cudatoolkit
            cudaPackages.cudnn
          ];

          shellHook = ''
            echo "╔════════════════════════════════════════════════════════════╗"
            echo "║           CUDA C++ Development Environment                 ║"
            echo "╚════════════════════════════════════════════════════════════╝"
            echo ""
            
            ${if isCudaSupported then ''
              echo "CUDA Toolkit: ${pkgs.cudatoolkit.version}"
              echo ""
              export CUDA_PATH="${pkgs.cudatoolkit}"
              export CUDA_HOME="${pkgs.cudatoolkit}"
              export LD_LIBRARY_PATH="${pkgs.cudatoolkit}/lib:${pkgs.cudatoolkit.lib}/lib''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
              export PATH="${pkgs.cudatoolkit}/bin:$PATH"
              
              echo "✓ Running on Linux - CUDA toolkit installed"
              echo ""
            '' else ''
              echo "⚠️  WARNING: Running on ${system}"
              echo "   CUDA is not available on this platform."
              echo "   You can still:"
              echo "   • Write and review CUDA code"
              echo "   • Use this as a base for remote development"
              echo ""
              echo "   To run CUDA code, use:"
              echo "   • Remote GPU server (SSH + rsync)"
              echo "   • Cloud GPU: Google Colab, AWS, Azure, Paperspace"
              echo "   • Docker on Linux with NVIDIA GPU"
              echo ""
            ''}
            
            # Check for NVIDIA GPU (Linux only)
            if command -v nvidia-smi &> /dev/null; then
              echo "GPU Information:"
              nvidia-smi --query-gpu=name,driver_version,memory.total --format=csv,noheader
              echo ""
            fi
            
            echo "Available commands:"
            ${if isCudaSupported then ''
              echo "  make          - Build all CUDA programs"
              echo "  make run      - Build and run all programs"
              echo "  nvcc --version - Check CUDA compiler version"
            '' else ''
              echo "  make          - (Requires CUDA on Linux)"
              echo "  make run      - (Requires CUDA on Linux with GPU)"
              echo ""
              echo "For remote development:"
              echo "  rsync -avz . user@gpu-server:/path/to/project"
              echo "  ssh user@gpu-server 'cd /path/to/project && nix develop --command make run'"
            ''}
            echo ""
          '';
        };
      }
    );
}
