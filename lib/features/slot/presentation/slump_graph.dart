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
      return SizedBox(
        height: height,
        child: LineChart(
          LineChartData(
            minY: -300,
            maxY: 300,
            minX: 0,
            maxX: 1000,
            gridData: FlGridData(show: true),
            titlesData: const FlTitlesData(show: false),
            borderData: FlBorderData(show: true),
            lineBarsData: [], // データなしでも枠だけ表示
          ),
        ),
      );
    }

    return SizedBox(
      height: height,
      child: LineChart(
        LineChartData(
          minY: -300,
          maxY: 300,
          minX: 0,
          maxX: 1000,
          gridData: FlGridData(
            show: true,
            drawHorizontalLine: true,
            horizontalInterval: 100,
            getDrawingHorizontalLine: (value) {
              if (value == 0) {
                return FlLine(color: Colors.redAccent, strokeWidth: 2);
              }
              return FlLine(color: Colors.grey.withOpacity(0.3), strokeWidth: 1);
            },
          ),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: true),
          lineBarsData: [
            LineChartBarData(
              spots: points
                  .map((p) => FlSpot(p.gameIndex.toDouble(), p.difference.toDouble()))
                  .toList(),
              isCurved: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(show: true,
                gradient: LinearGradient(
                  colors: [Colors.indigoAccent.withOpacity(0.25), Colors.transparent],
                  begin: Alignment.topCenter, end: Alignment.bottomCenter,
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
