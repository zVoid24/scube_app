import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class DieselLoadChart extends StatelessWidget {
  const DieselLoadChart({super.key});

  @override
  Widget build(BuildContext context) {
    // 🔹 Dynamic data (can come from API later)
    final List<double> values = [57, 28, 44, 22, 53, 46, 36, 53, 46, 36];

    final List<String> labels = List.generate(
      values.length,
      (i) => '${i * 100 + 1}-${(i + 1) * 100}',
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        const minSpacing = 8.0;
        const minBarWidth = 12.0;
        const maxBarWidth = 35.0;

        final barCount = values.length;
        final totalSpacing = minSpacing * (barCount - 1);
        final availableWidth = constraints.maxWidth - totalSpacing;

        final barWidth = (availableWidth / barCount).clamp(
          minBarWidth,
          maxBarWidth,
        );

        return BarChart(
          BarChartData(
            maxY: 60,
            minY: 0,
            alignment: BarChartAlignment.spaceBetween,
            groupsSpace: minSpacing,

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

                      // 🔹 Colored dot + label + value
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
              horizontalInterval: 5,
              getDrawingHorizontalLine: (_) =>
                  const FlLine(color: Color(0xFFEDEDED), strokeWidth: 1),
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
                axisNameWidget: const Text(
                  'Time (Minute)',
                  style: TextStyle(fontSize: 11),
                ),
                axisNameSize: 28,
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 5,
                  reservedSize: 26,
                  getTitlesWidget: (value, _) => Text(
                    value.toInt().toString(),
                    style: const TextStyle(fontSize: 10),
                  ),
                ),
              ),

              bottomTitles: AxisTitles(
                axisNameWidget: const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text(
                    'Total Load (kW)',
                    style: TextStyle(fontSize: 11),
                  ),
                ),
                axisNameSize: 30,
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 48,
                  getTitlesWidget: (value, _) {
                    final index = value.toInt();
                    if (index < 0 || index >= labels.length) {
                      return const SizedBox.shrink();
                    }

                    return SizedBox(
                      width: barWidth + minSpacing,
                      child: Center(
                        child: Transform.rotate(
                          angle: -math.pi / 3, // ≈ -60°
                          child: Text(
                            labels[index],
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 10),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            barGroups: List.generate(
              values.length,
              (i) => BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: values[i],
                    width: barWidth,
                    color: const Color(0xFFFFA726),
                    borderRadius: BorderRadius.zero,
                  ),
                ],
                //showingTooltipIndicators: const [0],
              ),
            ),
          ),
        );
      },
    );
  }
}
