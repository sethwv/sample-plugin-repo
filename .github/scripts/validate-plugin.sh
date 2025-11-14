#!/bin/bash
set -e

# validate-plugin.sh
# Validates a plugin PR and generates a validation report comment
#
# Usage: validate-plugin.sh <pr_number> <pr_author> <base_ref>
#
# Arguments:
#   pr_number  - GitHub PR number
#   pr_author  - GitHub username of PR author
#   base_ref   - Base branch reference (e.g., main)
#
# Environment variables required:
#   GITHUB_REPOSITORY - Full repository name (owner/repo)
#   GH_TOKEN          - GitHub token for API access

PR_NUMBER=$1
PR_AUTHOR=$2
BASE_REF=$3

if [[ -z "$PR_NUMBER" || -z "$PR_AUTHOR" || -z "$BASE_REF" ]]; then
  echo "Usage: $0 <pr_number> <pr_author> <base_ref>"
  exit 1
fi

REPO_OWNER=$(echo "$GITHUB_REPOSITORY" | cut -d'/' -f1)
REPO_NAME=$(echo "$GITHUB_REPOSITORY" | cut -d'/' -f2)

# Check if PR author is a repository maintainer
check_repo_maintainer() {
  local author=$1
  PERMISSION=$(gh api repos/$REPO_OWNER/$REPO_NAME/collaborators/$author/permission --jq .permission 2>/dev/null || echo "none")
  if [[ "$PERMISSION" == "admin" || "$PERMISSION" == "write" ]]; then
    echo "1"
  else
    echo "0"
  fi
}

