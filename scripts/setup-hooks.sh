#!/bin/bash
# Set up git hooks for MoodGarden
set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel)"
HOOK_SRC="$REPO_ROOT/scripts/pre-commit"
HOOK_DST="$REPO_ROOT/.git/hooks/pre-commit"

# Create symlink
ln -sf "$HOOK_SRC" "$HOOK_DST"
chmod +x "$HOOK_SRC"
echo "pre-commit hook installed."

# Check tool availability
echo ""
echo "Tool status:"
if command -v swiftlint >/dev/null 2>&1; then
    echo "  SwiftLint:   $(swiftlint version)"
else
    echo "  SwiftLint:   not installed (brew install swiftlint)"
fi

if command -v swift-format >/dev/null 2>&1; then
    echo "  swift-format: $(swift-format --version)"
else
    echo "  swift-format: not installed (brew install swift-format)"
fi
