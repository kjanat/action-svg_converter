# Version Sync Script for SVG Converter Action (PowerShell)
# This script synchronizes the version number across all project files

[CmdletBinding()]
param(
	[switch]$WhatIf
)

# Constants
$Colors = @{
	Green  = [System.ConsoleColor]::Green
	Yellow = [System.ConsoleColor]::Yellow
	Red    = [System.ConsoleColor]::Red
	Blue   = [System.ConsoleColor]::Blue
	Reset  = [System.ConsoleColor]::White
}

$FilePatterns = @{
	'entrypoint.sh' = 'readonly VERSION="[^"]*"'
	'Dockerfile'    = 'ARG VERSION=[^ \r\n]*'
	'README.md'     = 'uses: kjanat/svg-converter-action@v[^\s]*'
	'package.json'  = '"version": "[^\s]*"'
}

$Replacements = @{
	'entrypoint.sh' = { param($Version) "readonly VERSION=`"$Version`"" }
	'Dockerfile'    = { param($Version) "ARG VERSION=$Version" }
	'README.md'     = { param($Version) "uses: kjanat/svg-converter-action@v$Version" }
	'package.json'  = { param($Version) """version"": ""$Version""" }
}

# Functions
function Write-ColorOutput {
	param(
		[string]$Message,
		[System.ConsoleColor]$Color = $Colors.Reset
	)
	$originalColor = [Console]::ForegroundColor
	[Console]::ForegroundColor = $Color
	Write-Host $Message
	[Console]::ForegroundColor = $originalColor
}

function Get-ProjectPaths {
	# Handle different execution contexts
	$scriptPath = $MyInvocation.MyCommand.Path
	if (-not $scriptPath) {
		$scriptPath = $PSCommandPath
	}
	if (-not $scriptPath) {
		$scriptPath = (Get-Location).Path
	}
    
	$scriptDir = Split-Path -Parent $scriptPath
	$projectRoot = Split-Path -Parent $scriptDir
    
	return @{
		Root    = $projectRoot
		VERSION = Join-Path $projectRoot 'VERSION'
		Files   = @{
			'entrypoint.sh' = Join-Path $projectRoot 'entrypoint.sh'
			'Dockerfile'    = Join-Path $projectRoot 'Dockerfile'
			'README.md'     = Join-Path $projectRoot 'README.md'
			'package.json'  = Join-Path $projectRoot 'package.json'
		}
	}
}

function Get-VersionFromFile {
	param([string]$VersionFilePath)
    
	if (-not (Test-Path $VersionFilePath)) {
		throw "VERSION file not found at: $VersionFilePath"
	}
    
	$version = (Get-Content $VersionFilePath -Raw -ErrorAction Stop).Trim()
    
	if ([string]::IsNullOrWhiteSpace($version)) {
		throw 'VERSION file is empty'
	}
    
	return $version
}

function Update-FileVersion {
	param(
		[string]$FilePath,
		[string]$FileName,
		[string]$Version,
		[string]$Pattern,
		[scriptblock]$ReplacementGenerator,
		[switch]$WhatIf
	)
    
	if (-not (Test-Path $FilePath)) {
		Write-ColorOutput "❌ $FileName not found" $Colors.Red
		return $false
	}
    
	try {
		$content = Get-Content $FilePath -Raw -ErrorAction Stop
        
		if ($content -match $Pattern) {
			$replacement = & $ReplacementGenerator $Version
			$newContent = $content -replace $Pattern, $replacement
            
			if ($WhatIf) {
				Write-ColorOutput "Would update $FileName" $Colors.Yellow
			} else {
				Set-Content -Path $FilePath -Value $newContent -NoNewline -ErrorAction Stop
				Write-ColorOutput "✅ Updated $FileName" $Colors.Green
			}
			return $true
		} else {
			Write-ColorOutput "⚠️  No version pattern found in $FileName" $Colors.Yellow
			return $false
		}
	} catch {
		Write-ColorOutput "❌ Error processing $FileName : $($_.Exception.Message)" $Colors.Red
		return $false
	}
}

# Main execution
try {
	$paths = Get-ProjectPaths
	$version = Get-VersionFromFile $paths.VERSION
    
	Write-ColorOutput "🔄 Syncing version: $version" $Colors.Green
    
	$updatedFiles = @()
    
	foreach ($fileName in $FilePatterns.Keys) {
		$filePath = $paths.Files[$fileName]
		$pattern = $FilePatterns[$fileName]
		$replacement = $Replacements[$fileName]
        
		$updated = Update-FileVersion -FilePath $filePath -FileName $fileName -Version $version -Pattern $pattern -ReplacementGenerator $replacement -WhatIf:$WhatIf
        
		if ($updated -and -not $WhatIf) {
			$updatedFiles += $fileName
		}
	}
    
	# Summary
	if ($WhatIf) {
		Write-ColorOutput '🔍 Dry run completed. Use without -WhatIf to apply changes.' $Colors.Blue
	} else {
		Write-ColorOutput '🎉 Version sync completed successfully!' $Colors.Green
		Write-ColorOutput '📋 Summary:' $Colors.Green
		Write-ColorOutput "   Version: $version" $Colors.Yellow
        
		if ($updatedFiles.Count -gt 0) {
			Write-ColorOutput "   Files updated: $($updatedFiles -join ', ')" $Colors.Green
		} else {
			Write-ColorOutput '   No files were updated' $Colors.Yellow
		}
	}
} catch {
	Write-ColorOutput "❌ Script failed: $($_.Exception.Message)" $Colors.Red
	exit 1
}
