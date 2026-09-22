# Build tools

## Prerequisites

- Windows
- [Arduino CLI](https://arduino.github.io/arduino-cli/) on `PATH` (or set `ARDUINO_CLI_PATH`)
- DFRobot Edge101 board package installed for FQBN `DFRobot_Edge101:esp32:esp32`
- USB connection to the Edge101

## Board detection

```powershell
arduino-cli board list
```

## Typical build and upload

From the repository root:

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\build\build.ps1 -clean -compile -upload -port COM9
```

Or:

```bat
tools\build\build.bat -clean -compile -upload -port COM9
```

## Compile only

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\build\build.ps1 -clean -compile
```

Build output is written to `.build/` at the repo root (gitignored).

## Serial monitor

After upload:

```powershell
arduino-cli monitor -p COM9 -c baudrate=115200
```

Record the **UNIT_ID** line from the banner.
