# EDGE101 EFuse Reader

Temporary Arduino utility for the **DFRobot Edge101 IoT Controller** (ESP32). It reads the chip eFuse MAC, derives a stable **12-character uppercase hex UNIT_ID**, and prints it over USB serial so you can record it before flashing other firmware.

## What it prints

At **115200** baud, the sketch repeats a banner about every **3 seconds** with:

| Field | Meaning |
|--------|---------|
| **EFUSE RAW** | Full value from `ESP.getEfuseMac()` |
| **MAC48** | Low 48 bits (`mac & 0x0000FFFFFFFFFFFF`) |
| **MAC** | Colon-separated hex from MAC48 |
| **UNIT_ID** | `%012llX` of MAC48 — **12 uppercase hex characters** (this is the value to record) |

The MAC string shown by `esptool` / `espefuse` may not match **UNIT_ID** formatting. **Use the UNIT_ID line from this utility**, not factory-tool text alone.

Record **UNIT_ID** for whatever downstream device naming or provisioning workflow you use (inventory labels, cloud thing names, config files, and so on). This repository does not implement that workflow.

## Requirements

- **No network**, cloud account, certificates, or credentials are required.
- USB serial only; the firmware does not use Wi‑Fi or connect anywhere.

## Target hardware

- Board: DFRobot Edge101 IoT Controller
- FQBN: `DFRobot_Edge101:esp32:esp32`

## Warning

**This firmware overwrites the currently installed firmware.** Use it on new boards, spare units, or whenever replacing the running image is intentional.

## Quick start (Windows)

1. Plug in the Edge101 via USB.
2. Find the COM port:

   ```powershell
   arduino-cli board list
   ```

3. Build and flash (replace `COM9` with your port):

   ```powershell
   powershell -ExecutionPolicy Bypass -File .\tools\build\build.ps1 -clean -compile -upload -port COM9
   ```

4. Open the serial monitor:

   ```powershell
   arduino-cli monitor -p COM9 -c baudrate=115200
   ```

5. Copy **UNIT_ID** from the banner.

Compile only:

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\build\build.ps1 -clean -compile
```

Equivalent from the sketch folder (Arduino CLI directly):

```powershell
arduino-cli compile --fqbn DFRobot_Edge101:esp32:esp32 firmware/edge101_efuse_reader
arduino-cli upload -p COM9 --fqbn DFRobot_Edge101:esp32:esp32 firmware/edge101_efuse_reader
```

More detail: [docs/GETTING_STARTED.md](docs/GETTING_STARTED.md). Build scripts: [tools/build/README.md](tools/build/README.md).

## Repository layout

```
firmware/edge101_efuse_reader/   — minimal Arduino sketch
tools/build/                     — Windows build/upload helpers
docs/                            — getting started
```

## Disclaimer

This project is an independent utility maintained for convenience. **It is not affiliated with, endorsed by, or sponsored by DFRobot.** “Edge101” and related names are trademarks of their respective owners.

## License

MIT — see [LICENSE](LICENSE).
