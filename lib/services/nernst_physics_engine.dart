import 'dart:math';
import '../core/constants/app_constants.dart';

class NernstPhysicsEngine {
  /// Calculate the ideal Nernst slope in mV per pH unit at temperature T in Celsius.
  /// S(T) = (2.302585 * R * (T + 273.15) / F) * 1000 mV
  static double calculateNernstSlopeMv(double temperatureC) {
    final double kelvin = temperatureC + AppConstants.kelvinOffset;
    final double slopeVolts = (AppConstants.naturalLog10 *
            AppConstants.gasConstantR *
            kelvin) /
        AppConstants.faradayConstantF;
    return slopeVolts * 1000.0;
  }

  /// Calculate traditional Nernst-compensated pH from potential (mV) and temperature (°C)
  /// Formula: pH = 7.0 - (E_meas - E0) / Slope(T)
  static double calculateNernstPh({
    required double potentialMv,
    required double temperatureC,
    double asymmetryPotentialMv = 0.0,
  }) {
    final double slope = calculateNernstSlopeMv(temperatureC);
    if (slope <= 0) return 7.0;
    final double ph = 7.0 - ((potentialMv - asymmetryPotentialMv) / slope);
    return double.parse(ph.clamp(0.0, 14.0).toStringAsFixed(3));
  }

  /// Simulate realistic electrochemical sensor potential (mV) given true pH, temperature,
  /// and physical non-linearities (as described in Proposal Section 5.1).
  static double simulateRealSensorPotential({
    required double truePh,
    required double temperatureC,
    bool includeNonLinearity = true,
    bool includeNoise = false,
  }) {
    final double slope = calculateNernstSlopeMv(temperatureC);
    // Ideal Nernst response: E = (7.0 - pH) * slope
    double potential = (7.0 - truePh) * slope;

    if (includeNonLinearity) {
      // 1. Asymmetry potential drift with temperature
      final double deltaT = temperatureC - 25.0;
      potential += 4.5 * (1.0 + 0.05 * deltaT);

      // 2. Glass membrane non-linear compression in acidic and alkaline extremes
      if (truePh < 4.5) {
        // Acid error due to hydronium ion activity deviation
        final double acidDiff = 4.5 - truePh;
        potential -= 6.2 * acidDiff * (1.0 + 0.02 * deltaT);
      } else if (truePh > 8.5) {
        // Alkaline sodium error
        final double alkDiff = truePh - 8.5;
        potential += 8.4 * alkDiff * (1.0 + 0.03 * deltaT);
      }

      // 3. Mild non-linear quadratic sensor curvature
      potential += 0.85 * pow(truePh - 7.0, 2) * (deltaT / 30.0);
    }

    if (includeNoise) {
      // Small Gaussian-like noise (±1.5 mV)
      final Random rng = Random();
      final double noise = (rng.nextDouble() - 0.5) * 3.0;
      potential += noise;
    }

    return double.parse(potential.toStringAsFixed(2));
  }
}
