# Plugins Repo

This repository hosts publicly available plugins.

- All plugins are in `plugins/`
- Download plugin ZIPs and manifest from the [releases branch](https://github.com/${GITHUB_REPOSITORY}/tree/releases)
- See [PLUGINS.md](https://github.com/${GITHUB_REPOSITORY}/blob/maintainers/PLUGINS.md) for the current plugin list and maintainers

## Pull Request Requirements

- Each PR should add or update a plugin in its own subfolder under `plugins/`.
- Each plugin must include a `plugin.json` with valid metadata.
- Only the plugin's own files should be changed unless updating shared documentation.
- Ensure your plugin passes any automated checks and follows the contribution guidelines.

## Publishing & Releases

- Plugin ZIPs and the manifest are published automatically to the [releases branch](https://github.com/${GITHUB_REPOSITORY}/tree/releases) after PRs are merged to `main`.
- Only the 10 most recent versioned ZIPs per plugin are retained.
- The manifest includes metadata and download links for all plugins.

## Contributing

To contribute a plugin:

1. Fork the repo and create a branch.
2. Add your plugin to `plugins/<plugin-name>/` with:
	- `plugin.json` (metadata)
	- `README.md`
	- Source files
3. Submit a PR to `main`.
4. Only the plugin owner or listed maintainers can modify a plugin.
5. Make sure to bump the version in `plugin.json` for any updates.