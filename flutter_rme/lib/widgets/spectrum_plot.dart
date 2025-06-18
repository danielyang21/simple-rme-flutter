import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:csv/csv.dart';
import 'package:flutter_rme/models/spectrum_point.dart';

class SpectrumPlot extends StatefulWidget {
  final String csvData;

  const SpectrumPlot({Key? key, required this.csvData}) : super(key: key);

  @override
  _SpectrumPlotState createState() => _SpectrumPlotState();
}

class _SpectrumPlotState extends State<SpectrumPlot> {
  List<SpectrumPoint> _spectralData = [];
  double _maxIntensity = 0;
  double _minMass = 0;
  double _maxMass = 0;

  @override
  void initState() {
    super.initState();
    _parseCsvData();
  }

  void _parseCsvData() {
    final csvRows = const CsvToListConverter().convert(widget.csvData);
    
    // Skip header rows (everything before "Mass_to_charge,Relative_intensity")
    final dataStartIndex = csvRows.indexWhere(
      (row) => row.length >= 2 && 
              row[0].toString().contains('Mass_to_charge') &&
              row[1].toString().contains('Relative_intensity')
    ) + 1;

    if (dataStartIndex > 0 && dataStartIndex < csvRows.length) {
      final spectralData = csvRows
          .sublist(dataStartIndex)
          .where((row) => row.length >= 2)
          .map((row) => SpectrumPoint.fromCsv(row))
          .toList();

      if (spectralData.isNotEmpty) {
        final intensities = spectralData.map((e) => e.relativeIntensity).toList();
        final masses = spectralData.map((e) => e.massToCharge).toList();

        setState(() {
          _spectralData = spectralData;
          _maxIntensity = intensities.reduce((a, b) => a > b ? a : b);
          _minMass = masses.reduce((a, b) => a < b ? a : b);
          _maxMass = masses.reduce((a, b) => a > b ? a : b);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mass Spectrum'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: _spectralData.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : LineChart(
                      LineChartData(
                        minX: _minMass,
                        maxX: _maxMass,
                        minY: 0,
                        maxY: _maxIntensity * 1.1, // Add 10% padding
                        lineBarsData: [
                          LineChartBarData(
                            spots: _spectralData
                                .map((point) => FlSpot(
                                      point.massToCharge,
                                      point.relativeIntensity,
                                    ))
                                .toList(),
                            isCurved: false,
                            color: Colors.blue,
                            barWidth: 2,
                            isStrokeCapRound: true,
                            belowBarData: BarAreaData(show: false),
                            dotData: FlDotData(show: false),
                          ),
                        ],
                        titlesData: FlTitlesData(
                          show: true,
                          rightTitles: AxisTitles(),
                          topTitles: AxisTitles(),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 30,
                              interval: _calculateInterval(_maxMass - _minMass),
                              getTitlesWidget: (value, meta) {
                                return Text(value.toStringAsFixed(1));
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                              interval: _calculateInterval(_maxIntensity),
                              getTitlesWidget: (value, meta) {
                                return Text(value.toStringAsExponential(1));
                              },
                            ),
                          ),
                        ),
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: true,
                          horizontalInterval: _calculateInterval(_maxIntensity),
                          verticalInterval: _calculateInterval(_maxMass - _minMass),
                        ),
                        borderData: FlBorderData(
                          show: true,
                          border: Border.all(
                            color: Colors.grey,
                            width: 1,
                          ),
                        ),
                      ),
                    ),
            ),
            const SizedBox(height: 16),
            Text(
              'Mass Spectrum (m/z vs Relative Intensity)',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Text(
              'Range: ${_minMass.toStringAsFixed(2)} to ${_maxMass.toStringAsFixed(2)} m/z',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  double _calculateInterval(double range) {
    if (range <= 0) return 1;
    // Calculate a "nice" interval for axis labels
    final exponent = (log(range) / ln10).floor();
    final fraction = range / pow(10, exponent);
    
    if (fraction < 2) return 0.2 * pow(10, exponent);
    if (fraction < 5) return 0.5 * pow(10, exponent);
    return 1 * pow(10, exponent).toDouble();
  }
}