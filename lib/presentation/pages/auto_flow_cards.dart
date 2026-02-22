import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class AutoFlowCards extends StatelessWidget {
  const AutoFlowCards({super.key});

  @override
  Widget build(BuildContext context) {
    final cardsData = _mockJsonData();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Auto Masonry Dashboard'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: MasonryGridView.extent(
          maxCrossAxisExtent: 300, // 🔥 auto column calculation
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          itemCount: cardsData.length,
          itemBuilder: (context, index) {
            return DynamicCard(data: cardsData[index]);
          },
        ),
      ),
    );
  }
}

/* -------------------------------------------------------
  JSON DATA (5 TYPES)
------------------------------------------------------- */
List<Map<String, dynamic>> _mockJsonData() {
  return [
    {
      "type": "type01",
      "tag": "Type-01",
      "title": "Data Name",
      "value": "000 / Value",
    },
    {
      "type": "type02",
      "tag": "Type-02",
      "items": [
        {"label": "Data Name", "value": "000 / Value"},
        {"label": "Data Name", "value": "000 / Value"},
      ],
    },
    {
      "type": "type03",
      "tag": "Type-03",
      "title": "Card Name",
      "sections": [
        {"label": "Data 01 Name", "value": "000 / Value"},
        {"label": "Data 02 Name", "value": "000 / Value"},
      ],
    },
    {
      "type": "type04",
      "tag": "Type-04",
      "title": "Card Name",
      "rows": [
        {"key": "Data 01 Name", "value": "000 / Value"},
        {"key": "Data 02 Name", "value": "000 / Value"},
        {"key": "Data 03 Name", "value": "000 / Value"},
        {"key": "Data 04 Name", "value": "000 / Value"},
        {"key": "Data 05 Name", "value": "000 / Value"},
      ],
    },
    {
      "type": "type05",
      "tag": "Type-05",
      "columns": [
        {"label": "Data 01 Name", "value": "000 / Value"},
        {"label": "Data 02 Name", "value": "000 / Value"},
      ],
    },
  ];
}

/* -------------------------------------------------------
  DYNAMIC CARD
------------------------------------------------------- */
class DynamicCard extends StatelessWidget {
  final Map<String, dynamic> data;

  const DynamicCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTag(data["tag"]),
            const SizedBox(height: 12),
            _buildContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildTag(String tag) {
    return Align(
      alignment: Alignment.topRight,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(tag, style: const TextStyle(fontSize: 12)),
      ),
    );
  }

  Widget _buildContent() {
    switch (data["type"]) {
      case "type01":
        return _type01(data);
      case "type02":
        return _type02(data["items"]);
      case "type03":
        return _type03(data);
      case "type04":
        return _type04(data);
      case "type05":
        return _type05(data["columns"]);
      default:
        return const SizedBox();
    }
  }

  /* -------------------------------------------------------
    CARD TYPES
  ------------------------------------------------------- */

  Widget _type01(Map data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(data["title"], style: const TextStyle(color: Colors.grey)),
        const SizedBox(height: 8),
        Text(
          data["value"],
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _type02(List items) {
    return Column(
      children: items.map<Widget>((item) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            children: [
              Text(item["label"], style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 4),
              Text(
                item["value"],
                style:
                const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _type03(Map data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          data["title"],
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const Divider(),
        ...data["sections"].map<Widget>((s) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              children: [
                Text(s["label"],
                    style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 4),
                Text(
                  s["value"],
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _type04(Map data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          data["title"],
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...data["rows"].map<Widget>((row) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: Text(row["key"])),
                const Text(" : "),
                Text(
                  row["value"],
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _type05(List columns) {
    return Row(
      children: columns.map<Widget>((col) {
        return Expanded(
          child: Column(
            children: [
              Text(col["label"], style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 6),
              Text(
                col["value"],
                style:
                const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}