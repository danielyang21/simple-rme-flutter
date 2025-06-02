import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;
import 'package:html/parser.dart' as parser;
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_html/flutter_html.dart';

void main() {
  runApp(const NrcCrmApp());
}

class NrcCrmApp extends StatelessWidget {
  const NrcCrmApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NRC CRM Digital Repository',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const CrmSearchPage(),
    );
  }
}

class CrmItem {
  final String title;
  final String name;
  final String summary;
  final String id;

  CrmItem({
    required this.title,
    required this.name,
    required this.summary,
    required this.id,
  });
}

class CrmDetail {
  final String title;
  final String summary;
  final String? doi;
  final String? date;
  final List<Map<String, String>>? analyteData;

  CrmDetail({
    required this.title,
    required this.summary,
    this.doi,
    this.date,
    this.analyteData,
  });
}

class CrmSearchPage extends StatefulWidget {
  const CrmSearchPage({super.key});

  @override
  _CrmSearchPageState createState() => _CrmSearchPageState();
}

class _CrmSearchPageState extends State<CrmSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<CrmItem> _crmItems = [];
  List<String> _crmNames = [];
  String? _selectedCrm;
  CrmDetail? _selectedDetail;
  bool _isLoading = false;
  bool _initialLoadComplete = false;
  String? _errorMessage;
  bool _hasError = false;

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
      final response = await http
          .get(
            Uri.parse(
              'https://nrc-digital-repository.canada.ca/eng/search/atom/?q=*&fc=%2Bcn%3Acrm',
            ),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        try {
          final document = xml.XmlDocument.parse(response.body);
          final items = document.findAllElements('entry').skip(1);

          _crmItems = items
              .map((item) {
                final title = item.findElements('title').first.text;
                final name = title.split(':').first.trim();
                final summary = item.findElements('summary').first.text;
                final id = item.findElements('id').first.text;

                return CrmItem(
                  title: title,
                  name: name,
                  summary: summary,
                  id: id,
                );
              })
              .where((item) => item.title.isNotEmpty)
              .toList();

          _crmNames = _crmItems.map((item) => item.name).toSet().toList()
            ..sort();

          setState(() {
            _initialLoadComplete = true;
          });
        } catch (e) {
          _handleError('Failed to parse response data');
        }
      } else {
        _handleError(
          'Server responded with status code: ${response.statusCode}',
        );
      }
    } on http.ClientException catch (e) {
      _handleError(e.message);
    } on xml.XmlParserException {
      _handleError('Failed to parse XML response');
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
      final encodedQuery = Uri.encodeComponent(query);
      final response = await http
          .get(
            Uri.parse(
              'https://nrc-digital-repository.canada.ca/eng/search/atom/?q=$encodedQuery&fc=%2Bcn%3Acrm',
            ),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        try {
          final document = xml.XmlDocument.parse(response.body);
          final items = document.findAllElements('entry').skip(1);

          _crmItems = items
              .map((item) {
                final title = item.findElements('title').first.text;
                final name = title.split(':').first.trim();
                final summary = item.findElements('summary').first.text;
                final id = item.findElements('id').first.text;

                return CrmItem(
                  title: title,
                  name: name,
                  summary: summary,
                  id: id,
                );
              })
              .where((item) => item.title.isNotEmpty)
              .toList();

          _crmNames = _crmItems.map((item) => item.name).toSet().toList()
            ..sort();

          if (_crmNames.isEmpty) {
            _handleError('No results found', isWarning: true);
            _crmNames = ['No results'];
          }
        } catch (e) {
          _handleError('Failed to parse response data');
        }
      } else {
        _handleError(
          'Server responded with status code: ${response.statusCode}',
        );
      }
    } on http.ClientException catch (e) {
      _handleError(e.message);
    } on xml.XmlParserException {
      _handleError('Failed to parse XML response');
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
      _selectedCrm = crmName;
      _selectedDetail = null;
    });

    try {
      final crmItem = _crmItems.firstWhere((item) => item.name == crmName);
      final id = crmItem.id.replaceAll('urn:uuid:', '');
      final detailUrl =
          'https://nrc-digital-repository.canada.ca/eng/view/object/?id=$id';

      final response = await http
          .get(Uri.parse(detailUrl))
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final document = parser.parse(response.body);
        final tables = document.getElementsByTagName('table');

        String? doi;
        String? abstract;
        String? date;
        List<Map<String, String>>? analyteData;

        // Parse metadata table (first table)
        if (tables.isNotEmpty) {
          final firstTable = tables.first;
          final rows = firstTable.getElementsByTagName('tr');

          for (var row in rows) {
            final cells = row.getElementsByTagName('td');
            if (cells.length >= 2) {
              final key = cells[0].text.trim();
              final value = cells[1].text.trim();

              if (key == 'DOI') doi = value;
              if (key == 'Abstract') abstract = value;
              if (key == 'Publication date') date = value;
            }
          }
        }

        // Find the analyte table (look for table with "Analyte" in headers)
        for (var table in tables) {
          final headers = table.getElementsByTagName('th');
          final hasAnalyteHeader = headers.any(
            (th) => th.text.contains('Analyte'),
          );

          if (hasAnalyteHeader) {
            final rows = table.getElementsByTagName('tr');
            final headerRow = rows.first;
            final headers = headerRow
                .getElementsByTagName('th')
                .map((h) => h.text.trim())
                .toList();

            analyteData = [];

            for (var row in rows.skip(1)) {
              // Skip header row
              final cells = row.getElementsByTagName('td');
              if (cells.isNotEmpty) {
                final rowData = <String, String>{};
                for (var i = 0; i < cells.length && i < headers.length; i++) {
                  rowData[headers[i]] = cells[i].text.trim();
                }
                analyteData.add(rowData);
              }
            }
            break; // Stop after finding the first analyte table
          }
        }

        setState(() {
          _selectedDetail = CrmDetail(
            title: crmItem.title,
            summary: abstract ?? crmItem.summary,
            doi: doi,
            date: date,
            analyteData: analyteData,
          );
        });
      }
    } catch (e) {
      _handleError('Failed to load CRM details: ${e.toString()}');
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

  Widget _buildAnalyteTable() {
    if (_selectedDetail?.analyteData == null ||
        _selectedDetail!.analyteData!.isEmpty) {
      return const SizedBox.shrink();
    }

    // Get all column headers
    final allHeaders = _selectedDetail!.analyteData!
        .expand((row) => row.keys)
        .toSet()
        .toList();

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
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(4),
            ),
            child: DataTable(
              columnSpacing: 20,
              horizontalMargin: 12,
              headingRowColor: WidgetStateProperty.resolveWith<Color>(
                (Set<WidgetState> states) =>
                    Theme.of(context).primaryColor.withValues(),
              ),
              columns: allHeaders.map((header) {
                return DataColumn(
                  label: Text(
                    header,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  tooltip: header,
                );
              }).toList(),
              rows: _selectedDetail!.analyteData!.map((row) {
                return DataRow(
                  cells: allHeaders.map((header) {
                    return DataCell(Text(row[header] ?? ''));
                  }).toList(),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
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
                  const Text('v2. 2024', style: TextStyle(fontSize: 12)),
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
                      const Text('DOI:'),
                      GestureDetector(
                        onTap: () async {
                          final url = _selectedDetail!.doi!.startsWith('http')
                              ? _selectedDetail!.doi!
                              : 'https://doi.org/${_selectedDetail!.doi!.replaceAll('Resolve DOI:', '').trim()}';
                          if (await canLaunchUrl(Uri.parse(url))) {
                            await launchUrl(Uri.parse(url));
                          }
                        },
                        child: Text(
                          _selectedDetail!.doi!,
                          style: const TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                    if (_selectedDetail!.date != null)
                      Text('Publication date: ${_selectedDetail!.date}'),
                    _buildAnalyteTable(),
                  ],
                ],
              ),
            ),
    );
  }
}
