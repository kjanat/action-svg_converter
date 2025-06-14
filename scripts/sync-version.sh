#!/bin/bash
# Version Sync Script for SVG Converter Action
# This script synchronizes the version number across all project files

set -euo pipefail

# Constants
declare -A COLORS=(
    [GREEN]='\033[0;32m'
    [YELLOW]='\033[1;33m'
    [RED]='\033[0;31m'
    [BLUE]='\033[0;34m'
    [NC]='\033[0m'
)

# File patterns and replacements
declare -A FILE_PATTERNS=(
    ["entrypoint.sh"]="readonly VERSION=\"[^\"]*\""
    ["Dockerfile"]="ARG VERSION=[^ ]*"
    ["README.md"]="kjanat/svg-converter-action@v[^\s]*"
)

declare -A REPLACEMENTS=(
    ["entrypoint.sh"]="readonly VERSION=\"\$VERSION\""
    ["Dockerfile"]="ARG VERSION=\$VERSION"
    ["README.md"]="kjanat/svg-converter-action@v\$VERSION"
)

# Functions
log_colored() {
    local message color
    message="$1"
    color="${2:-NC}"

    echo -e "${COLORS[$color]}$message${COLORS[NC]}"
}

get_project_paths() {
    local script_dir project_root
    script_dir="$(cd "$(dirname "${BASH_SOURCE[1]}")" && pwd)"
    project_root="$(dirname "$script_dir")"

    echo "$project_root"
}

get_version_from_file() {
    local version_file="$1"

    if [[ ! -f "$version_file" ]]; then
        log_colored "❌ VERSION file not found at: $version_file" "RED" >&2
        return 1
    fi

    local version
    version=$(tr -d '\n\r ' <"$version_file")

    if [[ -z "$version" ]]; then
        log_colored "❌ VERSION file is empty" "RED" >&2
        return 1
    fi

    echo "$version"
}

update_file_version() {
    local file_path file_name version pattern replacement
    file_path="$1"
    file_name="$2"
    version="$3"
    pattern="$4"
    replacement="$5"

    if [[ ! -f "$file_path" ]]; then
        log_colored "❌ $file_name not found" "RED" >&2
        return 1
    fi

    if ! grep -q "$pattern" "$file_path"; then
        log_colored "⚠️  No version pattern found in $file_name" "YELLOW"
        return 1
    fi

    # Create replacement string with actual version
    local actual_replacement
    actual_replacement="${replacement//\$VERSION/$version}"

    # Update file with backup
    if sed -i.bak "s|$pattern|$actual_replacement|g" "$file_path"; then
        rm -f "$file_path.bak"
        log_colored "✅ Updated $file_name" "GREEN"
        return 0
    else
        log_colored "❌ Error updating $file_name" "RED" >&2
        return 1
    fi
}

# Main execution
main() {
    local project_root
    project_root=$(get_project_paths)

    local version_file="$project_root/VERSION"
    local version
    version=$(get_version_from_file "$version_file") || exit 1

    log_colored "🔄 Syncing version: $version" "GREEN"

    local updated_files=()
    local file_name file_path pattern replacement

    for file_name in "${!FILE_PATTERNS[@]}"; do
        file_path="$project_root/$file_name"
        pattern="${FILE_PATTERNS[$file_name]}"
        replacement="${REPLACEMENTS[$file_name]}"

        if update_file_version "$file_path" "$file_name" "$version" "$pattern" "$replacement"; then
            updated_files+=("$file_name")
        fi
    done

    # Summary
    log_colored "🎉 Version sync completed successfully!" "GREEN"
    log_colored "📋 Summary:" "GREEN"
    log_colored "   Version: $version" "YELLOW"

    if [[ ${#updated_files[@]} -gt 0 ]]; then
        local files_list
        files_list=$(
            IFS=', '
            echo "${updated_files[*]}"
        )
        log_colored "   Files updated: $files_list" "GREEN"
    else
        log_colored "   No files were updated" "YELLOW"
    fi
}

# Run main function
main "$@"
