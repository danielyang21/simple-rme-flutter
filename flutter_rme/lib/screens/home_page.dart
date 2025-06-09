import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reference Material Explorer')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('lib/assets/rme_icon.png', width: 200, height: 200),
                const SizedBox(height: 24),
                const Text(
                  'Reference Material Explorer',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 32),
                const Text(
                  'The RM Explorer is an application built upon the NRC Digital Repository external Application Programming Interfaces (APIs) that allows users to visualise, analyse and display useful information about the Reference Materials produced by the National Research Council of Canada. This application relies upon and complies with FAIR data principles and showcases multiple uses of machine-readable information in digital CRM certificates.',
                  textAlign: TextAlign.justify,
                  style: TextStyle(fontSize: 16, height: 1.5),
                ),
                const Divider(
                  height: 40,
                  thickness: 1,
                  color: Colors.grey,
                  indent: 15, // Left margin
                  endIndent: 15, // Right margin
                ),
                const Text(
                  'FAIR Compliance',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                const Text(
                  'The RM Explorer uses data from the digital certificates of reference materials and open-source compound identifiers (InChI / InChIKeys) to calculate information and present it in a user-friendly way. It also creates an integrated data structure by fetching information from external sources such as PubChem and comparing the information presented in these external sources to its calculated values.',
                  textAlign: TextAlign.justify,
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
