# Getting started — read UNIT_ID from Edge101

This guide covers flashing the reader sketch, opening serial, and recording **UNIT_ID**. Nothing in this repo talks to the network or stores secrets.

## What you are doing

1. Flash this **temporary** reader firmware (overwrites whatever is on the board now).
2. Open serial at **115200** baud.
3. Copy the **UNIT_ID** line (12 uppercase hex characters).
4. Use that string in your own inventory or provisioning process, then flash the firmware you actually want on the device.

## UNIT_ID vs factory MAC tools

Tools such as `esptool` or `espefuse` may show MAC-related text that does **not** match the **UNIT_ID** string this sketch prints.

This utility derives **UNIT_ID** as follows:

- `mac = ESP.getEfuseMac()`
- `mac48 = mac & 0x0000FFFFFFFFFFFF`
- `UNIT_ID = snprintf(..., "%012llX", mac48)` (12 uppercase hex digits)

**Always trust the UNIT_ID line from the serial banner** when you need the same ID this sketch computes.

## 1. Connect hardware

- USB cable to the Edge101.
- On Windows, ensure a COM port appears (USB serial driver if needed).

List ports:

```powershell
arduino-cli board list
```

Note your port (for example `COM9`).

## 2. Prerequisites

- [Arduino CLI](https://arduino.github.io/arduino-cli/) on `PATH`, or set `ARDUINO_CLI_PATH`
- DFRobot Edge101 board package for FQBN `DFRobot_Edge101:esp32:esp32`

## 3. Flash the reader

From the repository root:

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\build\build.ps1 -clean -compile -upload -port COM9
```

Replace `COM9` with your port.

## 4. Serial monitor

```powershell
arduino-cli monitor -p COM9 -c baudrate=115200
```

Baud rate must be **115200**.

The banner repeats about every **3 seconds**, so you can open the monitor after reset and still catch a print.

## 5. Record UNIT_ID

Example banner shape (values will match your chip):

```
========================================
EDGE101 EFUSE / UNIT ID READER
========================================
EFUSE RAW : 0x................
MAC48     : 0x............
MAC       : XX:XX:XX:XX:XX:XX
UNIT_ID   : XXXXXXXXXXXX
========================================
```

Copy **UNIT_ID** exactly. Store it wherever your workflow requires (spreadsheet, asset tag, device registry, etc.).

## 6. After you have the ID

This reader firmware is **disposable**. Flash your target application firmware when ready. You only need this utility again if you want to re-read the ID or intentionally overwrite the board with the reader sketch.

## Troubleshooting

| Issue | Check |
|--------|--------|
| Compile fails on FQBN | Install the DFRobot Edge101 core (`arduino-cli core list`, board manager) |
| Upload fails | Correct COM port, data-capable USB cable, driver |
| Empty serial | **115200** baud, correct COM, press reset after opening monitor |
| Wrong ID assumed | Use banner **UNIT_ID**, not esptool MAC text alone |
