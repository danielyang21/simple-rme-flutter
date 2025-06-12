import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/pubchem_data.dart';

class PubChemService {
  static const String _baseUrl = 'https://pubchem.ncbi.nlm.nih.gov/rest/pug';

  Future<PubChemData> getCompoundData(String identifier) async {
    //deal with multi-word, and extra brackets
    identifier = identifier.replaceAll(RegExp(r'\s*\([^)]*\)$'), ''); 
    identifier = identifier.replaceAll(' ', '-');

    try {
      // First try to get CID
      final cidResponse = await http.get(
        Uri.parse('$_baseUrl/compound/name/$identifier/cids/JSON'),
      );

      
      final cidJson = jsonDecode(cidResponse.body);
      final cid = cidJson['IdentifierList']['CID'][0];

      // Get compound properties
      final propertiesResponse = await http.get(
        Uri.parse('$_baseUrl/compound/cid/$cid/property/'
            'Title,IUPACName,MolecularFormula,MolecularWeight,InChIKey,SMILES,'
            'ExactMass,TPSA,XLogP/JSON'),
      );

      final propertiesJson = jsonDecode(propertiesResponse.body);
      final properties = propertiesJson['PropertyTable']['Properties'][0];

      // Parse numeric values safely
      double? parseNumeric(dynamic value) {
        if (value == null) return null;
        if (value is num) return value.toDouble();
        if (value is String) {
          return double.tryParse(value);
        }
        return null;
      }

      // Get synonyms
      List<String> synonyms = [];
      try {
        final synonymsResponse = await http.get(
          Uri.parse('$_baseUrl/compound/cid/$cid/synonyms/JSON'),
        );
        final synonymsJson = jsonDecode(synonymsResponse.body);
        synonyms = List<String>.from(
          synonymsJson['InformationList']['Information'][0]['Synonym'] ?? [],
        ).take(10).toList(); //take first 10 synonyms
      } catch (e) {
        print('Error fetching synonyms: $e');
      }


      return PubChemData(
        name: properties['Title'] ?? identifier,
        iupacName: properties['IUPACName'] ?? identifier,
        molecularFormula: properties['MolecularFormula'] ?? '',
        molecularWeight: parseNumeric(properties['MolecularWeight']),
        smiles: properties['SMILES'] ?? '',
        inchiKey: properties['InChIKey'] ?? '',
        exactMass: parseNumeric(properties['ExactMass']),
        tpsa: parseNumeric(properties['TPSA']),
        pKow: parseNumeric(properties['XLogP']),
        cid: cid,
        synonyms: synonyms.isNotEmpty ? synonyms : [identifier],
        imageUrl: '$_baseUrl/compound/cid/$cid/PNG',
      );
    } catch (e) {
      throw Exception('Failed to fetch compound data: $e');
    }
  }
}