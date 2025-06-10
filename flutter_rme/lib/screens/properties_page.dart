import 'package:flutter/material.dart';
import 'package:flutter_rme/models/analyte.dart';

class PropertiesPage extends StatelessWidget {
  const PropertiesPage({super.key, required this.analytes});

  final List<Analyte> analytes;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Analyte Details')),
      body: ListView.builder(
        itemCount: analytes.length,
        itemBuilder: (context, index) {
          final analyte = analytes[index];
          return ListTile(
            title: Text(analyte.name),
            subtitle: Text('Value: ${analyte.value}'),
          );
        },
      ),
    );
  }
}
