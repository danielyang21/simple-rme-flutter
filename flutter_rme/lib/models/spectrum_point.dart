class SpectrumPoint {
  final double massToCharge;
  final double relativeIntensity;

  SpectrumPoint({
    required this.massToCharge,
    required this.relativeIntensity,
  });

  factory SpectrumPoint.fromCsv(List<dynamic> csvRow) {
    return SpectrumPoint(
      massToCharge: double.parse(csvRow[0].toString()),
      relativeIntensity: double.parse(csvRow[1].toString()),
    );
  }
}