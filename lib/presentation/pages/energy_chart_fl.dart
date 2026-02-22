import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/models/chart_data_model.dart';

class EnergyChartFl extends StatefulWidget {
  const EnergyChartFl({super.key});

  @override
  State<EnergyChartFl> createState() => _EnergyChartFlState();
}

class _EnergyChartFlState extends State<EnergyChartFl> {
  late List<ChartData> chartData;

  // Zoom & Pan state
  double _minX = 0;
  double _maxX = 24;
  double _lastMinX = 0;
  double _lastMaxX = 24;

  // Visibility state
  bool _showSoc = true;
  bool _showLive = true;
  bool _showGrid = true;

  @override
  void initState() {
    super.initState();
    chartData = _generateData();
  }

  List<ChartData> _generateData() {
    return List.generate(1440, (index) {
      final double hour = index / 60.0;
      // Simulate gaps: e.g., no data for 20 minutes every 4 hours
      if (index % 240 < 20) {
        return ChartData(hour, null, null, null);
      }
      final double soc = 50 + 40 * sin(index * 0.01);
      final double livePower = 500 * cos(index * 0.02) + Random().nextInt(200);
      final double gridPower = 300 * sin(index * 0.03) + Random().nextInt(100);
      return ChartData(hour, soc, livePower, gridPower);
    });
  }

