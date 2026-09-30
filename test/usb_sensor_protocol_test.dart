import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:soil_pht_x_ai/core/utils/crc16.dart';
import 'package:soil_pht_x_ai/core/models/ph_sensor_reading.dart';
import 'package:soil_pht_x_ai/core/constants/sensor_constants.dart';

void main() {
  group('RS485 Modbus RTU USB Soil Sensor Protocol Tests', () {
    test('CRC-16 calculation for Modbus Command [01 03 00 00 00 04] is 0x44 0x09', () {
      final cmdWithoutCrc = Uint8List.fromList([0x01, 0x03, 0x00, 0x00, 0x00, 0x04]);
      final crc = Crc16.compute(cmdWithoutCrc, cmdWithoutCrc.length);
      expect(crc, 0x0944); // Little endian: 0x44 0x09

      final completeFrame = SensorConstants.readHoldingRegistersCommand;
      expect(Crc16.checkCrc(completeFrame), isTrue);
    });

    test('Parses 4-register Modbus response frame correctly (Moisture, Temp, EC, pH)', () {
      // Modbus Response payload:
      // [0x01] Slave ID
      // [0x03] Function
      // [0x08] 8 bytes data
      // Moisture: 524 -> 52.4 %
      // Temp: 285 -> 28.5 °C
      // EC: 450 -> 450 µS/cm
      // pH: 650 -> 6.50
      final rawData = [
        0x01, 0x03, 0x08,
        0x02, 0x0C, // 524 = 52.4%
        0x01, 0x1D, // 285 = 28.5°C
        0x01, 0xC2, // 450 µS/cm
        0x02, 0x8A, // 650 = 6.50 pH
      ];
      final frameWithCrc = Crc16.appendCrc(rawData);
      expect(Crc16.checkCrc(frameWithCrc), isTrue);

      final reading = SoilPhReading.fromModbusBytes(frameWithCrc);
      expect(reading.moisture, 52.4);
      expect(reading.temperature, 28.5);
      expect(reading.conductivity, 450);
      expect(reading.phRaw, 6.50);
      // Nernst slope at 28.5°C = 0.198414 * (273.15 + 28.5) = 59.85 mV/pH
      // Potential at pH 6.50 = -59.85 * (6.50 - 7.00) = +29.9 mV
      expect(reading.sensorVoltageMv, closeTo(29.9, 0.5));
    });

    test('Parses signed negative temperature Modbus bytes correctly', () {
      // Negative temp -5.0°C -> -50 in 16-bit signed = 0xFFCE
      final rawData = [
        0x01, 0x03, 0x08,
        0x01, 0x90, // 40.0%
        0xFF, 0xCE, // -50 = -5.0°C
        0x00, 0xC8, // 200 µS/cm
        0x00, 0x3C, // 60 -> 6.00 pH
      ];
      final frameWithCrc = Crc16.appendCrc(rawData);
      final reading = SoilPhReading.fromModbusBytes(frameWithCrc);
      expect(reading.temperature, -5.0);
      expect(reading.phRaw, 6.0);
    });
  });
}
