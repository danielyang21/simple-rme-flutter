import 'package:flutter/material.dart';
import 'screens/crm_search_page.dart';

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
