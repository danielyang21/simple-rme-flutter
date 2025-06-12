import 'package:flutter/material.dart';
import 'package:flutter_rme/models/pubchem_data.dart';
import 'package:flutter_rme/services/pubchem_service.dart';
import 'package:url_launcher/url_launcher.dart';

class PropertiesPage extends StatefulWidget {
  final String selectedAnalyte;

  const PropertiesPage({super.key, required this.selectedAnalyte});

  @override
  _PropertiesPageState createState() => _PropertiesPageState();
}

class _PropertiesPageState extends State<PropertiesPage> {
  late Future<PubChemData> _compoundData;
  final PubChemService _pubChemService = PubChemService();

  @override
  void initState() {
    super.initState();
    _compoundData = _pubChemService.getCompoundData(widget.selectedAnalyte);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Compound Properties')),
      body: FutureBuilder<PubChemData>(
        future: _compoundData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No data available'));
          }

          final data = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    'Showing Information on: ${data.name}',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                const SizedBox(height: 20),

                // Molecule Image
                if (data.imageUrl != null)
                  Center(
                    child: Image.network(
                      data.imageUrl!,
                      width: MediaQuery.of(context).size.width * 0.9,
                      fit: BoxFit.cover,
                    ),
                  ),

                const SizedBox(height: 20),

                // Properties
                _buildPropertySection(
                  context,
                  title: 'IUPAC Name',
                  value: data.iupacName,
                ),

                _buildPropertySection(
                  context,
                  title: 'Synonyms',
                  value: data.synonyms.join(', '),
                  tooltip: 'Top synonyms for this compound from PubChem',
                ),

                _buildPropertySection(
                  context,
                  title: 'Molecular Formula',
                  value: data.molecularFormula,
                ),

                _buildPropertySection(
                  context,
                  title: 'Molecular Weight',
                  value: '${data.molecularWeight} g/mol',
                ),

                _buildPropertySection(
                  context,
                  title: 'SMILES',
                  value: data.smiles,
                ),

                _buildPropertySection(
                  context,
                  title: 'InChIKey',
                  value: data.inchiKey,
                ),

                _buildPropertySection(
                  context,
                  title: 'Exact Mass',
                  value: '${data.exactMass} Da',
                  tooltip:
                      'Based on the most abundant isotope of each individual element',
                ),

                if (data.tpsa != null)
                  _buildPropertySection(
                    context,
                    title: 'Topological Polar Surface Area',
                    value: '${data.tpsa} Å²',
                  ),

                if (data.pKow != null)
                  _buildPropertySection(
                    context,
                    title: 'pKow',
                    value: data.pKow.toString(),
                  ),

                if (data.cid != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'PubChem',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        InkWell(
                          child: Text(
                            'https://pubchem.ncbi.nlm.nih.gov/compound/${data.cid}',
                            style: const TextStyle(
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                          onTap: () async {
                            await launchUrl(
                              Uri.parse(
                                'https://pubchem.ncbi.nlm.nih.gov/compound/${data.cid}',
                              ),
                              mode: LaunchMode.externalApplication,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPropertySection(
    BuildContext context, {
    required String title,
    required String value,
    String? tooltip,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              if (tooltip != null) ...[
                const SizedBox(width: 5),
                Tooltip(
                  message: tooltip,
                  child: const Icon(Icons.info_outline, size: 16),
                ),
              ],
            ],
          ),
          Text(value),
        ],
      ),
    );
  }
}
