import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_rme/widgets/spectrum_plot.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;

class SpectrumPage extends StatefulWidget {
  final String selectedAnalyte;
  const SpectrumPage({super.key, required this.selectedAnalyte});

  @override
  State<SpectrumPage> createState() => _SpectrumPageState();
}

class _SpectrumPageState extends State<SpectrumPage> {
  String? _errorMessage;
  String? _csvData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchSpectrumData();
  }

  Future<void> _fetchSpectrumData() async {
    try {
      // Build the URI for the Atom feed based on the selected analyte
      final uri = Uri.parse(
        'https://nrc-digital-repository.canada.ca/eng/search/atom/?q=${widget.selectedAnalyte.replaceAll(' ', '+')}',
      );

      print('Fetching Atom feed from: $uri');

      final response = await http.get(uri);
      if (response.statusCode != 200) {
        throw Exception('Failed to load Atom feed');
      }

      // Parse the Atom feed
      final document = xml.XmlDocument.parse(response.body);
      final datasetUrl = _findDatasetUrl(document);
      if (datasetUrl == null) {
        throw Exception('No spectral data found for ${widget.selectedAnalyte}');
      }

      print('Dataset URL: $datasetUrl');

      // Download the CSV data
      final csvResponse = await http.get(Uri.parse(datasetUrl));
      if (csvResponse.statusCode != 200) {
        throw Exception('Failed to download CSV data');
      }

      setState(() {
        _csvData = csvResponse.body;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading data: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  // Helper function to find the dataset URL in the Atom feed
  String? _findDatasetUrl(xml.XmlDocument document) {
    try {
      return document
          .findAllElements('link')
          .firstWhere(
            (link) =>
                link.getAttribute('type') == 'text/csv' &&
                link
                        .getAttribute('title')
                        ?.toLowerCase()
                        .contains('spectrum') ==
                    true,
          )
          .getAttribute('href');
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.selectedAnalyte)),
        body: Center(child: Text(_errorMessage!)),
      );
    }

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.selectedAnalyte)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_csvData == null) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.selectedAnalyte)),
        body: const Center(child: Text('No spectral data available')),
      );
    }

    return SpectrumPlot(csvData: _csvData!);
  }
}
