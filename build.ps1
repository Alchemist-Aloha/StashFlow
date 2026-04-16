<#
.SYNOPSIS
  Build StashFlow for available platforms on Windows (PowerShell).

.DESCRIPTION
  Mirrors build.sh logic: dependency checks, `flutter pub get`, code generation,
  and platform builds. The script attempts each platform and continues on
  failures (skips unavailable platforms).
#>

param(
    [switch]$Help
)

if ($Help) {
    Write-Host "Usage: .\build.ps1 [-Help]" -ForegroundColor Yellow
    exit 0
}

function Write-Info($msg) { Write-Host $msg -ForegroundColor Yellow }
function Write-Success($msg) { Write-Host $msg -ForegroundColor Green }
function Write-ErrorMsg($msg) { Write-Host $msg -ForegroundColor Red }

Write-Info "Starting StashFlow Build Process..."

Write-Info "Checking build dependencies..."

function Test-CommandExists([string]$cmd) {
    return (Get-Command $cmd -ErrorAction SilentlyContinue) -ne $null
}

function Check-Dep([string]$name, [string]$cmd) {
    if (Test-CommandExists $cmd) {
        Write-Success "[✓] $name"
        return $true
    } else {
        Write-ErrorMsg "[✗] $name"
        return $false
    }
}

function Check-AndroidSdk {
    $sdkPath = $null
    try {
        $doctor = & flutter doctor -v 2>$null
    } catch {
        $doctor = $null
    }
    if ($doctor) {
        foreach ($line in $doctor) {
            if ($line -match 'Android SDK at (.+)$') {
                $sdkPath = $matches[1].Trim()
                break
            }
        }
    }
    if ($sdkPath) {
        Write-Success "[✓] Android SDK (at $sdkPath)"
        return $true
    } else {
        Write-ErrorMsg "[✗] Android SDK"
        return $false
    }
}

$missingCritical = $false
if (-not (Check-Dep "Flutter" "flutter")) { $missingCritical = $true }
if (-not (Check-Dep "Dart" "dart")) { $missingCritical = $true }
Check-Dep "CMake (Linux/Windows)" "cmake" | Out-Null
Check-Dep "Ninja (Linux/Windows)" "ninja" | Out-Null
Check-AndroidSdk | Out-Null

if ($missingCritical) {
    Write-ErrorMsg "Critical dependencies (Flutter/Dart) are missing! Please install them first."
    exit 1
}

Write-Success "Dependency check finished. Continuing with build..."
Write-Host ""

# 1. Fetch dependencies
Write-Info "Fetching dependencies..."
& flutter pub get
if ($LASTEXITCODE -ne 0) {
    Write-ErrorMsg "flutter pub get failed!"
    exit 1
}

# 2. Run code generation
Write-Info "Running code generation..."
& dart run build_runner build --delete-conflicting-outputs
if ($LASTEXITCODE -ne 0) {
    Write-ErrorMsg "Code generation failed!"
    exit 1
}

function Invoke-CommandString([string]$cmd) {
    Invoke-Expression $cmd
    return $LASTEXITCODE
}

function Build-Platform([string]$platform, [string]$command) {
    Write-Info "Attempting to build for $platform..."
    try {
        $code = Invoke-CommandString $command
        if ($code -eq 0) {
            Write-Success "SUCCESS: $platform build completed."
            return $true
        } else {
            Write-ErrorMsg "SKIPPED/FAILED: $platform build was not successful or is unavailable on this system."
            return $false
        }
    } catch {
        Write-ErrorMsg "SKIPPED/FAILED: $platform build failed with error: $_"
        return $false
    }
}

$platforms = @{
    "Android (APK)" = "flutter build apk --split-per-abi"
    "Web" = "flutter build web"
    "Linux" = "flutter build linux"
    "Windows" = "flutter build windows"
    "macOS" = "flutter build macos"
}

$results = @()

foreach ($platform in @("Android (APK)", "Web", "Linux", "Windows", "macOS")) {
    $cmd = $platforms[$platform]
    if (Build-Platform $platform $cmd) {
        $results += [PSCustomObject]@{ Name = $platform; Success = $true }
    } else {
        $results += [PSCustomObject]@{ Name = $platform; Success = $false }
    }
}

Write-Host ""
Write-Info "=== Build Summary ==="
foreach ($r in $results) {
    if ($r.Success) {
        Write-Success "[✓] $($r.Name)"
    } else {
        Write-ErrorMsg "[✗] $($r.Name)"
    }
}

Write-Info "Build process finished."
exit 0