# Validate semantic version format
validate_semver() {
  local version=$1
  if [[ "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "1"
  else
    echo "0"
  fi
}

# Compare two semantic versions
version_greater_than() {
  local new_version=$1
  local old_version=$2
  
  IFS='.' read -r NEW_MAJOR NEW_MINOR NEW_PATCH <<< "$new_version"
  IFS='.' read -r OLD_MAJOR OLD_MINOR OLD_PATCH <<< "$old_version"
  
  if (( NEW_MAJOR > OLD_MAJOR )); then return 0; fi
  if (( NEW_MAJOR < OLD_MAJOR )); then return 1; fi
  if (( NEW_MINOR > OLD_MINOR )); then return 0; fi
  if (( NEW_MINOR < OLD_MINOR )); then return 1; fi
  if (( NEW_PATCH > OLD_PATCH )); then return 0; fi
  return 1
}

# Validate a single plugin
validate_plugin() {
  local plugin_name=$1
  local plugin_dir="plugins/$plugin_name"
  local plugin_json="$plugin_dir/plugin.json"
  local readme="$plugin_dir/README.md"
  local failed=0
  
  echo ""
  echo "### Plugin: \`$plugin_name\`"
  echo ""
  
  # Validate folder name format (lowercase-kebab-case)
  if [[ ! "$plugin_name" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]]; then
    echo "- ❌ Plugin folder name must be lowercase-kebab-case (lowercase letters, numbers, and hyphens only)"
    echo "  Current: \`$plugin_name\`"
    echo "  Example: \`my-plugin-name\`"
    failed=1
  else
    echo "- ✅ Folder name format valid"
  fi
  
  # Check for plugin.json
  if [[ ! -f "$plugin_json" ]]; then
    echo "- ❌ plugin.json missing"
    return 1
  fi
  echo "- ✅ plugin.json exists"
  
  # Check for README.md
  if [[ ! -f "$readme" ]]; then
    echo "- ❌ README.md missing"
    failed=1
  else
    echo "- ✅ README.md exists"
  fi
  
  # Validate JSON syntax
  if ! jq empty "$plugin_json" 2>/dev/null; then
    echo "- ❌ Invalid JSON"
    return 1
  fi
  echo "- ✅ JSON valid"
  
  # Validate required fields
  local required_keys=("name" "version" "owner" "maintainers" "description")
  for key in "${required_keys[@]}"; do
    if ! jq -e ".\"$key\"" "$plugin_json" >/dev/null 2>&1; then
      echo "- ❌ Required property '$key' missing"
      failed=1
    fi
  done
  
  # Extract metadata
  OWNER=$(jq -r '.owner' "$plugin_json")
  MAINTAINERS=$(jq -r '[.maintainers[]?] | join(" ")' "$plugin_json")
  VERSION=$(jq -r '.version' "$plugin_json")
  
  # Check ownership
  IS_REPO_MAINTAINER=$(check_repo_maintainer "$PR_AUTHOR")
  if [[ "$PR_AUTHOR" != "$OWNER" ]] && [[ ! " $MAINTAINERS " =~ " $PR_AUTHOR " ]] && [[ "$IS_REPO_MAINTAINER" -ne 1 ]]; then
    echo "- ❌ **Permission denied**: You are not the owner (\`$OWNER\`), a plugin maintainer, or a repository maintainer"
    failed=1
  else
    echo "- ✅ Permission check passed"
  fi
  
  # Validate version format
  if [[ $(validate_semver "$VERSION") -eq 1 ]]; then
    echo "- ✅ Version format valid (\`$VERSION\`)"
  else
    echo "- ❌ Version must be semantic (got \`$VERSION\`, expected X.Y.Z)"
    failed=1
  fi
  
  # Check version bump for existing plugins
  if git show origin/$BASE_REF:"$plugin_json" > /dev/null 2>&1; then
    OLD_VERSION=$(git show origin/$BASE_REF:"$plugin_json" | jq -r '.version')
    if version_greater_than "$VERSION" "$OLD_VERSION"; then
      echo "- ✅ Version bump valid (\`$OLD_VERSION\` → \`$VERSION\`)"
    else
      echo "- ❌ Version \`$VERSION\` must be greater than current version \`$OLD_VERSION\`"
      failed=1
    fi
  else
    echo "- ✅ New plugin (version \`$VERSION\`)"
  fi
  
  # Summary for this plugin
  if [[ $failed -eq 0 ]]; then
    echo ""
    echo "✅ **All checks passed for \`$plugin_name\`**"
  else
    echo ""
    echo "❌ **Validation failed for \`$plugin_name\`**"
  fi
  
  # Export table data for later rendering
  local keys=($(jq -r 'keys_unsorted[]' "$plugin_json"))
  PLUGIN_TABLE_HEADER="|"
  PLUGIN_TABLE_ROW="|"
  for key in "${keys[@]}"; do
    PLUGIN_TABLE_HEADER+=" $key |"
    value=$(jq -r ".\"$key\" | if type==\"array\" and (map(type) | all(. == \"string\")) then join(\", \") elif type==\"array\" or type==\"object\" then @json else . end" "$plugin_json")
    PLUGIN_TABLE_ROW+=" $value |"
  done
  
  return $failed
}

# Main validation logic
main() {
  echo "<!--PLUGIN_VALIDATION_COMMENT-->"
  echo ""
  echo "# Plugin Validation Results"
  echo ""
  
  local overall_failed=0
  
  # Compute merge base
  MERGE_BASE=$(git merge-base origin/$BASE_REF HEAD)
  
  # Detect modified plugins
  PLUGIN_DIRS=$(git diff --name-only $MERGE_BASE HEAD \
    | grep '^plugins/' | cut -d '/' -f2 | sort -u)
  
  PLUGIN_COUNT=$(echo "$PLUGIN_DIRS" | wc -w)
  
  if [[ -z "$PLUGIN_DIRS" ]]; then
    echo "❌ **Error:** No plugin changes detected"
    exit 1
  fi
  
  echo "**Modified plugins:** $PLUGIN_COUNT"
  echo ""
  
  # Validate each plugin
  local all_tables=""
  for plugin in $PLUGIN_DIRS; do
    if validate_plugin "$plugin"; then
      true  # Success
    else
      overall_failed=1
    fi
    
    # Collect table for this plugin
    if [[ -n "$PLUGIN_TABLE_HEADER" ]]; then
      if [[ -z "$all_tables" ]]; then
        all_tables="$PLUGIN_TABLE_HEADER"$'\n'
        # Generate separator
        separator="|"
        for col in $(echo "$PLUGIN_TABLE_HEADER" | tr '|' '\n' | tail -n +2 | head -n -1); do
          separator+="---|"
        done
        all_tables+="$separator"$'\n'
      fi
      all_tables+="$PLUGIN_TABLE_ROW"$'\n'
    fi
  done
  
  # Print overall status
  echo ""
  echo "---"
  echo ""
  if [[ "$overall_failed" -eq 0 ]]; then
    echo "## 🎉 All validation checks passed!"
    echo ""
    echo "This PR modifies **$PLUGIN_COUNT** plugin(s) and all checks have passed."
  else
    echo "## ❌ Validation failed"
    echo ""
    echo "Some checks failed. Please review the errors above and update your PR."
  fi
  
  # Print plugin information table
  if [[ -n "$all_tables" ]]; then
    echo ""
    echo "---"
    echo ""
    echo ""
    echo "## Plugin Metadata"
    echo ""
    echo "$all_tables"
  fi
  
  exit $overall_failed
}

# Run main
main
