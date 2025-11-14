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
| [`sample`](#sample) | `1.3.2` | sethwv | A new short description |

---

### [cool-new-plugin](https://github.com/sethwv/sample-plugin-repo/blob/main/plugins/cool-new-plugin/README.md)

**Version:** `0.0.2` | **Owner:** sethwv | **Last Updated:** 2025-11-14T08:21:08-05:00

A cool description

**📥 Downloads:**
- [Latest Release (`0.0.2`)](`releases/cool-new-plugin/cool-new-plugin-latest.zip`](https://github.com/sethwv/sample-plugin-repo/raw/releases/releases/cool-new-plugin/cool-new-plugin-latest.zip))
- [All Versions (1 available)](./releases/cool-new-plugin)


**👥 Maintainers:** sethwv-alt | **📂 Source:** [Browse](https://github.com/sethwv/sample-plugin-repo/tree/main/plugins/cool-new-plugin) | **📝 Last Change:** [`866706a`](https://github.com/sethwv/sample-plugin-repo/commit/866706a56c93eb9765855b515c992b405ef77c56)

---

### [sample](https://github.com/sethwv/sample-plugin-repo/blob/main/plugins/sample/README.md)

**Version:** `1.3.2` | **Owner:** sethwv | **Last Updated:** 2025-11-14T09:39:09-05:00

A new short description

**📥 Downloads:**
- [Latest Release (`1.3.2`)](`releases/sample/sample-latest.zip`](https://github.com/sethwv/sample-plugin-repo/raw/releases/releases/sample/sample-latest.zip))
- [All Versions (2 available)](./releases/sample)


**📂 Source:** [Browse](https://github.com/sethwv/sample-plugin-repo/tree/main/plugins/sample) | **📝 Last Change:** [`2cc8927`](https://github.com/sethwv/sample-plugin-repo/commit/2cc8927f09d6a1bdf6cdd024c174cd8080f3c2d8)

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

*Last updated: 2025-11-14 14:41:30 UTC*
