#!/bin/bash
set -e

# publish-plugins.sh
# Builds plugin ZIPs, generates manifest, and publishes to releases branch
#
# Usage: publish-plugins.sh <source_branch>
#
# Arguments:
#   source_branch - Source branch to read plugins from (e.g., main)
#
# Environment variables required:
#   GITHUB_REPOSITORY - Full repository name (owner/repo)
#   GITHUB_TOKEN      - GitHub token with write access

SOURCE_BRANCH=$1

if [[ -z "$SOURCE_BRANCH" ]]; then
  echo "Usage: $0 <source_branch>"
  exit 1
fi

RELEASES_BRANCH="releases"
MAX_VERSIONED_ZIPS=10

echo "🚀 Publishing plugins from $SOURCE_BRANCH to $RELEASES_BRANCH"

# Create temporary working directory
TMPDIR=$(mktemp -d)
trap "rm -rf $TMPDIR" EXIT

echo "📦 Cloning repository..."
git clone --no-checkout "https://x-access-token:${GITHUB_TOKEN}@github.com/${GITHUB_REPOSITORY}.git" "$TMPDIR/repo"
cd "$TMPDIR/repo"

# Configure git
git config user.name "github-actions[bot]"
git config user.email "github-actions[bot]@users.noreply.github.com"

# Checkout or create releases branch
echo "🔀 Setting up $RELEASES_BRANCH branch..."
if git ls-remote --exit-code --heads origin $RELEASES_BRANCH >/dev/null 2>&1; then
  git checkout $RELEASES_BRANCH
  git pull origin $RELEASES_BRANCH || true
else
  git checkout --orphan $RELEASES_BRANCH
  git rm -rf . 2>/dev/null || true
  git commit --allow-empty -m "Initialize $RELEASES_BRANCH branch"
fi

# Clean old artifacts (keep plugin folders for version history)
rm -f manifest.json README.md

# Fetch source branch and copy plugins
echo "📥 Fetching plugins from $SOURCE_BRANCH..."
git fetch origin $SOURCE_BRANCH
git checkout origin/$SOURCE_BRANCH -- plugins

# Create releases directory structure
mkdir -p releases

# Build plugin ZIPs
echo "🗜️  Building plugin ZIPs..."
for plugin_dir in plugins/*/; do
  plugin_name=$(basename "$plugin_dir")
  version=$(jq -r '.version' "$plugin_dir/plugin.json")
  
  echo "  - $plugin_name v$version"
  
  # Create plugin subfolder in releases
  mkdir -p "releases/$plugin_name"
  
  # Create versioned ZIP
  zip -r "releases/$plugin_name/${plugin_name}-${version}.zip" "$plugin_dir" -q
  
  # Create/update latest ZIP
  cp "releases/$plugin_name/${plugin_name}-${version}.zip" \
     "releases/$plugin_name/${plugin_name}-latest.zip"
done

# Clean up old versioned ZIPs (keep only most recent N)
echo "🧹 Cleaning up old versions..."
for plugin_dir in plugins/*/; do
  plugin_name=$(basename "$plugin_dir")
  zip_dir="releases/$plugin_name"
  
  # List all versioned zips (excluding latest), keep newest N
  ls -1t "$zip_dir"/${plugin_name}-*.zip 2>/dev/null \
    | grep -v "${plugin_name}-latest.zip" \
    | awk "NR>$MAX_VERSIONED_ZIPS" \
    | xargs -r rm -f
done

# Generate manifest.json
echo "📋 Generating manifest.json..."
{
  echo '{'
  echo '  "plugins": ['
  
  first=true
  for plugin_dir in plugins/*/; do
    plugin_file="$plugin_dir/plugin.json"
    if [[ -f "$plugin_file" ]]; then
      plugin_name=$(basename "$plugin_dir")
      
      # Get last update date from git history
      last_updated=$(git log -1 --format=%cI origin/$SOURCE_BRANCH -- "$plugin_dir" 2>/dev/null || date -u +"%Y-%m-%dT%H:%M:%SZ")
      
      # Build URLs for latest and versioned zips
      latest_url="https://github.com/${GITHUB_REPOSITORY}/raw/$RELEASES_BRANCH/releases/${plugin_name}/${plugin_name}-latest.zip"
      
      # Get list of versioned zip URLs
      versioned_zips="[]"
      for zipfile in $(ls -1t "releases/$plugin_name/${plugin_name}"-*.zip 2>/dev/null | grep -v latest); do
        zip_basename=$(basename "$zipfile")
        zip_url="https://github.com/${GITHUB_REPOSITORY}/raw/$RELEASES_BRANCH/releases/${plugin_name}/${zip_basename}"
        versioned_zips=$(jq --arg url "$zip_url" '. + [$url]' <<< "$versioned_zips")
      done
      
      # Merge plugin.json with URLs
      plugin_entry=$(jq \
        --arg last_updated "$last_updated" \
        --arg latest_url "$latest_url" \
        --argjson versioned_zips "$versioned_zips" \
        '. + {last_updated: $last_updated, latest_url: $latest_url, versioned_zips: $versioned_zips}' \
        "$plugin_file")
      
      # Add comma if not first entry
      if [[ "$first" != true ]]; then
        echo ","
      fi
      first=false
      
      echo "    $plugin_entry"
    fi
  done
  
  echo ""
  echo '  ]'
  echo '}'
} | jq '.' > manifest.json

# Generate README.md
echo "📄 Generating README.md..."
{
  echo "# Plugin List"
  echo ""
  echo "| Name | Version | Owner | Maintainers | Last Updated | Download |"
  echo "|------|---------|-------|-------------|--------------|----------|"
  
  for plugin_dir in plugins/*/; do
    plugin_file="$plugin_dir/plugin.json"
    if [[ -f "$plugin_file" ]]; then
      plugin_name=$(basename "$plugin_dir")
      name=$(jq -r '.name' "$plugin_file")
      version=$(jq -r '.version' "$plugin_file")
      owner=$(jq -r '.owner' "$plugin_file")
      maintainers=$(jq -r '[.maintainers[]?] | join(", ")' "$plugin_file")
      last_updated=$(git log -1 --format=%cI origin/$SOURCE_BRANCH -- "$plugin_dir" 2>/dev/null || date -u +"%Y-%m-%dT%H:%M:%SZ")
      zip_url="https://github.com/${GITHUB_REPOSITORY}/raw/$RELEASES_BRANCH/releases/${plugin_name}/${plugin_name}-latest.zip"
      
      echo "| $name | $version | $owner | $maintainers | $last_updated | [ZIP]($zip_url) |"
    fi
  done
} > README.md

# Clean up source plugins directory
echo "🧹 Removing source plugins from releases branch..."
rm -rf plugins
git rm -rf --cached plugins 2>/dev/null || true

# Commit and push changes
echo "💾 Committing changes..."
git add releases manifest.json README.md

if git diff --cached --quiet; then
  echo "✅ No changes to commit"
else
  git commit -m "Publish plugin updates from $SOURCE_BRANCH [skip ci]"
  echo "⬆️  Pushing to $RELEASES_BRANCH..."
  git push "https://x-access-token:${GITHUB_TOKEN}@github.com/${GITHUB_REPOSITORY}.git" $RELEASES_BRANCH
  echo "✅ Successfully published to $RELEASES_BRANCH"
fi