  @override
  Widget build(BuildContext context) {
    // We need distinct instances to compare in the tooltip builder
    // So we construct them fresh each build, but we can assign them to variables during build
    // actually, let's just use methods and reference the result in the list

    // But wait, "touchedSpot.bar == _socBarData" requires reference equality.
    // So we should create them inside build but before the chart.

    _socBarData = _getSocSeries();
    _liveBarData = _getLiveSeries();
    _gridBarData = _getGridSeries();

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            _buildLegend(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(
                  right: 20.0,
                  left: 10.0,
                  top: 20.0,
                  bottom: 10.0,
                ),
                child: GestureDetector(
                  onDoubleTap: () {
                    setState(() {
                      _minX = 0;
                      _maxX = 24;
                    });
                  },
                  onScaleStart: (details) {
                    _lastMinX = _minX;
                    _lastMaxX = _maxX;
                  },
                  onScaleUpdate: (details) {
                    setState(() {
                      // 1. Calculate new range based on zoom
                      final double currentRange = _lastMaxX - _lastMinX;
                      final double newRange = currentRange / details.scale;

                      // 2. Calculate center shift based on pan (focal point delta)
                      // We need to translate pixels to X-axis units.
                      // Approximate width of chart area helps, or just use sensitivity
                      // A safer way for pan is to track the change in focal point normalized to chart width.
                      // But effectively: X axis is 24 units.
                      // Let's rely on simple range scaling around the center first for zoom.

                      // Refined Zoom: Scale around the focal point?
                      // For MVP, center scaling is robust enough.
                      final double center = (_lastMinX + _lastMaxX) / 2;

                      // Pan logic:
                      // If details.scale is 1.0, it's a drag.
                      // We can just subtract the normalized delta.
                      // But combining them is tricky.

                      // Let's do simple center zoom + pan.

                      // Apply Zoom
                      double newMinX = center - (newRange / 2);
                      double newMaxX = center + (newRange / 2);

                      // Apply Pan
                      // details.horizontalScale is for zoom.
                      // details.focalPointDelta.dx is for pan.
                      // sensitivity: -details.focalPointDelta.dx / width * range
                      // We don't know exact width here easily without LayoutBuilder.
                      // Let's assume a sensitivity factor or use a small multiplier.
                      // e.g., 0.05 * newRange

                      if (details.scale == 1.0) {
                        // Approx pan effect
                        double dx = details.focalPointDelta.dx;
                        double shift = dx * -0.01 * (_maxX - _minX);
                        newMinX += shift;
                        newMaxX += shift;

                        // Use previous bounds as base for clean panning?
                        // Actually, setState re-runs, so we are modifying CURRENT _minX.
                        // Standard robust patterns usually use onScaleStart to capture baseline.
                        // But _lastMinX is fixed during gesture.

                        // Let's stick to the Zoom first, Pan is bonus if Zoom works.
                        // But user said "zoom not working".
                      }

                      // Update state
                      _minX = newMinX;
                      _maxX = newMaxX;

                      // Clamp
                      if (_minX < 0) _minX = 0;
                      if (_maxX > 24) _maxX = 24;
                      // Ensure minimum zoom level (e.g. 1 hour)
                      if (_maxX - _minX < 1) {
                        double mid = (_minX + _maxX) / 2;
                        _minX = mid - 0.5;
                        _maxX = mid + 0.5;
                      }
                    });
                  },
                  child: LineChart(
                    LineChartData(
                      clipData: const FlClipData.all(), // Needed for zoom
                      lineTouchData: LineTouchData(
                        getTouchedSpotIndicator: (LineChartBarData barData, List<int> spotIndexes) {
                          return spotIndexes.map((spotIndex) {
                            return TouchedSpotIndicatorData(
                              const FlLine(
                                color: Colors.grey,
                                strokeWidth: 1,
                                dashArray: [5, 5],
                              ),
                              FlDotData(
                                show: true,
                                getDotPainter: (spot, percent, barData, index) {
                                  // Determine color based on series
                                  // We can try to match the gradient logic conceptually
                                  Color color = Colors.black;

                                  // Identify series by checking spots/references or just re-checking value
                                  // But we can check which barData this is by reference if we managed it well
                                  // OR just use the logic:
                                  // SOC: -100 to 100
                                  // Power: normalized.
                                  // But easier: check visibility and order? No, getDotPainter gives barData.

                                  // Re-find the series type based on properties?
                                  // Or simply look at the Y value and guess? No.

                                  // Usage of gradient colors:
                                  // SOC/Live/Grid all use Red/Orange, Purple/Blue, Pink/Green split at 0.
                                  if (barData == _socBarData) {
                                    color = spot.y < 0
                                        ? Colors.red
                                        : Colors.orange;
                                  } else if (barData == _liveBarData) {
                                    color = spot.y < 0
                                        ? Colors.purple
                                        : Colors.blue;
                                  } else if (barData == _gridBarData) {
                                    color = spot.y < 0
                                        ? Colors.pink
                                        : Colors.green;
                                  }

                                  return FlDotCirclePainter(
                                    radius: 4,
                                    color: color,
                                    strokeWidth: 2,
                                    strokeColor: Colors.white,
                                  );
                                },
                              ),
                            );
                          }).toList();
                        },
                        touchTooltipData: LineTouchTooltipData(
                          getTooltipItems: (touchedSpots) {
                            // Correctly map barIndex to Series Type
                            // "lineBarsData" determines the index.
                            // We construct lineBarsData dynamically: [if soc, if live, if grid]

                            List<String> visibleSeries = [];
                            if (_showSoc) visibleSeries.add('SOC');
                            if (_showLive) visibleSeries.add('Live');
                            if (_showGrid) visibleSeries.add('Grid');

                            return touchedSpots.map((LineBarSpot touchedSpot) {
                              // touchedSpot.barIndex reflects the index in the filtered list
                              if (touchedSpot.barIndex >= visibleSeries.length)
                                return null;

                              String seriesName =
                                  visibleSeries[touchedSpot.barIndex];

                              // Find Data by X (Hour)
                              final x = touchedSpot.x;
                              final data = chartData.firstWhere(
                                (element) => (element.hour - x).abs() < 0.001,
                                orElse: () => chartData[0], // Fallback
                              );

                              String text = '';
                              Color color = Colors.black;

                              if (seriesName == 'SOC') {
                                text = 'SOC: ${data.soc?.toStringAsFixed(1)}%';
                                color = (data.soc ?? 0) < 0
                                    ? Colors.red
                                    : Colors.orange;
                              } else if (seriesName == 'Live') {
                                text =
                                    'Live: ${data.livePower?.toStringAsFixed(0)} W';
                                color = (data.livePower ?? 0) < 0
                                    ? Colors.purple
                                    : Colors.blue;
                              } else if (seriesName == 'Grid') {
                                text =
                                    'Grid: ${data.gridPower?.toStringAsFixed(0)} W';
                                color = (data.gridPower ?? 0) < 0
                                    ? Colors.pink
                                    : Colors.green;
                              }

                              return LineTooltipItem(
                                text,
                                TextStyle(
                                  color: color,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            }).toList();
                          },
                        ),
                        handleBuiltInTouches: true,
                      ),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 30,
                            // Dynamic interval logic
                            interval: (_maxX - _minX) > 12
                                ? 6
                                : ((_maxX - _minX) > 6 ? 2 : 1),
                            getTitlesWidget: (value, meta) {
                              if (value < 0 || value > 24)
                                return const SizedBox.shrink();
                              int hour = value.floor();
                              int minute = ((value - hour) * 60).round();
                              return Text(
                                '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}',
                                style: const TextStyle(fontSize: 10),
                              );
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: 20,
                            reservedSize: 40,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                '${value.toInt()}%',
                                style: const TextStyle(fontSize: 10),
                              );
                            },
                          ),
                        ),
                        rightTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: 20,
                            reservedSize: 40,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                '${(value * 10).toInt()}',
                                style: const TextStyle(fontSize: 10),
                              );
                            },
                          ),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      minX: _minX,
                      maxX: _maxX,
                      minY: -100,
                      maxY: 100,
                      gridData: const FlGridData(
                        show: true,
                        drawVerticalLine: false,
                      ),
                      borderData: FlBorderData(show: true),
                      lineBarsData: [
                        if (_showSoc) _socBarData,
                        if (_showLive) _liveBarData,
                        if (_showGrid) _gridBarData,
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _legendItem(
            'SOC',
            Colors.orange,
            _showSoc,
            (v) => setState(() => _showSoc = v),
          ),
          const SizedBox(width: 10),
          _legendItem(
            'Live Power',
            Colors.blue,
            _showLive,
            (v) => setState(() => _showLive = v),
          ),
          const SizedBox(width: 10),
          _legendItem(
            'Grid Power',
            Colors.green,
            _showGrid,
            (v) => setState(() => _showGrid = v),
          ),
        ],
      ),
    );
  }

  Widget _legendItem(
    String text,
    Color color,
    bool isVisible,
    Function(bool) onChanged,
  ) {
    return InkWell(
      onTap: () => onChanged(!isVisible),
      child: Row(
        children: [
          Icon(
            isVisible ? Icons.check_box : Icons.check_box_outline_blank,
            color: color,
            size: 20,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(color: isVisible ? Colors.black : Colors.grey),
          ),
        ],
      ),
    );
  }

  // Bar Data instances for equality checks
  late LineChartBarData _socBarData;
  late LineChartBarData _liveBarData;
  late LineChartBarData _gridBarData;

  LineChartBarData _getSocSeries() {
    return LineChartBarData(
      spots: chartData.map((e) {
        if (e.soc == null) return FlSpot.nullSpot;
        return FlSpot(e.hour, e.soc!);
      }).toList(),
      isCurved: true,
      barWidth: 2,
      dotData: const FlDotData(show: false),
      gradient: const LinearGradient(
        colors: [Colors.red, Colors.red, Colors.orange, Colors.orange],
        stops: [0.0, 0.5, 0.5, 1.0],
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
      ),
    );
  }

  LineChartBarData _getLiveSeries() {
    return LineChartBarData(
      spots: chartData.map((e) {
        if (e.livePower == null) return FlSpot.nullSpot;
        return FlSpot(e.hour, e.livePower! / 10);
      }).toList(),
      isCurved: true,
      barWidth: 2,
      dotData: const FlDotData(show: false),
      gradient: const LinearGradient(
        colors: [Colors.purple, Colors.purple, Colors.blue, Colors.blue],
        stops: [0.0, 0.5, 0.5, 1.0],
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
      ),
    );
  }

  LineChartBarData _getGridSeries() {
    return LineChartBarData(
      spots: chartData.map((e) {
        if (e.gridPower == null) return FlSpot.nullSpot;
        return FlSpot(e.hour, e.gridPower! / 10);
      }).toList(),
      isCurved: true,
      barWidth: 2,
      dotData: const FlDotData(show: false),
      gradient: const LinearGradient(
        colors: [Colors.pink, Colors.pink, Colors.green, Colors.green],
        stops: [0.0, 0.5, 0.5, 1.0],
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
      ),
    );
  }
}
