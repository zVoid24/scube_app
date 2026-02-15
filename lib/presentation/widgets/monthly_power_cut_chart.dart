import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class MonthlyPowerCutChart extends StatelessWidget {
  const MonthlyPowerCutChart({super.key});

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        maxY: 15,
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
              final labels = [
                '1–10 min',
                '11–30 min',
                '31–60 min',
                '1–2 hrs',
                '2–3 hrs',
                '3+ hrs',
              ];

              return BarTooltipItem(
                '',
                const TextStyle(),
                children: [
                  // 🔹 Header
                  TextSpan(
                    text: '${labels[group.x.toInt()]}\n',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  // 🔹 Colored dot + label + value
                  TextSpan(
                    text: '● ',
                    style: TextStyle(
                      color: rod.color ?? Colors.white,
                      fontSize: 14,
                    ),
                  ),
                  const TextSpan(
                    text: 'Power Cut: ',
                    style: TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                  TextSpan(
                    text: rod.toY.toInt().toString(),
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

        // 🔹 GRID
        gridData: FlGridData(
          show: true,
          horizontalInterval: 3,
          getDrawingHorizontalLine: (_) =>
              const FlLine(color: Color(0xFFEDEDED), strokeWidth: 1),
          getDrawingVerticalLine: (_) =>
              const FlLine(color: Color(0xFFEDEDED), strokeWidth: 1),
        ),

        // 🔹 BORDER
        borderData: FlBorderData(
          show: true,
          border: Border(
            left: BorderSide(color: Colors.grey.shade400),
            bottom: BorderSide(color: Colors.grey.shade400),
          ),
        ),

        // 🔹 AXES
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),

          leftTitles: AxisTitles(
            axisNameWidget: const Text(
              'Power Cut (Qty.)',
              style: TextStyle(fontSize: 11),
            ),
            axisNameSize: 28,

            //sideTitleAlignment: SideTitleAlignment.outside,
            // sideTitles: SideTitles(
            //   showTitles: false,
            //   interval: 3,
            //   reservedSize: 32,
            //   getTitlesWidget: (value, _) => Text(
            //     value.toInt().toString(),
            //     style: const TextStyle(fontSize: 10),
            //   ),
            // ),
          ),

          bottomTitles: AxisTitles(
            axisNameWidget: const Padding(
              padding: EdgeInsets.only(top: 6),
              child: Text('Total Load (kW)', style: TextStyle(fontSize: 11)),
            ),
            axisNameSize: 26,
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 38,
              getTitlesWidget: (value, _) {
                const labels = [
                  '1-10\n(min)',
                  '11-30\n(min)',
                  '31-60\n(min)',
                  '1-2\n(hrs)',
                  '2-3\n(hrs)',
                  '3-more\n(hrs)',
                ];
                return Text(
                  labels[value.toInt()],
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
        ),

        // 🔹 BARS
        barGroups: [
          _group(0, 7, const Color(0xFFFFA726)),
          _group(1, 13, const Color(0xFF9C6ADE)),
          _group(2, 6, const Color(0xFF2EC7C9)),
          _group(3, 14, const Color(0xFF5DA9F6)),
          _group(4, 4, const Color(0xFF2ECC71)),
          _group(5, 2, const Color(0xFFB87333)),
        ],
      ),
    );
  }

  static BarChartGroupData _group(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          width: 35,
          color: color,
          borderRadius: BorderRadius.zero,
        ),
      ],
    );
  }
}
