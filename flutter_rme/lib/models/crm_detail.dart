import 'analyte.dart';

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
