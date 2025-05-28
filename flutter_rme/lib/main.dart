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
  final SearchController _controller = SearchController();
  List<CRMEntry> _allCrms = [];
  List<CRMEntry> _filteredSuggestions = [];
  bool _isLoading = false;
  bool _hasFetched = false;

  void _filterSuggestions(String query) {
    final q = query.toLowerCase();
    setState(() {
      _filteredSuggestions = _allCrms.where((entry) {
        return entry.name.toLowerCase().contains(q) ||
               entry.summary.toLowerCase().contains(q);
      }).toList();
    });
  }

  Future<void> _fetchAllCrmsIfNeeded() async {
    if (_hasFetched) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final results = await fetchCRMs('crm');
      setState(() {
        _allCrms = results;
        _filteredSuggestions = results;
        _hasFetched = true;
      });
    } catch (e) {
      setState(() {
        _allCrms = [];
        _filteredSuggestions = [];
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('NRC CRM Digital Repository')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SearchAnchor(
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
                _filterSuggestions(query);
                controller.openView();
              },
            );
          },
          suggestionsBuilder: (BuildContext context, SearchController controller) {
            if (_isLoading) {
              return const [
                ListTile(
                  leading: CircularProgressIndicator(),
                  title: Text('Loading CRMs...'),
                ),
              ];
            }

            if (_filteredSuggestions.isEmpty) {
              return const [
                ListTile(
                  title: Text('No CRMs found.'),
                ),
              ];
            }

            return _filteredSuggestions.map((entry) {
              return ListTile(
                title: Text(entry.name),
                subtitle: Text(entry.summary),
                onTap: () {
                  controller.closeView(entry.name);
                },
              );
            }).toList();
          },
        ),
      ),
    );
  }
}