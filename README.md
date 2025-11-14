# Plugin Releases

This branch contains all published plugin releases with automated builds and metadata.

## 📥 Quick Access

- **Manifest**: [`manifest.json`](./manifest.json) - Complete plugin registry with metadata
- **Releases**: [`releases/`](./releases/) - All plugin ZIP files
- **Metadata**: [`metadata/`](./metadata/) - Version metadata with checksums

## 📦 Available Plugins

| Plugin | Version | Owner | Description |
|--------|---------|-------|-------------|
| [`cool-new-plugin`](#cool-new-plugin) | `0.0.2` | sethwv | A cool description |
| [`sample`](#sample) ⚠️ | `1.3.1` | sethwv | ~~A short description~~ |

---

### [cool-new-plugin](https://github.com/sethwv/sample-plugin-repo/blob/main/plugins/cool-new-plugin/README.md)

**Version:** `0.0.2` | **Owner:** sethwv | **Last Updated:** 2025-11-14T08:21:08-05:00

A cool description

**📥 Downloads:**
- [Latest Release (`0.0.2`)](`releases/cool-new-plugin/cool-new-plugin-latest.zip`](https://github.com/sethwv/sample-plugin-repo/raw/releases/releases/cool-new-plugin/cool-new-plugin-latest.zip))
- [All Versions (1 available)](./releases/cool-new-plugin)


**👥 Maintainers:** sethwv-alt | **📂 Source:** [Browse](https://github.com/sethwv/sample-plugin-repo/tree/main/plugins/cool-new-plugin) | **📝 Last Change:** [`866706a`](https://github.com/sethwv/sample-plugin-repo/commit/866706a56c93eb9765855b515c992b405ef77c56)

---


## ⚠️ Deprecated Plugins

These plugins are deprecated and may be removed in the future without notice. They may not work in current or future versions of the application. Use at your own risk.

### ⚠️ [sample](https://github.com/sethwv/sample-plugin-repo/blob/main/plugins/sample/README.md)

**Version:** `1.3.1` | **Owner:** sethwv | **Last Updated:** 2025-11-14T09:35:23-05:00

A short description

**📥 Downloads:**
- [Latest Release (`1.3.1`)](`releases/sample/sample-latest.zip`](https://github.com/sethwv/sample-plugin-repo/raw/releases/releases/sample/sample-latest.zip))
- [All Versions (1 available)](./releases/sample)


**📂 Source:** [Browse](https://github.com/sethwv/sample-plugin-repo/tree/main/plugins/sample) | **📝 Last Change:** [`86d6ebb`](https://github.com/sethwv/sample-plugin-repo/commit/86d6ebbb5b98cada5981b56fa70b7dec101a4a61)

---

## 🔍 Using the Manifest

Programmatically access plugin information:

```bash
curl https://raw.githubusercontent.com/sethwv/sample-plugin-repo/releases/manifest.json
```

The manifest includes:
- Plugin metadata (name, version, owner, description)
- Download URLs for all versions
- Checksums (MD5, SHA256) for integrity verification
- Git commit information for traceability
- Build timestamps

---

*Last updated: 2025-11-14 14:38:23 UTC*
