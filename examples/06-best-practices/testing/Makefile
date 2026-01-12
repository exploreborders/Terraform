# Makefile for Terraform Testing

.PHONY: help test test-unit test-integration test-performance clean deps fmt validate

# Default target
help: ## Show this help message
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Targets:'
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  %-15s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

# Install dependencies
deps: ## Install Go dependencies
	go mod download
	go mod tidy

# Format Go code
fmt: ## Format Go code
	go fmt ./...

# Run all tests
test: ## Run all tests
	go test -v ./...

# Run unit tests only
test-unit: ## Run unit tests (VPC and security group tests)
	go test -v -run "TestVpcModule|TestSecurityGroupModule" ./...

# Run integration tests only
test-integration: ## Run integration and end-to-end tests
	go test -v -run "TestEndToEnd|TestTerraform|TestResourceCleanup|TestIdempotency" ./...

# Run performance tests
test-performance: ## Run performance tests (may take longer)
	go test -v -run "TestPerformance" -timeout 30m ./...

# Run tests with coverage
test-coverage: ## Run tests with coverage report
	go test -v -coverprofile=coverage.out ./...
	go tool cover -html=coverage.out -o coverage.html
	@echo "Coverage report generated: coverage.html"

# Run tests in short mode (skip long-running tests)
test-short: ## Run tests in short mode
	go test -v -short ./...

# Run tests with race detection
test-race: ## Run tests with race detection
	go test -v -race ./...

# Clean up test artifacts
clean: ## Clean up test artifacts
	rm -f coverage.out coverage.html
	go clean -testcache

# Validate Terraform configurations
validate: ## Validate all Terraform configurations
	@echo "Validating modules/network..."
	@cd ../../../modules/network && terraform init -backend=false && terraform validate
	@echo "Validating examples/01-basics..."
	@cd ../../../examples/01-basics && terraform init -backend=false && terraform validate
	@echo "Validating examples/02-resources/ec2-instance..."
	@cd ../../../examples/02-resources/ec2-instance && terraform init -backend=false && terraform validate
	@echo "Validating examples/02-resources/vpc-network..."
	@cd ../../../examples/02-resources/vpc-network && terraform init -backend=false && terraform validate
	@echo "Validation complete!"

# Lint Go code
lint: ## Lint Go code
	golangci-lint run ./...

# Run tests in CI mode (no color, json output)
test-ci: ## Run tests in CI mode
	go test -v -json ./... | tee test-results.json

# Benchmark tests
benchmark: ## Run benchmark tests
	go test -bench=. -benchmem ./...

# Watch for changes and run tests
watch: ## Watch for changes and run tests (requires entr)
	find . -name "*.go" | entr -r make test-short

# Docker-based testing
test-docker: ## Run tests in Docker container
	docker run --rm -v $(PWD):/app -w /app golang:1.21 make test

# Update dependencies
update-deps: ## Update Go dependencies
	go get -u ./...
	go mod tidy

# Security scan
security-scan: ## Run security scan on dependencies
	gosec ./...

# Generate test report
report: ## Generate test report
	go test -v -json ./... > test-results.json
	@echo "Test results saved to test-results.json"