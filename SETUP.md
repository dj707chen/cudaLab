# CUDA Development Setup with Nix Flakes

## Important Note for macOS Users

⚠️ **CUDA requires NVIDIA GPU hardware which is not available on macOS** (especially Apple Silicon Macs). While you can use Nix to set up the CUDA compiler on macOS, you cannot execute CUDA programs without an NVIDIA GPU.

## Prerequisites

1. **Install Nix with flakes support:**
   ```bash
   # Install Nix (if not already installed)
   curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
   ```

2. **Enable experimental features** (if not already enabled):
   ```bash
   mkdir -p ~/.config/nix
   echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
   ```

## Quick Start

### Option 1: Using Nix Flake (Recommended)

```bash
# Enter the development environment
nix develop

# Build CUDA programs
make

# Note: Running will fail on macOS without NVIDIA GPU
make run
```

### Option 2: Using direnv (Automatic)

If you have `direnv` installed:

```bash
# Install direnv
nix-env -iA nixpkgs.direnv

# Hook direnv into your shell (add to ~/.zshrc or ~/.bashrc)
eval "$(direnv hook zsh)"  # or bash

# Allow direnv in this directory
direnv allow

# The environment will automatically load when you cd into this directory
```

## Platform-Specific Instructions

### On macOS

You can compile CUDA code but **cannot run it locally**. Options:

1. **Remote Development:**
   ```bash
   # Compile locally
   nix develop
   make
   
   # Deploy to remote Linux machine with GPU
   rsync -avz build/ user@gpu-server:/path/to/cudaLab/build/
   ssh user@gpu-server "cd /path/to/cudaLab && ./build/add_grid"
   ```

2. **Use Cloud GPU Services:**
   - Google Colab (free tier)
   - AWS EC2 with GPU instances
   - Paperspace, Lambda Labs, etc.

3. **Docker with Remote Execution:**
   ```bash
   # Build Docker image with CUDA support
   # Deploy to Linux machine with NVIDIA Container Toolkit
   ```

### On Linux with NVIDIA GPU

```bash
# Enter development environment
nix develop

# Verify GPU is available
nvidia-smi

# Build and run
make run
```

## Troubleshooting

### "CUDA not found" on macOS
This is expected. Nix can provide the CUDA compiler, but it won't work without NVIDIA hardware.

### Build errors on macOS
Some CUDA features are Linux-specific. The build may partially work for cross-compilation purposes.

### Missing NVIDIA drivers on Linux
```bash
# Check if drivers are installed
nvidia-smi

# If not, install NVIDIA drivers (outside of Nix)
# Ubuntu/Debian:
sudo apt install nvidia-driver-535

# Arch Linux:
sudo pacman -S nvidia nvidia-utils
```

## Alternative: Docker Development

If you want a more portable solution:

```bash
# Create Dockerfile
cat > Dockerfile <<EOF
FROM nvidia/cuda:12.3.0-devel-ubuntu22.04

RUN apt-get update && apt-get install -y \\
    build-essential \\
    && rm -rf /var/lib/apt/lists/*

WORKDIR /workspace
COPY . .

RUN make
EOF

# Build and run (requires Linux with NVIDIA Container Toolkit)
docker build -t cuda-lab .
docker run --gpus all cuda-lab ./build/add_grid
```

## Resources

- [Nix Flakes Documentation](https://nixos.wiki/wiki/Flakes)
- [CUDA on NixOS](https://nixos.wiki/wiki/CUDA)
- [Remote CUDA Development](https://code.visualstudio.com/docs/remote/ssh)
