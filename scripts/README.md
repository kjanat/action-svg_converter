# Scripts

This directory contains utility scripts for maintaining the SVG Converter Action.

## Version Sync Scripts

These scripts synchronize the version number from the `VERSION` file across all project files.

### Bash Script ([sync-version.sh](sync-version.sh))

For Linux/macOS or Windows with Git Bash/WSL:

```bash
# Run from project root
bash scripts/sync-version.sh
```

### PowerShell Script ([sync-version.ps1](sync-version.ps1))

For Windows PowerShell:

```powershell
# Run from project root
powershell -ExecutionPolicy Bypass -File "scripts\sync-version.ps1"

# Dry run to see what would be changed
powershell -ExecutionPolicy Bypass -File "scripts\sync-version.ps1" -WhatIf
```

## Files Updated

Both scripts update the following files:

- `entrypoint.sh` - Updates `readonly VERSION="x.x.x"`
- `Dockerfile` - Updates `ARG VERSION=x.x.x`

## Usage Workflow

1. Update the version in the `VERSION` file
2. Run the appropriate sync script for your platform
3. Commit the changes
4. Create a new release/tag

## Example

```bash
# Update version
echo "1.0.6" > VERSION

# Sync version across files
bash scripts/sync-version.sh

# Commit changes
git add .
git commit -m "🔖 Bump version to 1.0.6"
git tag v1.0.6
git push origin main --tags
```
