#!/bin/bash
# Check environment variable consistency across ansible templates
# This ensures the same env var isn't defined with different values in different places
#
# SINGLE SOURCE OF TRUTH ENFORCEMENT:
# - Environment variables should be defined ONCE in group_vars/all.yml
# - Templates should reference variables, not hardcode values

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"

cd "$REPO_ROOT"

errors=0
warnings=0

echo "Checking environment variable consistency..."

# Find all XAI_ environment variables in templates
declare -A env_vars
declare -A env_var_files

# Scan all j2 templates and yml files for Environment= lines with XAI_ variables
while IFS= read -r line; do
    file=$(echo "$line" | cut -d: -f1)
    content=$(echo "$line" | cut -d: -f2-)

    # Extract variable name and value
    if [[ $content =~ Environment[[:space:]]*=[[:space:]]*\"?([A-Z_]+)=([^\"]+)\"? ]]; then
        var_name="${BASH_REMATCH[1]}"
        var_value="${BASH_REMATCH[2]}"

        # Skip variables that use jinja2 templating (these are dynamic)
        if [[ $var_value == *"{{"* ]]; then
            continue
        fi

        # Check if we've seen this variable before with a different value
        if [[ -n "${env_vars[$var_name]}" ]] && [[ "${env_vars[$var_name]}" != "$var_value" ]]; then
            echo -e "${RED}ERROR: Conflicting values for $var_name${NC}"
            echo "  File 1: ${env_var_files[$var_name]} = ${env_vars[$var_name]}"
            echo "  File 2: $file = $var_value"
            ((errors++))
        else
            env_vars[$var_name]="$var_value"
            env_var_files[$var_name]="$file"
        fi
    fi
done < <(grep -rn "Environment.*XAI_" --include="*.j2" --include="*.yml" 2>/dev/null || true)

# Check for hardcoded values that should be variables
hardcoded_patterns=(
    "8545"   # RPC port
    "8333"   # P2P port
    "26657"  # Cosmos RPC
    "26656"  # Cosmos P2P
)

for pattern in "${hardcoded_patterns[@]}"; do
    # Look for hardcoded ports in service files (not in inventory where they should be)
    matches=$(grep -rn "\\b$pattern\\b" --include="*.j2" 2>/dev/null | grep -v "{{" | grep -v "default(" || true)
    if [[ -n "$matches" ]]; then
        echo -e "${YELLOW}WARNING: Hardcoded port $pattern found (should use variables):${NC}"
        echo "$matches" | head -5
        ((warnings++))
    fi
done

# Summary
echo ""
echo "========================================"
if [[ $errors -gt 0 ]]; then
    echo -e "${RED}FAILED: $errors conflicting environment variables found${NC}"
    exit 1
elif [[ $warnings -gt 0 ]]; then
    echo -e "${YELLOW}PASSED with $warnings warnings${NC}"
    exit 0
else
    echo -e "${GREEN}PASSED: All environment variables are consistent${NC}"
    exit 0
fi
