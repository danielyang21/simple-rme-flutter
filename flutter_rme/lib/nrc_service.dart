import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';

class CRMEntry {
  final String id;
  final String summary;
  final String crmCode;

  CRMEntry({required this.id, required this.summary, required this.crmCode});

  String get name => crmCode;
}


Future<List<CRMEntry>> fetchCRMs(String query) async {
  final url = Uri.parse('https://nrc-digital-repository.canada.ca/eng/search/atom/?q=*&fc=%2Bcn%3Acrm');
  final response = await http.get(url);
  if (response.statusCode != 200) {
    throw Exception('Failed to fetch data');
  }
  final document = XmlDocument.parse(response.body);
  final entries = document.findAllElements('entry');
  
  print("Length ${entries.length}");
  List<CRMEntry> results = [];

  for (var entry in entries) {
    final rawId = entry.findElements('id').toList().first.text.trim();
    final id = rawId.replaceFirst("urn:uuid:", "");
    final summary = entry.findElements('summary').toList().first.text.trim();
    final link = "https://nrc-digital-repository.canada.ca/eng/view/object/?id=$id";
    
    print(link);

    //crmCode stuff
    final categories = entry.findElements('category').toList();
    final thirdCategory = categories[2];
    final crmCode = thirdCategory.getAttribute('term') ?? '';

    results.add(CRMEntry(
      id: id,
      summary: summary,
      crmCode: crmCode,
    ));
    
  }

  results.sort((a, b) => a.crmCode.compareTo(b.crmCode));
  return results;
}
