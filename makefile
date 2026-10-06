# Define binary directory for local tool installations
LOCAL_BIN := /usr/local/bin
PATH := $(LOCAL_BIN):$(PATH)

# Tool versions
PROTOC_GEN_GO_VERSION := v1.34.2
PROTOC_GEN_GO_GRPC_VERSION := v1.5.1

# Protobuf directories
PROTO_DIR := proto
OUT_DIR := proto

.PHONY: all deps compile clean

all: deps compile

# 1. Install required Go plugins locally without polluting global GOPATH
deps:
	@mkdir -p $(LOCAL_BIN)
	@GOBIN=$(LOCAL_BIN) go install google.golang.org/protobuf/cmd/protoc-gen-go@$(PROTOC_GEN_GO_VERSION)
	@GOBIN=$(LOCAL_BIN) go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@$(PROTOC_GEN_GO_GRPC_VERSION)

# 2. Find and compile all .proto files recursively
compile:
	@echo "Generating Go code from Protobuf files..."
	@protoc \
		--proto_path=$(PROTO_DIR) \
		--go_out=$(OUT_DIR) \
		--go_opt=paths=source_relative \
		--go-grpc_out=$(OUT_DIR) \
		--go-grpc_opt=paths=source_relative \
		$(shell find $(PROTO_DIR) -name "*.proto")
	@echo "Code generation complete!"

# 3. Clean generated files (assumes files are named *.pb.go)
clean:
	@echo "Cleaning generated files..."
	@find $(OUT_DIR) -type f -name "*.pb.go" -delete
	@rm -rf $(LOCAL_BIN)
	@echo "Clean complete."
