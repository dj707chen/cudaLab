# CUDA C++ Compiler
NVCC = nvcc

# Compiler flags
NVCCFLAGS = -O3 -std=c++11

# Source directory
SRC_DIR = src

# Build directory
BUILD_DIR = build

# Source files
SOURCES = $(SRC_DIR)/add.cu $(SRC_DIR)/add_block.cu $(SRC_DIR)/add_grid.cu

# Target executables
TARGETS = $(BUILD_DIR)/add $(BUILD_DIR)/add_block $(BUILD_DIR)/add_grid

# Default target
all: $(BUILD_DIR) $(TARGETS)

# Create build directory
$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

# Build add (single thread version)
$(BUILD_DIR)/add: $(SRC_DIR)/add.cu
	$(NVCC) $(NVCCFLAGS) $< -o $@

# Build add_block (single block with 256 threads)
$(BUILD_DIR)/add_block: $(SRC_DIR)/add_block.cu
	$(NVCC) $(NVCCFLAGS) $< -o $@

# Build add_grid (multiple blocks with grid-stride loop)
$(BUILD_DIR)/add_grid: $(SRC_DIR)/add_grid.cu
	$(NVCC) $(NVCCFLAGS) $< -o $@

# Run all programs
run: all
	@echo "Running single thread version..."
	@$(BUILD_DIR)/add
	@echo ""
	@echo "Running single block (256 threads) version..."
	@$(BUILD_DIR)/add_block
	@echo ""
	@echo "Running multiple blocks (grid-stride) version..."
	@$(BUILD_DIR)/add_grid

# Clean build artifacts
clean:
	rm -rf $(BUILD_DIR)

# Help target
help:
	@echo "Available targets:"
	@echo "  all        - Build all CUDA programs (default)"
	@echo "  run        - Build and run all programs"
	@echo "  clean      - Remove build directory"
	@echo "  help       - Display this help message"
	@echo ""
	@echo "Individual targets:"
	@echo "  $(BUILD_DIR)/add       - Build single thread version"
	@echo "  $(BUILD_DIR)/add_block - Build single block version"
	@echo "  $(BUILD_DIR)/add_grid  - Build grid-stride version"

.PHONY: all run clean help
