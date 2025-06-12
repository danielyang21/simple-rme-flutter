import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SpectrumPage extends StatefulWidget {
  final String selectedAnalyte;
  const SpectrumPage({super.key, required this.selectedAnalyte});

  @override
  State<SpectrumPage> createState() => _SpectrumPageState();
}

class _SpectrumPageState extends State<SpectrumPage> {
  List<List<String>> spectrumData = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchSpectrumData();
  }

  Future<void> fetchSpectrumData() async {
    try {
      final uri = Uri.parse('https://nrc-digital-repository.canada.ca/eng/view/dataset/?id=a378a45e-91d2-46f0-be8e-15bef03f3216');

      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final lines = const LineSplitter().convert(response.body);
        final data = <List<String>>[];

        // Skip metadata until reaching the actual data header
        bool foundHeader = false;
        for (final line in lines) {
          if (!foundHeader) {
            if (line.trim().toLowerCase().startsWith('mass_to_charge')) {
              foundHeader = true;
            }
            continue;
          }
          if (line.trim().isEmpty) continue;

          final parts = line.split(',');
          if (parts.length == 2) {
            data.add(parts);
          }
        }

        setState(() {
          spectrumData = data;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to fetch spectrum data');
      }
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Spectrum for ${widget.selectedAnalyte}')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Text('Error: $error'))
              : ListView.builder(
                  itemCount: spectrumData.length,
                  itemBuilder: (context, index) {
                    final row = spectrumData[index];
                    return ListTile(
                      title: Text('m/z: ${row[0]}'),
                      subtitle: Text('Intensity: ${row[1]}'),
                    );
                  },
                ),
    );
  }
}
