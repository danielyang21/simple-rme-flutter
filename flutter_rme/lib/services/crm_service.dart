import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;
import 'package:html/parser.dart' as parser;
import '../models/crm_item.dart';
import '../models/crm_detail.dart';
import '../models/analyte.dart';

class CrmService {
  Future<List<CrmItem>> loadInitialData() async {
    final response = await http
        .get(Uri.parse(
            'https://nrc-digital-repository.canada.ca/eng/search/atom/?q=*&fc=%2Bcn%3Acrm'))
        .timeout(const Duration(seconds: 30));

    if (response.statusCode == 200) {
      final document = xml.XmlDocument.parse(response.body);
      final items = document.findAllElements('entry').skip(1);

      return items
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
    } else {
      throw Exception(
          'Server responded with status code: ${response.statusCode}');
    }
  }

  Future<List<CrmItem>> searchCrm(String query) async {
    final encodedQuery = Uri.encodeComponent(query);
    final response = await http
        .get(Uri.parse(
            'https://nrc-digital-repository.canada.ca/eng/search/atom/?q=$encodedQuery&fc=%2Bcn%3Acrm'))
        .timeout(const Duration(seconds: 30));

    if (response.statusCode == 200) {
      final document = xml.XmlDocument.parse(response.body);
      final items = document.findAllElements('entry').skip(1);

      return items
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
    } else {
      throw Exception(
          'Server responded with status code: ${response.statusCode}');
    }
  }

  Future<CrmDetail> loadCrmDetail(CrmItem crmItem) async {
    final formattedId = crmItem.id.replaceAll('urn:uuid:', '');
    final url =
        'https://nrc-digital-repository.canada.ca/eng/view/object/?id=$formattedId';

    final response = await http
        .get(Uri.parse(url))
        .timeout(const Duration(seconds: 30));

    if (response.statusCode == 200) {
      final htmlString = response.body;
      final document = parser.parse(htmlString);

      String title = crmItem.name;
      final titleElement =
          document.querySelector('h1#wb-cont span.citation_title');
      if (titleElement != null) {
        title = titleElement.text.trim();
      }

      List<Analyte> analytes = [];
      try {
        final analyteTable = document
            .querySelectorAll('.table-viewobject .table.table-condensed')[1];
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
        analytes = [];
      }

      final summaryText = document
          .querySelector('div.metadata-abstract span[itemprop="description"]')
          ?.text
          .trim();

      final doiLink =
          document.querySelector('a[itemprop="sameAs"]')?.attributes['href'];

      final datePublished = document
          .querySelector('span[itemprop="datePublished"]')
          ?.text
          .trim();

      return CrmDetail(
        title: title,
        summary: summaryText ?? 'No summary available',
        doi: doiLink,
        date: datePublished,
        analyteData: analytes,
      );
    } else {
      throw Exception(
          'Server responded with status code: ${response.statusCode}');
    }
  }
}
