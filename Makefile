.DEFAULT_GOAL := help

TFLINT_VERSION := v0.39.3.0
TFSEC_VERSION := v1.27.5
TFDOCS_VERSION := 0.16.0

.PHONY: lint
lint: ## Run checks based on `tffmt` and `tflint` rules
	@terraform fmt -check=true -diff=true -recursive
	@docker run --rm \
	  -v "$(PWD):/app" \
	  -w /app \
	  --entrypoint= \
	  ghcr.io/terraform-linters/tflint-bundle:$(TFLINT_VERSION) \
	  sh -c "find . -type f -name variables.tf -exec dirname {} \; | xargs -I {} tflint -c /app/.tflint.hcl {}"

.PHONY: security
security: ## Run checks based on `tfsec` rules
	@docker run --rm -v "$(PWD):/app" aquasec/tfsec:$(TFSEC_VERSION) /app

.PHONY: can-release
can-release: lint security ## Ensure code meets release requirements

.PHONY: format
format: ## Apply formatting rules
	@terraform fmt -recursive

.PHONY: documentation
documentation: ## Generate documentation using `terraform-docs`
	@docker run --rm \
	  -v "$(PWD):/app" \
	  --entrypoint= \
	  quay.io/terraform-docs/terraform-docs:$(TFDOCS_VERSION) \
	  sh -c "find . -type f -name variables.tf -exec dirname {} \; | xargs -I {} terraform-docs -c /app/.terraform-docs.yml {}"

# https://blog.thapaliya.com/posts/well-documented-makefiles/
.PHONY: help
help:
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)
