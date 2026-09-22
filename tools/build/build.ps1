param(
  [switch]$clean,
  [switch]$compile,
  [switch]$upload,
  [string]$port = "",
  [string]$fqbn = "DFRobot_Edge101:esp32:esp32",
  [switch]$verbose
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Step([string]$message) {
  Write-Host ""
  Write-Host "========== $message ==========" -ForegroundColor Cyan
}

function Info([string]$message) {
  Write-Host "[info] $message" -ForegroundColor Gray
}

function Ok([string]$message) {
  Write-Host "[ok] $message" -ForegroundColor Green
}

function Fail([string]$message) {
  Write-Host "[error] $message" -ForegroundColor Red
}

function Resolve-ArduinoCli {
  if ($env:ARDUINO_CLI_PATH -and $env:ARDUINO_CLI_PATH.Trim().Length -gt 0) {
    try {
      return (Resolve-Path $env:ARDUINO_CLI_PATH).Path
    } catch {
      Fail "ARDUINO_CLI_PATH is set but not valid: $env:ARDUINO_CLI_PATH"
      Write-Host "Set ARDUINO_CLI_PATH to a valid arduino-cli executable path, or clear it to use PATH discovery."
      exit 1
    }
  }

  try {
    return (Get-Command "arduino-cli" -ErrorAction Stop).Source
  } catch {
    Fail "Arduino CLI was not found."
    Write-Host "Install Arduino CLI and either:"
    Write-Host " - add it to PATH, or"
    Write-Host " - set ARDUINO_CLI_PATH to the executable path."
    exit 1
  }
}

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = (Resolve-Path (Join-Path $scriptDir "..\..")).Path
$sketchDir = Join-Path $repoRoot "firmware\edge101_efuse_reader"
$sketchPath = Join-Path $sketchDir "edge101_efuse_reader.ino"
$buildDir = Join-Path $repoRoot ".build"

if (-not $clean -and -not $compile -and -not $upload) {
  Fail "No action specified."
  Write-Host "Usage:"
  Write-Host "  powershell -ExecutionPolicy Bypass -File .\tools\build\build.ps1 -clean -compile"
  Write-Host "  powershell -ExecutionPolicy Bypass -File .\tools\build\build.ps1 -clean -compile -upload -port COM9"
  exit 1
}

if (-not (Test-Path $sketchPath)) {
  Fail "Firmware sketch not found: $sketchPath"
  exit 1
}

if ($upload -and (-not $port -or $port.Trim().Length -eq 0)) {
  Fail "-upload requires -port COMx"
  Write-Host "Example: -upload -port COM9"
  exit 1
}

Step "EDGE101 EFuse Reader build"
Info "Repo root: $repoRoot"
Info "Sketch dir: $sketchDir"
Info "Build dir: $buildDir"
Info "FQBN: $fqbn"

if ($clean) {
  Step "Clean"
  foreach ($dirName in @(".build", "build", "out")) {
    $target = Join-Path $repoRoot $dirName
    if (Test-Path $target) {
      Remove-Item -Path $target -Recurse -Force
      Info "Removed $target"
    }
  }
  Ok "Clean complete."
}

$arduinoCli = $null
if ($compile -or $upload) {
  $arduinoCli = Resolve-ArduinoCli
  Info "Arduino CLI: $arduinoCli"
}

if ($compile) {
  Step "Compile"
  New-Item -ItemType Directory -Force -Path $buildDir | Out-Null

  if ($verbose) {
    & $arduinoCli compile --fqbn $fqbn --build-path $buildDir --verbose $sketchDir
  } else {
    & $arduinoCli compile --fqbn $fqbn --build-path $buildDir $sketchDir
  }

  if ($LASTEXITCODE -ne 0) {
    Fail "Compile failed (exit code: $LASTEXITCODE)."
    Write-Host "Verify board core: arduino-cli core list"
    exit $LASTEXITCODE
  }

  Ok "Compile succeeded."
}

if ($upload) {
  if (-not (Test-Path $buildDir)) {
    Fail "Build directory not found: $buildDir"
    Write-Host "Run with -compile first."
    exit 1
  }

  Step "Upload"
  Info "Port: $port"

  if ($verbose) {
    & $arduinoCli upload -p $port --fqbn $fqbn --input-dir $buildDir --verbose $sketchDir
  } else {
    & $arduinoCli upload -p $port --fqbn $fqbn --input-dir $buildDir $sketchDir
  }

  if ($LASTEXITCODE -ne 0) {
    Fail "Upload failed (exit code: $LASTEXITCODE)."
    exit $LASTEXITCODE
  }

  Ok "Upload complete."
  Write-Host ""
  Write-Host "Open serial monitor at 115200 baud and record the UNIT_ID value."
  Write-Host "arduino-cli monitor -p $port -c baudrate=115200"
}
