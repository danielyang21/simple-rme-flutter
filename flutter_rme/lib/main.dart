import 'package:flutter/material.dart';
import 'package:flutter_rme/screens/home_page.dart';
import 'package:flutter_rme/screens/instructions_page.dart';
import 'package:flutter_rme/screens/polarity_mw_plot_page.dart';
import 'screens/crm_search_page.dart';
import 'dart:io';
import 'package:flutter_rme/global_state.dart';
import 'package:provider/provider.dart';

//http overrides to allow self-signed certificates
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main() {
  HttpOverrides.global = MyHttpOverrides();
  runApp(
    ChangeNotifierProvider(
      create: (context) => GlobalState(),
      child: const NrcCrmApp(),
    ),
  );
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
      home: const MainNavigationWrapper(),
    );
  }
}

// wrapper widget to handle navigation
class MainNavigationWrapper extends StatefulWidget {
  const MainNavigationWrapper({super.key});

  @override
  State<MainNavigationWrapper> createState() => _MainNavigationWrapperState();
}

class _MainNavigationWrapperState extends State<MainNavigationWrapper> {
  int _currentIndex = 0;

  // List of pages
  final List<Widget> _pages = [
    const HomePage(),
    const CrmSearchPage(),
    const PolarityMwPlotPage(),
    const InstructionsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.house), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Polarity MW Plot',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info),
            label: 'Instructions',
          ),
        ],
      ),
    );
  }
}
