# Changelog

All notable changes to SVG Converter will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Full font support for Inkscape rendering (including Microsoft TrueType core fonts)
- Pango and HarfBuzz text rendering libraries
- Font configuration for high-quality text rendering
- Environment variables for consistent font handling
- Configuration for pnpm package manager with Docker and CI/CD improvements
  - `.dockerignore` and `.prettierignore` files for better build and formatting exclusions
  - `package.json` and `pnpm-lock.yaml` for consistent dependency management
- README workflow badge for CI/CD visibility

### Changed

- Updated Dockerfile to use pnpm for dependency management and enhanced font setup
- Adjusted Dependabot update schedules to weekly with pnpm support

### Fixed

- Missing text in output images due to missing font dependencies
- Font rendering issues in SVG to PNG/ICO conversion
- Pango font mapping errors in Docker container

## [1.0.6] - 2025-06-15

### Added

- Version sync scripts (Bash and PowerShell) to synchronize version numbers across all project files
- Scripts directory with comprehensive documentation
- Inkscape support for highest quality SVG to PNG conversion
- Enhanced ICO generation using high-resolution intermediate PNG for better quality

### Changed

- Changed the repository name from "action-svg_converter" to "svg-converter-action"
- Updated README to reflect new repository name and usage instructions
- Updated all README.md usage examples to use correct repository reference (`kjanat/svg-converter-action@v1.0.6`)
- Fixed action path references from local `./.github/actions/svg-converter` to proper marketplace format
- Prioritized Inkscape over other SVG converters for superior rendering quality
- ICO conversion now uses highest available resolution as intermediate PNG for better quality
- Enhanced conversion logging with converter type and file size information

### Fixed

- Docker LABEL version command substitution (replaced invalid `$(cat /tmp/VERSION)` with proper ARG/LABEL pattern)
- Version mismatches across project files (now all synced to v1.0.6)
- GitHub Actions workflow artifact uploads (each demo job now properly uploads its generated files)
- TypeScript component demo output and file detection logic
- Missing artifacts issue where generated files weren't being uploaded to GitHub
- ICO file quality by using two-step conversion process (SVG → PNG → ICO)

### Removed

- Obsolete SETUP_INSTRUCTIONS.md file (no longer needed for standalone action repository)

## [1.0.5] - 2025-06-14

### Added

- MAX_FILES limit (100 files) to prevent resource exhaustion
- File count validation that calculates total files across all formats
- VERSION file to store version number
- CHANGELOG.md for tracking changes
- Docker LABEL for versioning
- Enhanced debug output for better troubleshooting
- Enhanced debug output to show file breakdown by format
- Improved error messages for file limit violations with helpful suggestions

### Changed

- Renamed project to "SVG Converter" from "SVG Converter Pro"

### Fixed

- Docker LABEL version command substitution (replaced invalid `$(cat /tmp/VERSION)` with proper ARG/LABEL pattern)

## [1.0.4] - 2025-06-14

### Added

- Dedicated setup job to centralize environment variable handling
- Robust fallback mechanism that works for all trigger scenarios

### Changed

- Completely restructured workflow to properly handle push vs workflow_dispatch triggers
- All demo jobs now use `needs.setup.outputs` for reliable input handling

### Fixed

- Persistent empty SVG_PATH issue by using job outputs instead of direct input references

## [1.0.3] - 2025-06-14

### Changed

- Updated workflow to use `inputs.svg_file` instead of `github.event.inputs.svg_file`

### Fixed

- Workflow input handling for different trigger types (push vs workflow_dispatch)
- Empty SVG_PATH issue when workflow triggered by push events
- Input parameter reliability across all workflow trigger scenarios

## [1.0.2] - 2025-06-14

### Added

- Missing DEBUG input variable handling and validation

### Changed

- Updated `get_input` function to properly convert hyphens to underscores (GitHub Actions convention)

### Fixed

- Environment variable handling for GitHub Actions inputs with hyphens
- "Invalid variable name" bash errors for hyphenated input names

## [1.0.1] - 2025-06-14

### Changed

- Corrected action usage from `./.github/actions/svg-converter` to `./`

### Fixed

- GitHub Actions workflow path references
- "Can't find action.yml" errors in workflow execution
- Workflow reliability and execution success rate

## [1.0.0] - 2025-06-14

### Added

- Initial release with basic SVG conversion capabilities
- Parallel processing for PNG generation
- Security with input validation and path protection
- Comprehensive error handling and recovery
- Performance optimizations and resource management
- Debug mode for troubleshooting
- Improved logging and progress indicators
- Automatic cleanup of temporary files
- Enhanced documentation and examples

[unreleased]: https://github.com/kjanat/svg-converter-action/compare/v1.0.6...HEAD
[1.0.6]: https://github.com/kjanat/svg-converter-action/compare/v1.0.5...v1.0.6
[1.0.5]: https://github.com/kjanat/svg-converter-action/compare/v1.0.4...v1.0.5
[1.0.4]: https://github.com/kjanat/svg-converter-action/compare/v1.0.3...v1.0.4
[1.0.3]: https://github.com/kjanat/svg-converter-action/compare/v1.0.2...v1.0.3
[1.0.2]: https://github.com/kjanat/svg-converter-action/compare/v1.0.1...v1.0.2
[1.0.1]: https://github.com/kjanat/svg-converter-action/compare/v1.0.0...v1.0.1
[1.0.0]: https://github.com/kjanat/svg-converter-action/releases/tag/v1.0.0

<!-- markdownlint-configure-file { "MD024": false } -->
