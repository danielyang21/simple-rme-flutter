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
  final List<Analyte>? analyteData;

  CrmDetail({
    required this.title,
    required this.summary,
    this.doi,
    this.date,
    this.analyteData,
  });
}

class Analyte {
  final String name;
  final String quantity;
  final String value;
  final String uncertainty;
  final String unit;
  final String type;

  Analyte({
    required this.name,
    required this.quantity,
    required this.value,
    required this.uncertainty,
    required this.unit,
    required this.type,
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
            _crmNames = [];
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
      _selectedDetail = null;
    });

    try {
      // Find the matching CRM item to get its ID
      final crmItem = _crmItems.firstWhere(
        (item) => item.name == crmName,
        orElse: () => throw Exception('CRM not found'),
      );

      // Construct the URL using the ID from the CRM item
      final formattedId = crmItem.id.replaceAll('urn:uuid:', '');
      final url =
          'https://nrc-digital-repository.canada.ca/eng/view/object/?id=$formattedId';

      // Make the HTTP request to get the HTML content
      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 30));
      if (response.statusCode == 200) {
        // Store the HTML string
        final htmlString = response.body;

        // Parse the HTML to extract the title and summary
        final document = parser.parse(htmlString);

        // Extract title from the specific h1 tag
        String title =
            crmName; // Default to CRM name in case we can't find the title
        final titleElement = document.querySelector(
          'h1#wb-cont span.citation_title',
        );
        if (titleElement != null) {
          title = titleElement.text.trim();
        }

        // Extract analyte data from the table
        List<Analyte> analytes = [];
        try {
          final analyteTable = document.querySelectorAll(
            '.table-viewobject .table.table-condensed',
          )[1];
          final rows = analyteTable.querySelectorAll('tbody tr');

          for (final row in rows) {
            final cells = row.querySelectorAll('td');
            if (cells.length >= 6) {
              analytes.add(
                Analyte(
                  name: cells[0].text.trim(),
                  quantity: cells[1].text.trim(),
                  value: cells[2].text.trim(),
                  uncertainty: cells[3].text.trim(),
                  unit: cells[4].text.trim(),
                  type: cells[5].text.trim(),
                ),
              );
            }
          }
        } on RangeError catch (_) {
          // Silently ignore RangeError if no analyte data is found
          analytes = [];
        }

        final summaryText = document.querySelector(
          'div.metadata-abstract span[itemprop="description"]',
        )?.text.trim();

        final doiLink = document
            .querySelector('a[itemprop="sameAs"]')
            ?.attributes['href'];

        final datePublished = document
            .querySelector('span[itemprop="datePublished"]')
            ?.text
            .trim();

        // Create CrmDetail object with the extracted information
        final crmDetail = CrmDetail(
          title: title,
          summary: summaryText ?? 'No summary available',
          doi: doiLink,
          date: datePublished,
          analyteData: analytes,
        );

        setState(() {
          _selectedCrm = crmName;
          _selectedDetail = crmDetail;
          _isLoading = false;
        });
      } else {
        _handleError(
          'Server responded with status code: ${response.statusCode}',
        );
      }
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

  Widget _buildAnalyteTable() {
    if (_selectedDetail?.analyteData == null ||
        _selectedDetail!.analyteData!.isEmpty) {
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
            rows: _selectedDetail!.analyteData!.map((analyte) {
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
                    _buildAnalyteTable(),
                  ],
                ],
              ),
            ),
    );
  }
}
