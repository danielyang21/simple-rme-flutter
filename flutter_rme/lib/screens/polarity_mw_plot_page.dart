import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../global_state.dart';

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
        title: const Text('Polarity vs. Molecular Weight Plot'),
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
                return Dismissible(
                  key: Key(analyte.name),
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Text(
                      'Remove',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                  onDismissed: (_) => globalState.removeAnalytes([analyte]),
                  child: ListTile(title: Text(analyte.name)),
                );
              },
            ),
    );
  }
}
