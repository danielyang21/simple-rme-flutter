import 'package:flutter/material.dart';
import 'nrc_service.dart';

void main() {
  runApp(
    MaterialApp(home: NRCApp()),
  );
}


class NRCApp extends StatefulWidget {
  const NRCApp({super.key});

  @override
  State<NRCApp> createState() => _NRCAppState();
}




class _NRCAppState extends State<NRCApp> {
  List<CRMEntry> _allCrms = [];
  bool _isLoading = false;
  bool _hasFetched = false;

  CRMEntry? _selectedEntry;


  Future<void> _fetchAllCrmsIfNeeded() async {
    if (_hasFetched) return;

    setState(() => _isLoading = true);

    try {
      final results = await fetchCRMs('crm');
      setState(() {
        _allCrms = results;
        _hasFetched = true;
      });
    } catch (e) {
      setState(() {
        _allCrms = [];
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('NRC CRM Digital Repository')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            SearchAnchor(
              builder: (BuildContext context, SearchController controller) {
                return SearchBar(
                  controller: controller,
                  padding: const WidgetStatePropertyAll<EdgeInsets>(
                    EdgeInsets.symmetric(horizontal: 16.0),
                  ),
                  leading: const Icon(Icons.search),
                  onTap: () async {
                    await _fetchAllCrmsIfNeeded();
                    controller.openView();
                  },
                  onChanged: (query) {
                    controller.openView();
                  },
                );
              },
            
              suggestionsBuilder: (BuildContext context, SearchController controller) {
                final query = controller.text.toLowerCase();
                if (_isLoading) {
                    return const [
                    ListTile(
                        leading: CircularProgressIndicator(),
                        title: Text('Loading CRMs...'),
                    ),
                    ];
                }
            
                final filtered = _allCrms.where((entry) {
                    return entry.name.toLowerCase().contains(query) ||
                        entry.summary.toLowerCase().contains(query);
                }).toList();
            
                if (filtered.isEmpty) {
                    return const [
                    ListTile(
                        title: Text('No CRMs found.'),
                    ),
                    ];
                }
            
                return filtered.map((entry) {
                    return ListTile(
                    title: Text(entry.name),
                    onTap: () {
                        controller.closeView(entry.name);
                        setState(() {
                            _selectedEntry = entry;
                        });
            
                    },
                    );
                }).toList();
              },
            ),

            if (_selectedEntry != null) ...[
                const SizedBox(height: 16),
                Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                                Text(
                                    _selectedEntry!.name,
                                    style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                    ),
                                ),
                                const SizedBox(height: 8),
                                Text(_selectedEntry!.summary),
                                const SizedBox(height: 8),
                                //Text('DOI : ${_selectedEntry!.doi}')
                            ],
                        )
                    ),
                )
            ]
          ],
        ),
      ),
    );
  }
}
