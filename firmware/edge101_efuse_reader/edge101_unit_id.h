#pragma once

// UNIT_ID from ESP32 eFuse MAC:
//   mac     = ESP.getEfuseMac()
//   mac48   = mac & 0x0000FFFFFFFFFFFFULL
//   unit_id = snprintf(..., "%012llX", mac48)  // 12 uppercase hex digits

#include <Arduino.h>
#include <stdint.h>
#include <stdio.h>

static inline void edge101_read_efuse_mac48(uint64_t* out_raw, uint64_t* out_mac48) {
  const uint64_t mac = ESP.getEfuseMac();
  if (out_raw != nullptr) {
    *out_raw = mac;
  }
  if (out_mac48 != nullptr) {
    *out_mac48 = (mac & 0x0000FFFFFFFFFFFFULL);
  }
}

static inline void edge101_format_unit_id(char* unit_id, size_t unit_id_len) {
  if (unit_id == nullptr || unit_id_len < 13) {
    return;
  }
  uint64_t mac48 = 0;
  edge101_read_efuse_mac48(nullptr, &mac48);
  snprintf(unit_id, unit_id_len, "%012llX", static_cast<unsigned long long>(mac48));
}

// Factory-style MAC from the same mac48 used for UNIT_ID (MSB-first octets).
static inline void edge101_format_mac48_string(uint64_t mac48, char* mac_str, size_t mac_str_len) {
  if (mac_str == nullptr || mac_str_len < 18) {
    return;
  }
  snprintf(mac_str, mac_str_len, "%02X:%02X:%02X:%02X:%02X:%02X",
           static_cast<unsigned>((mac48 >> 40) & 0xFFu), static_cast<unsigned>((mac48 >> 32) & 0xFFu),
           static_cast<unsigned>((mac48 >> 24) & 0xFFu), static_cast<unsigned>((mac48 >> 16) & 0xFFu),
           static_cast<unsigned>((mac48 >> 8) & 0xFFu), static_cast<unsigned>(mac48 & 0xFFu));
}
