import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_typography.dart';

class SubjectPieItem {
  final String name;
  final double hours;
  final Color color;

  const SubjectPieItem({
    required this.name,
    required this.hours,
    required this.color,
  });
}

/// Subject distribution breakdown pie chart.
class SubjectPieChart extends StatelessWidget {
  const SubjectPieChart({
    super.key,
    required this.items,
  });

  final List<SubjectPieItem> items;

  @override
  Widget build(BuildContext context) {
    final totalHours = items.fold<double>(0.0, (acc, item) => acc + item.hours);

    return SizedBox(
      height: 180,
      child: PieChart(
        PieChartData(
          sectionsSpace: 3,
          centerSpaceRadius: 40,
          sections: items.map((item) {
            final percentage = totalHours > 0 ? (item.hours / totalHours * 100).toInt() : 0;
            return PieChartSectionData(
              color: item.color,
              value: item.hours,
              title: '$percentage%',
              radius: 46,
              titleStyle: AppTypography.labelSmall.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
