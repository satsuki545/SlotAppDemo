import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:slot_app/providers/slot_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SlumpGraph extends ConsumerWidget {
  final double height;
  const SlumpGraph({super.key, this.height = 220});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(slotProvider.notifier);
    final points = controller.points;
    if (points.isEmpty) {
      return const SizedBox(height: 120, child: Center(child: Text('データなし')));
    }

    return SizedBox(
      height: height,
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: true),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: true),
          lineBarsData: [
            LineChartBarData(
              spots: points
                  .map(
                    (p) =>
                        FlSpot(p.gameIndex.toDouble(), p.difference.toDouble()),
                  )
                  .toList(),
              isCurved: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    Colors.indigoAccent.withOpacity(0.25),
                    Colors.transparent,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              color: Colors.indigo,
              barWidth: 2,
            ),
          ],
        ),
      ),
    );
  }
}
