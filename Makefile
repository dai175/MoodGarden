SWIFT_FILES := MoodGarden MoodGardenTests MoodGardenUITests

.PHONY: help lint format check setup

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}'

lint: ## Run SwiftLint
	@if command -v swiftlint >/dev/null 2>&1; then \
		swiftlint lint; \
	else \
		echo "warning: SwiftLint is not installed. Run 'brew install swiftlint'"; \
	fi

format: ## Run swift-format (in-place fix)
	@if command -v swift-format >/dev/null 2>&1; then \
		swift-format format --in-place --recursive $(SWIFT_FILES); \
	else \
		echo "warning: swift-format is not installed. Run 'brew install swift-format'"; \
	fi

check: ## Run both tools in check mode (no modifications)
	@echo "==> SwiftLint"
	@$(MAKE) --no-print-directory lint
	@echo ""
	@echo "==> swift-format"
	@if command -v swift-format >/dev/null 2>&1; then \
		swift-format lint --recursive $(SWIFT_FILES); \
	else \
		echo "warning: swift-format is not installed. Run 'brew install swift-format'"; \
	fi

setup: ## Set up git pre-commit hook
	@bash scripts/setup-hooks.sh
