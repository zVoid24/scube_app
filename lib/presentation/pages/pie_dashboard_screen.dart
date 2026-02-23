import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class PieDashboardScreen extends StatelessWidget {
  const PieDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final charts = mockPieChartData();

    final small = charts.where((e) => e["size"] == "small").toList();
    final big = charts.where((e) => e["size"] == "big").toList();

    return Scaffold(
      appBar: AppBar(title: const Text("Pie Chart Dashboard")),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                /// 🔹 SMALL PIE CHARTS (auto columns, NO scroll)
                MasonryGridView.extent(
                  maxCrossAxisExtent: 380,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: small.length,
                  itemBuilder: (context, index) {
                    return PieChartCard(data: small[index]);
                  },
                ),

                const SizedBox(height: 16),

                /// 🔹 BIG PIE CHARTS (full width)
                ...big.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: PieChartCard(data: item),
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

/* -------------------------------------------------------
  MOCK DATA
------------------------------------------------------- */
List<Map<String, dynamic>> mockPieChartData() {
  return [
    {"type": "pie", "size": "small", "tag": "Type-01", "title": "Chart Name"},
    {"type": "pie", "size": "small", "tag": "Type-04", "title": "Chart Name"},
    {"type": "pie", "size": "big", "tag": "Type-02", "title": "Chart Name"},
    {"type": "pie", "size": "big", "tag": "Type-03", "title": "Chart Name"},
    {"type": "pie", "size": "small", "tag": "Type-05", "title": "Chart Name"},
    {"type": "pie", "size": "small", "tag": "Type-06", "title": "Chart Name"},
  ];
}

/* -------------------------------------------------------
  PIE CHART CARD
------------------------------------------------------- */
class PieChartCard extends StatelessWidget {
  final Map<String, dynamic> data;

  const PieChartCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final bool isBig = data["size"] == "big";

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
            Center(child: _buildPiePlaceholder(isBig)),
            if (isBig) ...[
              const SizedBox(height: 16),
              const Center(
                child: Text(
                  "Total\n35955.44 ৳",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTag(String tag) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(tag, style: const TextStyle(fontSize: 12)),
    );
  }

  Widget _buildPiePlaceholder(bool isBig) {
    return Container(
      height: isBig ? 260 : 180,
      width: isBig ? 260 : 180,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey.shade100,
        border: Border.all(color: Colors.grey.shade300),
      ),
      alignment: Alignment.center,
      child: Text(
        isBig ? "BIG PIE\n(CHART)" : "SMALL\nPIE",
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.grey),
      ),
    );
  }
}
