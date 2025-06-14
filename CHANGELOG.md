# Changelog

All notable changes to SVG Converter will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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

[unreleased]: https://github.com/action-svg_converter/compare/v1.0.5...HEAD
[1.0.5]: https://github.com/action-svg_converter/compare/v1.0.4...v1.0.5
[1.0.4]: https://github.com/action-svg_converter/compare/v1.0.3...v1.0.4
[1.0.3]: https://github.com/action-svg_converter/compare/v1.0.2...v1.0.3
[1.0.2]: https://github.com/action-svg_converter/compare/v1.0.1...v1.0.2
[1.0.1]: https://github.com/action-svg_converter/compare/v1.0.0...v1.0.1
[1.0.0]: https://github.com/action-svg_converter/releases/tag/v1.0.0

<!-- markdownlint-configure-file { "MD024": false } -->
