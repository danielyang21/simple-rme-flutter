import 'package:flutter/material.dart';
import '../models/analyte.dart';

class AnalyteTable extends StatelessWidget {
  final List<Analyte>? analytes;

  const AnalyteTable({super.key, required this.analytes});

  @override
  Widget build(BuildContext context) {
    if (analytes == null || analytes!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text(
          'Analyte Composition:',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: const [
              DataColumn(label: Text('Analyte')),
              DataColumn(label: Text('Quantity')),
              DataColumn(label: Text('Value')),
              DataColumn(label: Text('Uncertainty')),
              DataColumn(label: Text('Unit')),
              DataColumn(label: Text('Type')),
            ],
            rows: analytes!.map((analyte) {
              return DataRow(
                cells: [
                  DataCell(Text(analyte.name)),
                  DataCell(Text(analyte.quantity)),
                  DataCell(Text(analyte.value)),
                  DataCell(Text(analyte.uncertainty)),
                  DataCell(Text(analyte.unit)),
                  DataCell(Text(analyte.type)),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
