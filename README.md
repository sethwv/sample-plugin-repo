# Plugin Repository

A centralized repository for publishing and distributing plugins with automated validation, versioning, and release management.

## 📦 How It Works

### Repository Structure

```
plugins/
├── plugin-name-1/
│   ├── plugin.json      # Plugin metadata and configuration
│   ├── README.md        # Plugin documentation
│   └── main.js          # Plugin source code
└── plugin-name-2/
    ├── plugin.json
    ├── README.md
    └── ...
```

### Automated Workflow

#### 1. **Pull Request Validation** (`validate-plugin.yml`)

When you submit a PR to update or add a plugin:

- **Ownership Verification**: Ensures only the plugin owner, listed maintainers, or repository maintainers can modify plugins
- **Structure Validation**: Checks for required files (`plugin.json`, `README.md`)
- **JSON Validation**: Verifies `plugin.json` is valid and contains required fields (`name`, `version`, `owner`, `maintainers`, `description`)
- **Version Enforcement**: For existing plugins, ensures the version is semantically incremented (e.g., `1.0.0` → `1.0.1`)
- **Multi-Plugin Support**: Validates permissions for each plugin when multiple plugins are modified in one PR
- **Draft PR Protection**: Validation only runs when PRs are marked "ready for review"

The workflow posts a detailed validation report as a comment on your PR, showing which checks passed or failed.

#### 2. **Automated Publishing** (`publish-plugins.yml`)

Once your PR is merged to `main`:

- **Automatic ZIP Creation**: Each plugin is packaged into versioned and latest ZIPs
  - `plugin-name-1.0.0.zip` (versioned)
  - `plugin-name-latest.zip` (always points to the newest version)
- **Retention Policy**: Only the 10 most recent versioned ZIPs are kept per plugin
- **Manifest Generation**: A `manifest.json` file is generated with metadata and download URLs for all plugins
- **Release Branch**: All artifacts are published to the [`releases` branch](https://github.com/sethwv/sample-plugin-repo/tree/releases)
- **Plugin List**: An auto-generated README on the releases branch lists all available plugins with download links

## 🚀 Contributing a Plugin

### Adding a New Plugin

1. **Fork the repository** and create a new branch
2. **Create your plugin folder** under `plugins/your-plugin-name/`
3. **Add required files**:
   - `plugin.json` - Plugin metadata
   - `README.md` - Plugin documentation
   - Source files (e.g., `main.js`)
4. **Submit a pull request** to `main`

### Updating an Existing Plugin

1. **Fork the repository** and create a new branch
2. **Modify files** in `plugins/your-plugin-name/`
3. **Increment the version** in `plugin.json` (e.g., `1.0.0` → `1.0.1`)
4. **Submit a pull request** to `main`

### `plugin.json` Format

```json
{
  "name": "my-awesome-plugin",
  "version": "1.0.0",
  "owner": "github-username",
  "maintainers": ["contributor1", "contributor2"],
  "description": "A brief description of what the plugin does"
}
```

**Required fields:**
- `name`: Unique plugin identifier (matches folder name)
- `version`: Semantic version (e.g., `1.0.0`)
- `owner`: GitHub username of the plugin owner
- `maintainers`: Array of GitHub usernames who can modify the plugin
- `description`: Brief explanation of plugin functionality

### PR Requirements & Validation

✅ **Your PR must**:
- Be submitted by the plugin owner, a listed maintainer, or a repository maintainer (for each modified plugin)
- Include valid `plugin.json` and `README.md` files for each plugin
- Use semantic versioning (`MAJOR.MINOR.PATCH`)
- Increment the version for updates to existing plugins
- Have proper permissions for all modified plugins

❌ **Your PR will fail if**:
- Required files are missing
- `plugin.json` is invalid or missing required fields
- Version is not incremented (for existing plugins)
- Submitter lacks permission for any modified plugin

**Note:** You can modify multiple plugins in a single PR as long as you have proper permissions for all of them.

## 📥 Downloading Plugins

### For End Users

Visit the [**releases branch**](https://github.com/sethwv/sample-plugin-repo/tree/releases) to:
- Browse available plugins in the auto-generated README
- Download the latest version: `releases/plugin-name/plugin-name-latest.zip`
- Download specific versions: `releases/plugin-name/plugin-name-1.0.0.zip`

### For Applications

Use the `manifest.json` on the releases branch to programmatically access plugin metadata and download URLs:

```bash
curl https://raw.githubusercontent.com/sethwv/sample-plugin-repo/releases/manifest.json
```

## 🔒 Ownership & Permissions

- **Plugin Owner**: The GitHub user specified in `plugin.json` `owner` field
- **Maintainers**: Additional GitHub users listed in `plugin.json` `maintainers` array
- **Repository Maintainers**: Users with write/admin access to this repository

Only these users can submit PRs that modify a given plugin.

## 🏷️ Versioning

This repository uses **semantic versioning** for plugins:

- `MAJOR.MINOR.PATCH` (e.g., `1.0.0`)
- **PATCH**: Bug fixes and minor changes (`1.0.0` → `1.0.1`)
- **MINOR**: New features, backward compatible (`1.0.0` → `1.1.0`)
- **MAJOR**: Breaking changes (`1.0.0` → `2.0.0`)

Version increments are **enforced** by the validation workflow.