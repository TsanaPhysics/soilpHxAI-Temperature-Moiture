class AiErrorCompensationModel {
  // Pre-computed AI Model Coefficients
  // Inverse Non-linear Mapping: pH_predicted = g(E_real, T)
  // Trained via Multi-Layer Error Minimization on Standard Buffers (pH 4.01, 7.00, 10.01 @ 20-50°C)
  static const double cBias = 6.931715;
  static const double cE = -0.03481958;
  static const double cT = 0.00956416;
  static const double cET = -3.47704e-05;
  static const double cE2 = 7.53126e-06;
  static const double cT2 = -1.62641e-05;
  static const double cE2T = -7.34178e-07;
  static const double cE3 = 6.27303e-07;

  /// High-Accuracy AI Forward Inference: g(E_real, T) -> pH_predicted
  /// Resolves asymmetry potential, non-linear curvature, and temperature drift.
  static double predict({
    required double potentialMv,
    required double temperatureC,
  }) {
    final double e = potentialMv;
    final double t = temperatureC;

    final double phPred = cBias +
        (cE * e) +
        (cT * t) +
        (cET * e * t) +
        (cE2 * e * e) +
        (cT2 * t * t) +
        (cE2T * e * e * t) +
        (cE3 * e * e * e);

    return double.parse(phPred.clamp(0.0, 14.0).toStringAsFixed(2));
  }

  /// Generate embeddable C++ code for flashing into ESP32 / Arduino Microcontroller
  /// (Conforming to Research Procedure Step 4.1 "การสร้างต้นแบบ - ฝังโมเดล AI ลงในไมโครคอนโทรลเลอร์")
  static String generateCppArduinoCode() {
    return '''
// ============================================================================
// SoilpHTxAI - Embedded AI Error Compensation Engine for ESP32 / Arduino
// Project: Development of a High-Accuracy Field-Portable Soil pH Meter Prototype
// Funding: Rambhai Barni Rajabhat University Research Fund 2569
// Principal Investigators: Tanapat Tirawoot, Asst.Prof.Dr. Chewa Thassana, Assoc.Prof.Dr. Nuntaporn Moonrungsee, Assoc.Prof.Dr. Nipat Piamarun
// ============================================================================

#include <Arduino.h>
#include <math.h>

// AI Model Inverse Mapping Parameters
static const float C_BIAS = 6.931715f;
static const float C_E    = -0.03481958f;
static const float C_T    = 0.00956416f;
static const float C_ET   = -3.47704e-05f;
static const float C_E2   = 7.53126e-06f;
static const float C_T2   = -1.62641e-05f;
static const float C_E2T  = -7.34178e-07f;
static const float C_E3   = 6.27303e-07f;

// Forward Inference Routine for ESP32
float predictAiCompensatedPh(float potentialMv, float tempC) {
  float e = potentialMv;
  float t = tempC;
  
  float phPred = C_BIAS +
                 (C_E * e) +
                 (C_T * t) +
                 (C_ET * e * t) +
                 (C_E2 * e * e) +
                 (C_T2 * t * t) +
                 (C_E2T * e * e * t) +
                 (C_E3 * e * e * e);

  if (phPred < 0.0f) phPred = 0.0f;
  if (phPred > 14.0f) phPred = 14.0f;
  return phPred;
}

void setup() {
  Serial.begin(115200);
  Serial.println("SoilpHTxAI Firmware Initialized (RBRU 2569)");
}

void loop() {
  // Read analog potential from pH probe (GPIO 34) and Temperature (DS18B20)
  float rawMv = 118.5f; // Replace with analogReadMilliVolts(34)
  float tempC = 28.5f;  // Replace with sensors.getTempCByIndex(0)
  
  float phAI = predictAiCompensatedPh(rawMv, tempC);
  
  // Format JSON payload for mobile app
  Serial.print("{\\"potential_mv\\":");
  Serial.print(rawMv);
  Serial.print(",\\"temperature_c\\":");
  Serial.print(tempC);
  Serial.print(",\\"ai_ph\\":");
  Serial.print(phAI, 2);
  Serial.println("}");
  
  delay(1000);
}
''';
  }
}
