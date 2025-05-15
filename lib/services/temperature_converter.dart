class TemperatureConverter {
  static double? kelvinToCelsius(num? kelvin) {
  if (kelvin == null || kelvin <= 250 || kelvin >= 320) return null;
  return (kelvin - 273.15).toDouble();
}

  static String formatTemperature(num? tempCelsius, bool isCelsius) {
    if (tempCelsius == null) return '--';

    if (!isCelsius) {
      final fahrenheit = (tempCelsius * 9 / 5) + 32;
      return '${fahrenheit.round()}°F';
    } else {
      return '${tempCelsius.round()}°C';
    }
  }
}