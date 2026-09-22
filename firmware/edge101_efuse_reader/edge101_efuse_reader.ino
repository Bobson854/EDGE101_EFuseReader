#include "edge101_unit_id.h"

static const uint32_t kPrintIntervalMs = 3000;

static void printIdentityBanner() {
  uint64_t raw = 0;
  uint64_t mac48 = 0;
  char unit_id[13] = {0};
  char mac_str[18] = {0};

  edge101_read_efuse_mac48(&raw, &mac48);
  edge101_format_unit_id(unit_id, sizeof(unit_id));
  edge101_format_mac48_string(mac48, mac_str, sizeof(mac_str));

  Serial.println();
  Serial.println("========================================");
  Serial.println("EDGE101 EFUSE / UNIT ID READER");
  Serial.println("========================================");
  Serial.printf("EFUSE RAW : 0x%016llX\n", static_cast<unsigned long long>(raw));
  Serial.printf("MAC48     : 0x%012llX\n", static_cast<unsigned long long>(mac48));
  Serial.printf("MAC       : %s\n", mac_str);
  Serial.printf("UNIT_ID   : %s\n", unit_id);
  Serial.println("========================================");
  Serial.println("Record UNIT_ID for your device inventory /");
  Serial.println("provisioning workflow. No network in this sketch.");
  Serial.println("UNIT_ID is the authoritative value.");
  Serial.println("========================================");
  Serial.println();
}

void setup() {
  Serial.begin(115200);
  delay(500);
  printIdentityBanner();
}

void loop() {
  delay(kPrintIntervalMs);
  printIdentityBanner();
}
