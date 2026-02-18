import 'package:flutter/material.dart';

class EnergyReportExactScreen extends StatelessWidget {
  EnergyReportExactScreen({super.key});

  final double rowHeight = 34;
  final ScrollController vertical = ScrollController();
  final ScrollController horizontal = ScrollController();

  final List<Map<String, dynamic>> data = List.generate(8, (_) {
    return {
      'date': '01 Dec 24',
      'kwh': ['2000', '2000', '2000'],
      'tk': ['2598257/10.2', '2598257/10.2', '2598257/10.2'],
    };
  });
  Color tableBlue = Color(0xFFEEF3FF); // main zebra blue
  Color tableWhite = Colors.white; // white column
  Color totalBlue = Color(0xFFE3EBFF); // total row

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FF),
      appBar: AppBar(
        title: const Text('Energy Report'),
        backgroundColor: const Color(0xFF5E6C8A),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.black26),
            ),
            child: Row(children: [_fixedPart(), _scrollablePart()]),
          ),
        ),
      ),
    );
  }

  // ================= FIXED PART =================
  Widget _edgeShadow() {
    return IgnorePointer(
      child: Container(
        width: 10,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              Colors.black.withOpacity(0.18),
              Colors.black.withOpacity(0.0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _fixedPart() {
    return SizedBox(
      width: 140,
      child: Column(
        children: [
          _fixedHeader(),
          Expanded(
            child: ListView.builder(
              controller: vertical,
              itemCount: data.length + 1,
              itemBuilder: (_, index) {
                if (index == data.length) return _fixedTotal();
                return _fixedGroup(data[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _fixedHeader() {
    return Row(
      children: [
        _headerCell(
          'Date',
          70,
          radius: const BorderRadius.only(topLeft: Radius.circular(15)),
        ),
        _headerCell('Unit', 70),
      ],
    );
  }

  Widget _fixedGroup(Map<String, dynamic> row) {
    return Row(
      children: [
        // Date (NO COLOR)
        Container(
          width: 70,
          height: rowHeight * 2,
          alignment: Alignment.center,
          decoration: _cellDecoration(),
          child: Text(row['date'], textAlign: TextAlign.center),
        ),

        Column(
          children: [_cell('kWh', isTkRow: false), _cell('৳', isTkRow: true)],
        ),
      ],
    );
  }

  Widget _fixedTotal() {
    return Row(
      children: [
        Container(
          width: 70,
          height: rowHeight * 2,
          alignment: Alignment.center,
          decoration: _cellDecoration(isBold: true).copyWith(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(15),
            ),
          ),
          child: const Text(
            'Total',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),

        Column(
          children: [
            _cell('kWh', isBold: true),
            _cell(
              '৳',
              isBold: true,
              //radius: const BorderRadius.only(bottomLeft: Radius.circular(15)),
            ),
          ],
        ),
      ],
    );
  }

  // ================= SCROLLABLE PART =================

  Widget _scrollablePart() {
    return Expanded(
      child: SingleChildScrollView(
        controller: horizontal,
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: 600,
          child: Column(
            children: [
              _scrollHeader(),
              Expanded(
                child: ListView.builder(
                  controller: vertical,
                  itemCount: data.length + 1,
                  itemBuilder: (_, index) {
                    if (index == data.length) return _scrollTotal();
                    return _scrollGroup(data[index]);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _scrollHeader() {
    return Row(
      children: const [
        _HeaderCell('Total Energy\n& Cost'),
        _HeaderCell('REB Energy\n& Cost'),
        _HeaderCell('Solar Energy\n& Cost', isLast: true),
      ],
    );
  }

  Widget _scrollGroup(Map<String, dynamic> row) {
    final List<String> kwh = List<String>.from(row['kwh']);
    final List<String> tk = List<String>.from(row['tk']);

    return Column(
      children: [
        // kWh row → WHITE
        Row(
          children: kwh
              .map((v) => _cell(v, width: 200, isTkRow: false))
              .toList(),
        ),

        // ৳ row → BLUE
        Row(
          children: tk.map((v) => _cell(v, width: 200, isTkRow: true)).toList(),
        ),
      ],
    );
  }

  Widget _scrollTotal() {
    return Column(
      children: [
        Row(
          children: [
            '9687568.22',
            '9687568.22',
            '9687568.22',
          ].map((v) => _cell(v, width: 200, isBold: true)).toList(),
        ),
        Row(
          children: ['9289756.56', '9289756.56', '9289756.56']
              .asMap()
              .entries
              .map(
                (e) => _cell(
                  e.value,
                  width: 200,
                  isBold: true,
                  radius: e.key == 2
                      ? const BorderRadius.only(
                          bottomRight: Radius.circular(15),
                        )
                      : null,
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  // ================= CELLS =================

  Widget _headerCell(String text, double width, {BorderRadius? radius}) {
    return Container(
      width: width,
      height: 42,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFF5E6C8A),
        border: Border.all(color: Colors.black26),
        borderRadius: radius,
      ),
      child: Text(text, style: const TextStyle(color: Colors.white)),
    );
  }

  Widget _cell(
    String text, {
    double width = 70,
    bool isBold = false,
    bool isTkRow = false,
    BorderRadius? radius,
  }) {
    return Container(
      width: width,
      height: rowHeight,
      alignment: Alignment.center,
      decoration: _cellDecoration(
        isBold: isBold,
        backgroundColor: _rowTypeColor(isTkRow: isTkRow, isBold: isBold),
      ).copyWith(borderRadius: radius),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  BoxDecoration _cellDecoration({bool isBold = false, Color? backgroundColor}) {
    return BoxDecoration(
      color: backgroundColor ?? const Color(0xFFEFF3FF),
      border: Border.all(color: isBold ? Colors.black54 : Colors.black26),
    );
  }
}

Color _columnColor(int columnIndex, {bool isBold = false}) {
  if (isBold) {
    return const Color(0xFFE3EBFF); // Total row background
  }

  // Column-based zebra (Unit + scrollable)
  return columnIndex.isEven
      ? const Color.fromARGB(255, 217, 225, 243) // light blue
      : Colors.white;
}

Color _rowTypeColor({required bool isTkRow, bool isBold = false}) {
  if (isBold) return const Color.fromARGB(255, 187, 212, 231);
  return isTkRow ? const Color(0xFFE0E1FF) : const Color(0xFFF2F3FF);
}

// ================= HEADER CELL =================

class _HeaderCell extends StatelessWidget {
  final String title;
  final bool isLast;

  const _HeaderCell(this.title, {this.isLast = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      height: 42,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFF5E6C8A),
        border: Border.all(color: Colors.black26),
        borderRadius: isLast
            ? const BorderRadius.only(topRight: Radius.circular(15))
            : null,
      ),
      child: Text(
        title,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.white),
      ),
    );
  }
}
