import 'package:flutter/material.dart';
import 'package:flutter_application_1/presentation/widgets/bess_load_chart.dart';
import 'package:flutter_application_1/presentation/widgets/chart_card.dart';
import 'package:flutter_application_1/presentation/widgets/data_filter_bar.dart';
import 'package:flutter_application_1/presentation/widgets/diseal_load_chart.dart';
import 'package:flutter_application_1/presentation/widgets/monthly_power_cut_chart.dart';
import 'package:flutter_application_1/presentation/widgets/total_load_time_duration.dart';

class PowerCutScreen extends StatelessWidget {
  const PowerCutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: const Text('Power Cut Analytics'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: const Color(0xFF1E88E5),
      ),
      body: SingleChildScrollView(
        //padding: const EdgeInsets.all(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            children: [
              const DateFilterBar(),
              const SizedBox(height: 16),

              const ChartCard(
                title: 'Monthly Power Cuts & Avg Duration (min)',
                child: MonthlyPowerCutChart(),
              ),
              const SizedBox(height: 16),

              ChartCard(
                title: 'BESS Load Time Duration (min)',
                child: BessLoadChart(),
              ),
              const SizedBox(height: 16),

              const ChartCard(
                title: 'Diesel Generator Load Time Duration (min)',
                child: DieselLoadChart(),
              ),
              const SizedBox(height: 16),

              const ChartCard(
                title: 'Total Load Time Duration',
                child: LoadTimeDuration(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
