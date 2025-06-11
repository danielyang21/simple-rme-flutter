import 'package:flutter/material.dart';
import '../models/analyte.dart';

class AnalyteTable extends StatefulWidget {
  final List<Analyte>? analytes;
  final void Function(List<Analyte>)? onSelectionChanged;

  const AnalyteTable({
    super.key,
    required this.analytes,
    this.onSelectionChanged,
  });

  @override
  State<AnalyteTable> createState() => _AnalyteTableState();
}

class _AnalyteTableState extends State<AnalyteTable> {
  int? _sortColumnIndex;
  bool _sortAscending = true;
  late List<Analyte> _sortedAnalytes;
  String _searchText = '';
  final TextEditingController _searchController = TextEditingController();
  final List<Analyte> _selectedAnalytes = [];

  @override
  void initState() {
    super.initState();
    _sortedAnalytes = List.from(widget.analytes ?? []);
    _searchController.addListener(_updateSearchText);
  }

  void _updateSearchText() {
    setState(() {
      _searchText = _searchController.text.toLowerCase();
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_updateSearchText);
    _searchController.dispose();
    super.dispose();
  }

  void _sort<T>(
    Comparable<T> Function(Analyte analyte) getField,
    int columnIndex,
    bool ascending,
  ) {
    setState(() {
      _sortedAnalytes.sort((a, b) {
        final aValue = getField(a);
        final bValue = getField(b);
        return ascending
            ? Comparable.compare(aValue, bValue)
            : Comparable.compare(bValue, aValue);
      });

      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
    });
  }

  List<Analyte> get _filteredAnalytes {
    if (_searchText.isEmpty) return _sortedAnalytes;
    return _sortedAnalytes.where((a) {
      return a.name.toLowerCase().contains(_searchText) ||
          a.quantity.toLowerCase().contains(_searchText) ||
          a.value.toLowerCase().contains(_searchText) ||
          a.uncertainty.toLowerCase().contains(_searchText) ||
          a.unit.toLowerCase().contains(_searchText) ||
          a.type.toLowerCase().contains(_searchText);
    }).toList();
  }

  void _toggleSelection(Analyte analyte) {
    setState(() {
      if (_selectedAnalytes.contains(analyte)) {
        _selectedAnalytes.remove(analyte);
      } else {
        _selectedAnalytes.add(analyte);
      }
      widget.onSelectionChanged?.call(List.from(_selectedAnalytes));
    });
  }

  bool _isSelected(Analyte analyte) {
    return _selectedAnalytes.contains(analyte);
  }

  @override
  Widget build(BuildContext context) {
    if (_sortedAnalytes.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text(
          'Analyte Composition:',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            labelText: 'Filter analytes',
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            sortColumnIndex: _sortColumnIndex,
            sortAscending: _sortAscending,
            columns: [
              DataColumn(
                label: const Text('Analyte'),
                onSort: (i, asc) => _sort((a) => a.name, i, asc),
              ),
              DataColumn(
                label: const Text('Quantity'),
                onSort: (i, asc) => _sort((a) => a.quantity, i, asc),
              ),
              DataColumn(
                label: const Text('Value'),
                onSort: (i, asc) => _sort((a) => a.value, i, asc),
              ),
              DataColumn(
                label: const Text('Uncertainty'),
                onSort: (i, asc) => _sort((a) => a.uncertainty, i, asc),
              ),
              DataColumn(
                label: const Text('Unit'),
                onSort: (i, asc) => _sort((a) => a.unit, i, asc),
              ),
              DataColumn(
                label: const Text('Type'),
                onSort: (i, asc) => _sort((a) => a.type, i, asc),
              ),
            ],
            rows: _filteredAnalytes.map((analyte) {
              final isSelected = _isSelected(analyte);
              return DataRow(
                selected: isSelected,
                onSelectChanged: (_) => _toggleSelection(analyte),
                cells: [
                  DataCell(Text(analyte.name)),
                  DataCell(Text(analyte.quantity)),
                  DataCell(Text(analyte.value)),
                  DataCell(Text(analyte.uncertainty)),
                  DataCell(Text(analyte.unit)),
                  DataCell(Text(analyte.type)),
                ],
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Selected: ${_selectedAnalytes.length} item(s)',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        _selectedAnalytes.isNotEmpty
            ? Wrap(
                spacing: 8,
                runSpacing: 4,
                children: _selectedAnalytes.map((analyte) {
                  return Chip(
                    label: Text(analyte.name),
                    onDeleted: () => _toggleSelection(analyte),
                  );
                }).toList(),
              )
            : const SizedBox.shrink(),
      ],
    );
  }
}
