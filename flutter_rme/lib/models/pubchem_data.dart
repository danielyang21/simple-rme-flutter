class PubChemData {
  final String name;
  final String molecularFormula;
  final double? molecularWeight;
  final String smiles;
  final String inchiKey;
  final double? exactMass;
  final double? tpsa;
  final double? pKow;
  final int? cid;
  final List<String> synonyms;
  final String? imageUrl;

  PubChemData({
    required this.name,
    required this.molecularFormula,
    this.molecularWeight,
    required this.smiles,
    required this.inchiKey,
    this.exactMass,
    this.tpsa,
    this.pKow,
    this.cid,
    required this.synonyms,
    this.imageUrl,
  });

  factory PubChemData.fromJson(Map<String, dynamic> json) {
    double? parseDouble(dynamic value) {
      if (value == null) return null;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value);
      return null;
    }

    int? parseInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is double) return value.toInt();
      if (value is String) return int.tryParse(value);
      return null;
    }

    return PubChemData(
      name: json['name']?.toString() ?? 'Unknown',
      molecularFormula: json['molecularFormula']?.toString() ?? '',
      molecularWeight: parseDouble(json['molecularWeight']),
      smiles: json['smiles']?.toString() ?? '',
      inchiKey: json['inchiKey']?.toString() ?? '',
      exactMass: parseDouble(json['exactMass']),
      tpsa: parseDouble(json['tpsa']),
      pKow: parseDouble(json['pKow']),
      cid: parseInt(json['cid']),
      synonyms: List<String>.from(json['synonyms']?.map((x) => x.toString()) ?? []),
      imageUrl: json['imageUrl']?.toString(),
    );
  }
}