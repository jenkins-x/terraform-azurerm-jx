TERRAFORM_VAR_FILE = _terraform.tfvars
GO := GO111MODULE=on go
GOTEST := $(GO) test
GOBUILD := $(GO) build
VERIFY_KEY_VAULT_SRC_FILE=./cmd/verify_key_vault
VERIFY_KEY_VAULT_NAME=verify_key_vault
.DEFAULT_GOAL := help

.PHONY: help
help:
	@grep -h -E '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: build
build: build-verify-key-vault

.PHONY: linux
linux: build-verify-key-vault-linux

build-verify-key-vault:
	$(GOBUILD) -o build/$(VERIFY_KEY_VAULT_NAME)  $(VERIFY_KEY_VAULT_SRC_FILE)

build-verify-key-vault-linux: ## Build for Linux
	GOOS=linux GOARCH=amd64 CGO_ENABLED=0 $(GOBUILD) -o build/linux/$(VERIFY_KEY_VAULT_NAME) $(VERIFY_KEY_VAULT_SRC_FILE)
	chmod +x build/linux/$(VERIFY_KEY_VAULT_NAME)
