import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/models/chart_data_model.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class EnergyChart extends StatelessWidget {
  const EnergyChart({super.key});

  @override
  Widget build(BuildContext context) {
    // Generate dense data for 24 hours (1440 minutes)
    final List<ChartData> chartData = List.generate(1440, (index) {
      final double hour = index / 60.0;

      // Simulate gaps: e.g., no data for 20 minutes every 4 hours
      if (index % 240 < 20) {
        return ChartData(hour, null, null, null);
      }

      // Generate random-ish data
      final double soc = 50 + 40 * sin(index * 0.01);
      final double livePower = 500 * cos(index * 0.02) + Random().nextInt(200);
      final double gridPower = 300 * sin(index * 0.03) + Random().nextInt(100);

      return ChartData(hour, soc, livePower, gridPower);
    });

    final ZoomPanBehavior zoomPanBehavior = ZoomPanBehavior(
      enablePinching: true,
      enablePanning: true,
      enableDoubleTapZooming: true,
      zoomMode: ZoomMode.x, // Zoom primarily on X axis for time
    );

    return SafeArea(
      child: Scaffold(
        body: SfCartesianChart(
          zoomPanBehavior: zoomPanBehavior,
          backgroundColor: Colors.white,

          /// 🟢 Legend click toggles series automatically
          legend: Legend(
            isVisible: true,
            position: LegendPosition.top,
            toggleSeriesVisibility: true,
          ),

          /// ✋ Trackball
          // onTrackballPositionChanging: (TrackballArgs args) {
          //   final dynamic info = args.chartPointInfo;
          //   final List<dynamic> points = (info is List) ? info : [info];

          //   for (final pointInfo in points) {
          //     final num? yValue = pointInfo.chartPoint.y;
          //     if (yValue == null) continue;

          //     switch (pointInfo.seriesIndex) {
          //       case 0: // SOC
          //         pointInfo.color = yValue < 0 ? Colors.red : Colors.orange;
          //         break;

          //       case 1: // Live Power
          //         pointInfo.color = yValue < 0 ? Colors.purple : Colors.blue;
          //         break;

          //       case 2: // Grid Power
          //         pointInfo.color = yValue < 0 ? Colors.pink : Colors.green;
          //         break;
          //     }
          //   }
          // },
          trackballBehavior: TrackballBehavior(
            enable: true,
            activationMode: ActivationMode.singleTap,
            tooltipDisplayMode: TrackballDisplayMode.groupAllPoints,
            tooltipSettings: const InteractiveTooltip(
              enable: true,
              format: 'point.x : point.y',
            ),
          ),

          /// ⏰ X Axis (00.00 → 24.00)
          primaryXAxis: NumericAxis(
            minimum: 0,
            maximum: 24,
            interval: 6,
            labelFormat: '{value}.00',
            title: AxisTitle(text: 'Time (Hours)'),
          ),

          /// 🔋 Left Y Axis (SOC %)
          primaryYAxis: NumericAxis(
            minimum: -100,
            maximum: 100,
            interval: 20,
            labelFormat: '{value}%',
            title: AxisTitle(text: 'SOC'),
          ),

          /// ⚡ Right Y Axis (Power)
          axes: <ChartAxis>[
            NumericAxis(
              name: 'powerAxis',
              opposedPosition: true,
              minimum: -1000,
              maximum: 1000,
              interval: 200,
              title: AxisTitle(text: 'Power (W)'),
            ),
          ],

          series: <CartesianSeries>[
            /// 🟡 SOC (Positive / Negative color)
            LineSeries<ChartData, double>(
              name: 'SOC',
              dataSource: chartData,
              xValueMapper: (d, _) => d.hour,
              yValueMapper: (d, _) => d.soc,
              pointColorMapper: (d, _) =>
                  (d.soc ?? 0) < 0 ? Colors.red : Colors.orange,
              width: 2,
              // onCreateShader: (ShaderDetails details) {
              //   return ui.Gradient.linear(
              //     details.rect.bottomCenter,
              //     details.rect.topCenter,
              //     const <Color>[
              //       Colors.red,
              //       Colors.red,
              //       Colors.orange,
              //       Colors.orange,
              //     ],
              //     const <double>[0.0, 0.5, 0.5, 1.0],
              //   );
              // },
              markerSettings: const MarkerSettings(isVisible: false),
              emptyPointSettings: EmptyPointSettings(mode: EmptyPointMode.gap),
            ),

            /// 🔵 Live Power
            LineSeries<ChartData, double>(
              name: 'Live Power',
              dataSource: chartData,
              xValueMapper: (d, _) => d.hour,
              yValueMapper: (d, _) => d.livePower,
              pointColorMapper: (d, _) =>
                  (d.livePower ?? 0) < 0 ? Colors.purple : Colors.blue,
              yAxisName: 'powerAxis',
              width: 2,
              // onCreateShader: (ShaderDetails details) {
              //   return ui.Gradient.linear(
              //     details.rect.bottomCenter,
              //     details.rect.topCenter,
              //     const <Color>[
              //       Colors.purple,
              //       Colors.purple,
              //       Colors.blue,
              //       Colors.blue,
              //     ],
              //     const <double>[0.0, 0.5, 0.5, 1.0],
              //   );
              // },
              markerSettings: const MarkerSettings(isVisible: false),
              emptyPointSettings: EmptyPointSettings(mode: EmptyPointMode.gap),
            ),

            /// 🟢 Grid Power (3rd parameter)
            LineSeries<ChartData, double>(
              name: 'Grid Power',
              dataSource: chartData,
              xValueMapper: (d, _) => d.hour,
              yValueMapper: (d, _) => d.gridPower,
              pointColorMapper: (d, _) =>
                  (d.gridPower ?? 0) < 0 ? Colors.pink : Colors.green,
              yAxisName: 'powerAxis',
              width: 2,
              // onCreateShader: (ShaderDetails details) {
              //   return ui.Gradient.linear(
              //     details.rect.bottomCenter,
              //     details.rect.topCenter,
              //     const <Color>[
              //       Colors.pink,
              //       Colors.pink,
              //       Colors.green,
              //       Colors.green,
              //     ],
              //     const <double>[0.0, 0.5, 0.5, 1.0],
              //   );
              // },
              markerSettings: const MarkerSettings(isVisible: false),
              emptyPointSettings: EmptyPointSettings(mode: EmptyPointMode.gap),
            ),
          ],
        ),
      ),
    );
  }
}
