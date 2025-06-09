import 'package:flutter/material.dart';

class InstructionsPage extends StatelessWidget {
  const InstructionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Instructions')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'General Search Page',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Use the dropdown to search for an Inchikey, Compound, IUPAC or any Keyword. There is a check box next to the search dropdown that lets you pick whether you want to add the selected substance to the table or if you want the selected substance to replace everything that is in the table. You can then select a compound from the table shown in order to display its properties on the Properties tab. You can also select a substance from the table and see its spectral data (if it has any) on the Spectral Data tab. You can clear all your selection by clicking the \'Unselect All Rows\' button located at the top right of the page. You can save the substances you have loaded in the table by clicking the \'Save Table Substances\' button. This will give you a .csv file. If you want to view the same table later on, you can load it by clicking the \'Load Saved Substances\' button and uploading the .csv file.',
                  textAlign: TextAlign.justify,
                  style: TextStyle(fontSize: 16, height: 1.5),
                ),
                const SizedBox(height: 10),
                const Divider(
                  height: 40,
                  thickness: 1,
                  color: Colors.grey,
                  indent: 15, // Left margin
                  endIndent: 15, // Right margin
                ),

                
              ],
            ),
          ),
        ),
      ),
    );
  }
}
