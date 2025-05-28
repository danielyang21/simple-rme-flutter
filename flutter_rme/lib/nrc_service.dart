import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';

class CRMEntry {
  final String title;
  final String summary;
  final String id;
  final String crmCode;

  CRMEntry({required this.title, required this.summary, required this.id, required this.crmCode});

  String get name => crmCode;
}


Future<List<CRMEntry>> fetchCRMs(String query) async {
  final url = Uri.parse('https://nrc-digital-repository.canada.ca/eng/search/atom/?q=*&fc=%2Bcn%3Acrm');
  final response = await http.get(url);
  final document = XmlDocument.parse(response.body);
  

  final entries = document.findAllElements('entry');

  List<CRMEntry> results = [];

  for (var entry in entries) {
    final title = entry.getElement('title')?.value ?? '';
    final id = entry.getElement('id')?.value ?? '';
    final summary = entry.getElement('summary')?.value ?? '';
    
    //crmCode stuff
    final categories = entry.findElements('category').toList();
    final thirdCategory = categories[2];
    final crmCode = thirdCategory.getAttribute('term') ?? '';
    
    

    results.add(CRMEntry(
      title: title,
      summary: summary,
      id: id,
      crmCode: crmCode,
    ));

    print(entry);
    print(crmCode);
    
  }

  results.sort((a, b) => a.crmCode.compareTo(b.crmCode));
  return results;
}
