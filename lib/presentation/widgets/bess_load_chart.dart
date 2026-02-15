import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class BessLoadChart extends StatelessWidget {
  BessLoadChart({super.key});

  @override
  Widget build(BuildContext context) {
    final labels = [
      '1-100',
      '101-200',
      '201-300',
      '301-400',
      '401-500',
      '501-600',
      '601-700',
    ];
    return BarChart(
      BarChartData(
        maxY: 60,
        minY: 0,

        alignment: BarChartAlignment.spaceBetween,
        groupsSpace: 12,
        barTouchData: BarTouchData(
          enabled: true,
          handleBuiltInTouches: true,
          touchTooltipData: BarTouchTooltipData(
            //tooltipRoundedRadius: 10,
            tooltipBorderRadius: BorderRadius.all(Radius.circular(10)),
            tooltipPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 10,
            ),
            tooltipMargin: 12,
            tooltipHorizontalAlignment: FLHorizontalAlignment.center,
            //tooltipVerticalAlignment: FLVerticalAlignment.top,
            fitInsideHorizontally: true,
            fitInsideVertically: true,
            getTooltipColor: (_) => const Color(0xFF2B2B2B),
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '',
                const TextStyle(),
                children: [
                  // 🔹 Header
                  TextSpan(
                    text: '${labels[group.x.toInt()]} kW\n',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  TextSpan(
                    text: '● ',
                    style: TextStyle(
                      color: rod.color ?? Colors.white,
                      fontSize: 14,
                    ),
                  ),
                  const TextSpan(
                    text: 'Time: ',
                    style: TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                  TextSpan(
                    text: "${rod.toY.toInt()} min",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              );
            },
          ),
        ),

        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          //verticalInterval: 3,
          horizontalInterval: 3,
          getDrawingHorizontalLine: (_) =>
              FlLine(color: const Color(0xFFEDEDED), strokeWidth: 1),
          // getDrawingVerticalLine: (_) =>
          //     FlLine(color: const Color(0xFFEDEDED), strokeWidth: 1),
        ),

        borderData: FlBorderData(
          show: true,
          border: Border(
            left: BorderSide(color: Colors.grey.shade400),
            bottom: BorderSide(color: Colors.grey.shade400),
          ),
        ),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),

          leftTitles: AxisTitles(
            axisNameWidget: const Padding(
              padding: EdgeInsets.only(bottom: 1),
              child: Text('Time (Minute)', style: TextStyle(fontSize: 11)),
            ),
            axisNameSize: 25,
            sideTitles: SideTitles(
              showTitles: true,
              interval: 5,
              reservedSize: 22,
              getTitlesWidget: (value, _) => Text(
                value.toInt().toString(),
                style: const TextStyle(fontSize: 10),
              ),
            ),
          ),

          bottomTitles: AxisTitles(
            axisNameWidget: const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text('Total Load (kW)', style: TextStyle(fontSize: 11)),
            ),
            axisNameSize: 26,
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 42,
              getTitlesWidget: (value, _) {
                return SizedBox(
                  width: 47, // 35 (bar) + 12 (group space)
                  child: Center(
                    child: Transform.rotate(
                      angle: -1.3,
                      alignment: Alignment.center,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          labels[value.toInt()],
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 10),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        barGroups: [
          _group(0, 57, const Color(0xFF5DA9F6)),
          _group(1, 28, const Color(0xFF5DA9F6)),
          _group(2, 44, const Color(0xFF5DA9F6)),
          _group(3, 22, const Color(0xFF5DA9F6)),
          _group(4, 53, const Color(0xFF5DA9F6)),
          _group(5, 46, const Color(0xFF5DA9F6)),
          _group(5, 36, const Color(0xFF5DA9F6)),
        ],
      ),
    );
  }

  BarChartGroupData _group(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barsSpace: 0,
      barRods: [
        BarChartRodData(
          toY: y,
          width: 35,
          color: color,
          borderRadius: BorderRadius.zero,
        ),
      ],
      //showingTooltipIndicators: [0],
    );
  }
}
