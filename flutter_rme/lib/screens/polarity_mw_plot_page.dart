import 'package:flutter/material.dart';
import 'package:flutter_rme/models/pubchem_data.dart';
import 'package:provider/provider.dart';

import '../global_state.dart';
import '../services/pubchem_service.dart';

class PolarityMwPlotPage extends StatefulWidget {
  const PolarityMwPlotPage({super.key});

  @override
  State<PolarityMwPlotPage> createState() => _PolarityMwPlotPageState();
}

class _PolarityMwPlotPageState extends State<PolarityMwPlotPage> {
  @override
  Widget build(BuildContext context) {
    final globalState = Provider.of<GlobalState>(context);
    final selectedAnalytes = globalState.selectedAnalytes;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Polarity vs. Molecular Weight'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => globalState.clearAllAnalytes(),
          ),
        ],
      ),
      body: selectedAnalytes.isEmpty
          ? const Center(child: Text('No analytes selected'))
          : ListView.builder(
              itemCount: selectedAnalytes.length,
              itemBuilder: (context, index) {
                final analyte = selectedAnalytes[index];
                final compoundData = PubChemService().getCompoundData(analyte.name);
                
                return FutureBuilder<PubChemData>(
                  future: compoundData,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return ListTile(
                        title: Text(analyte.name),
                        subtitle: const Text('Loading data...'),
                      );
                    }
                    
                    if (snapshot.hasError) {
                      return ListTile(
                        title: Text(analyte.name),
                        subtitle: const Text('Data unavailable'),
                      );
                    }
                    
                    final data = snapshot.data;
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              analyte.name,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            if (data != null) ...[
                              Text('Polarity: ${data.pKow}'),
                              Text('Molecular Weight: ${data.molecularWeight}'),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}