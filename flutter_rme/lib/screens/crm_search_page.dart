import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';

import '../models/analyte.dart';
import '../models/crm_item.dart';
import '../models/crm_detail.dart';
import '../screens/properties_page.dart';
import '../screens/spectrum_page.dart';
import '../services/crm_service.dart';
import '../widgets/analyte_table.dart';
import '../global_state.dart';

class CrmSearchPage extends StatefulWidget {
  const CrmSearchPage({super.key});

  @override
  _CrmSearchPageState createState() => _CrmSearchPageState();
}

class _CrmSearchPageState extends State<CrmSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final CrmService _crmService = CrmService();

  List<CrmItem> _crmItems = [];
  List<String> _crmNames = [];
  String? _selectedCrm;
  CrmDetail? _selectedDetail;
  bool _isLoading = false;
  bool _initialLoadComplete = false;
  String? _errorMessage;
  bool _hasError = false;

  List<Analyte> _selectedAnalytes = [];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = null;
    });

    try {
      _crmItems = await _crmService.loadInitialData();
      _crmNames = _crmItems.map((item) => item.name).toSet().toList()..sort();

      setState(() {
        _initialLoadComplete = true;
      });
    } catch (e) {
      _handleError(e.toString());
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _searchCrm(String query) async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = null;
      _selectedCrm = null;
      _selectedDetail = null;
    });

    try {
      _crmItems = await _crmService.searchCrm(query);
      _crmNames = _crmItems.map((item) => item.name).toSet().toList()..sort();

      if (_crmNames.isEmpty) {
        _handleError('No results found', isWarning: true);
      }
    } catch (e) {
      _handleError(e.toString());
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadCrmDetail(String crmName) async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = null;
      _selectedDetail = null;
    });

    try {
      final crmItem = _crmItems.firstWhere(
        (item) => item.name == crmName,
        orElse: () => throw Exception('CRM not found'),
      );

      final crmDetail = await _crmService.loadCrmDetail(crmItem);

      setState(() {
        _selectedCrm = crmName;
        _selectedDetail = crmDetail;
      });
    } catch (e) {
      _handleError('Error fetching CRM details: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _handleError(String message, {bool isWarning = false}) {
    if (mounted) {
      setState(() {
        _errorMessage = message;
        _hasError = !isWarning;
      });
    }
  }

  void _navigateToPropertiesPage() {
    if (_selectedAnalytes.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              PropertiesPage(selectedAnalyte: _selectedAnalytes[0].name),
        ),
      );
    }
  }

  void _navigateToSpectrumPage() {
    if (_selectedAnalytes.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              SpectrumPage(selectedAnalyte: _selectedAnalytes[0].name),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('NRC CRM Digital Repository')),
      body: _isLoading && !_initialLoadComplete
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      labelText: 'Search CRMs',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      if (_searchController.text.isNotEmpty) {
                        _searchCrm(_searchController.text);
                      }
                    },
                    child: const Text('Submit'),
                  ),
                  const SizedBox(height: 16),
                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(
                          color: _hasError ? Colors.red : Colors.orange,
                        ),
                      ),
                    ),
                  if (_crmNames.isNotEmpty)
                    DropdownButtonFormField<String>(
                      value: _selectedCrm,
                      hint: const Text('Select a CRM'),
                      items: _crmNames.map((name) {
                        return DropdownMenuItem<String>(
                          value: name,
                          child: Text(name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null && value != 'No results') {
                          _loadCrmDetail(value);
                        }
                      },
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                    ),
                  const SizedBox(height: 24),
                  if (_selectedDetail != null) ...[
                    Text(
                      _selectedDetail!.title,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Html(data: _selectedDetail!.summary),
                    const SizedBox(height: 8),
                    if (_selectedDetail!.doi != null) ...[
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          const Text('DOI: '),
                          InkWell(
                            onTap: () async {
                              String url = _selectedDetail!.doi!;
                              await launchUrl(
                                Uri.parse(url),
                                mode: LaunchMode.externalApplication,
                              );
                            },
                            child: Text(
                              _selectedDetail!.doi!,
                              style: const TextStyle(
                                color: Colors.blue,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],
                    if (_selectedDetail!.date != null)
                      Text('Publication date: ${_selectedDetail!.date}'),
                    AnalyteTable(
                      analytes: _selectedDetail!.analyteData,
                      onSelectionChanged: (selected) {
                        setState(() => _selectedAnalytes = selected);
                        Provider.of<GlobalState>(
                          context,
                          listen: false,
                        ).addAnalytes(selected);
                      },
                    ),

                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _selectedAnalytes.isNotEmpty
                          ? _navigateToPropertiesPage
                          : null,
                      child: const Text('View Selected Properties'),
                    ),

                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _selectedAnalytes.isNotEmpty
                          ? _navigateToSpectrumPage
                          : null,
                      child: const Text('View Selected Spectrum'),
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}
