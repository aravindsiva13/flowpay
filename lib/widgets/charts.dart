import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/dashboard_model.dart';
import '../core/constants.dart';
import '../core/utils.dart';

// Department distribution pie chart
class DepartmentChart extends StatelessWidget {
  final List<ChartData> data;

  const DepartmentChart({
    Key? key,
    required this.data,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(child: Text('No data available'));
    }

    return AspectRatio(
      aspectRatio: 1.3,
      child: PieChart(
        PieChartData(
          pieTouchData: PieTouchData(
            touchCallback: (FlTouchEvent event, pieTouchResponse) {
              // Handle touch events if needed
            },
          ),
          borderData: FlBorderData(show: false),
          sectionsSpace: 2,
          centerSpaceRadius: 40,
          sections: _buildSections(),
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildSections() {
    final total = data.fold<double>(0, (sum, item) => sum + item.value);
    
    return data.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      final percentage = (item.value / total * 100);
      
      return PieChartSectionData(
        color: AppColors.chartColors[index % AppColors.chartColors.length],
        value: item.value,
        title: '${percentage.toStringAsFixed(1)}%',
        radius: 50,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }
}

// Monthly expense line chart
class MonthlyExpenseChart extends StatelessWidget {
  final List<ChartData> data;

  const MonthlyExpenseChart({
    Key? key,
    required this.data,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(child: Text('No data available'));
    }

    return AspectRatio(
      aspectRatio: 1.7,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: true,
            horizontalInterval: 1,
            verticalInterval: 1,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: AppColors.borderLight,
                strokeWidth: 1,
              );
            },
            getDrawingVerticalLine: (value) {
              return FlLine(
                color: AppColors.borderLight,
                strokeWidth: 1,
              );
            },
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: 1,
                getTitlesWidget: (double value, TitleMeta meta) {
                  final index = value.toInt();
                  if (index >= 0 && index < data.length) {
                    return SideTitleWidget(
                      axisSide: meta.axisSide,
                      child: Text(
                        data[index].label,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    );
                  }
                  return Container();
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                getTitlesWidget: (double value, TitleMeta meta) {
                  return Container(
                    margin: const EdgeInsets.only(right: 8),
                    child: Text(
                      AppUtils.formatCurrency(value),
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  );
                },
                reservedSize: 50,
              ),
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: AppColors.borderLight, width: 1),
          ),
          minX: 0,
          maxX: data.length - 1.0,
          minY: 0,
          maxY: _getMaxValue() * 1.2,
          lineBarsData: [
            LineChartBarData(
              spots: data.asMap().entries.map((entry) {
                return FlSpot(entry.key.toDouble(), entry.value.value);
              }).toList(),
              isCurved: true,
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryBlue,
                  AppColors.accentGreen,
                ],
              ),
              barWidth: 5,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: false,
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryBlue.withOpacity(0.3),
                    AppColors.accentGreen.withOpacity(0.3),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _getMaxValue() {
    return data.map((e) => e.value).reduce((a, b) => a > b ? a : b);
  }
}

// Salary breakdown pie chart for employees
class SalaryBreakdownChart extends StatelessWidget {
  final List<ChartData> data;

  const SalaryBreakdownChart({
    Key? key,
    required this.data,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(child: Text('No data available'));
    }

    return Column(
      children: [
        AspectRatio(
          aspectRatio: 1.3,
          child: PieChart(
            PieChartData(
              pieTouchData: PieTouchData(
                touchCallback: (FlTouchEvent event, pieTouchResponse) {
                  // Handle touch events if needed
                },
              ),
              borderData: FlBorderData(show: false),
              sectionsSpace: 2,
              centerSpaceRadius: 40,
              sections: _buildSalaryBreakdownSections(),
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildLegend(),
      ],
    );
  }

  List<PieChartSectionData> _buildSalaryBreakdownSections() {
    final total = data.fold<double>(0, (sum, item) => sum + item.value);
    
    return data.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      final percentage = (item.value / total * 100);
      
      return PieChartSectionData(
        color: AppColors.chartColors[index % AppColors.chartColors.length],
        value: item.value,
        title: '${percentage.toStringAsFixed(0)}%',
        radius: 50,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  Widget _buildLegend() {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: data.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;
        final color = AppColors.chartColors[index % AppColors.chartColors.length];
        
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${item.label}: ${AppUtils.formatCurrency(item.value)}',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}

// Monthly earnings bar chart for employees
class MonthlyEarningsChart extends StatelessWidget {
  final List<ChartData> data;

  const MonthlyEarningsChart({
    Key? key,
    required this.data,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(child: Text('No data available'));
    }

    return AspectRatio(
      aspectRatio: 1.7,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: _getMaxValue() * 1.2,
          barTouchData: BarTouchData(
            enabled: false,
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (double value, TitleMeta meta) {
                  final index = value.toInt();
                  if (index >= 0 && index < data.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        data[index].label,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    );
                  }
                  return Container();
                },
                reservedSize: 30,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 50,
                interval: _getMaxValue() / 5,
                getTitlesWidget: (double value, TitleMeta meta) {
                  return Text(
                    AppUtils.formatCurrency(value),
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  );
                },
              ),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(
            show: false,
          ),
          barGroups: data.asMap().entries.map((entry) {
            return BarChartGroupData(
              x: entry.key,
              barRods: [
                BarChartRodData(
                  toY: entry.value.value,
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primaryBlue,
                      AppColors.accentGreen,
                    ],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                  width: 16,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(4),
                  ),
                ),
              ],
            );
          }).toList(),
          gridData: FlGridData(
            show: true,
            drawHorizontalLine: true,
            drawVerticalLine: false,
            horizontalInterval: _getMaxValue() / 5,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: AppColors.borderLight,
                strokeWidth: 1,
              );
            },
          ),
        ),
      ),
    );
  }

  double _getMaxValue() {
    return data.map((e) => e.value).reduce((a, b) => a > b ? a : b);
  }
}

// Custom chart container
class ChartContainer extends StatelessWidget {
  final String title;
  final Widget chart;
  final List<Widget>? actions;

  const ChartContainer({
    Key? key,
    required this.title,
    required this.chart,
    this.actions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppConstants.paddingMedium),
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              if (actions != null) ...actions!,
            ],
          ),
          const SizedBox(height: AppConstants.paddingMedium),
          chart,
        ],
      ),
    );
  }
}

// Donut chart with center text
class DonutChart extends StatelessWidget {
  final List<ChartData> data;
  final String? centerText;
  final String? centerSubtext;

  const DonutChart({
    Key? key,
    required this.data,
    this.centerText,
    this.centerSubtext,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(child: Text('No data available'));
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        AspectRatio(
          aspectRatio: 1.3,
          child: PieChart(
            PieChartData(
              pieTouchData: PieTouchData(enabled: false),
              borderData: FlBorderData(show: false),
              sectionsSpace: 2,
              centerSpaceRadius: 60,
              sections: _buildDonutSections(),
            ),
          ),
        ),
        if (centerText != null)
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                centerText!,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              if (centerSubtext != null) ...[
                const SizedBox(height: 4),
                Text(
                  centerSubtext!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
      ],
    );
  }

  List<PieChartSectionData> _buildDonutSections() {
    final total = data.fold<double>(0, (sum, item) => sum + item.value);
    
    return data.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      final percentage = (item.value / total * 100);
      
      return PieChartSectionData(
        color: AppColors.chartColors[index % AppColors.chartColors.length],
        value: item.value,
        title: '',
        radius: 30,
        borderSide: const BorderSide(color: Colors.white, width: 2),
      );
    }).toList();
  }
}

// Simple progress bar chart
class ProgressChart extends StatelessWidget {
  final List<ChartData> data;
  final double height;

  const ProgressChart({
    Key? key,
    required this.data,
    this.height = 200,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(child: Text('No data available'));
    }

    final maxValue = data.map((e) => e.value).reduce((a, b) => a > b ? a : b);

    return SizedBox(
      height: height,
      child: Column(
        children: data.map((item) {
          final percentage = item.value / maxValue;
          final color = AppColors.chartColors[
            data.indexOf(item) % AppColors.chartColors.length
          ];

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  SizedBox(
                    width: 100,
                    child: Text(
                      item.label,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      height: 20,
                      decoration: BoxDecoration(
                        color: AppColors.borderLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: percentage,
                        child: Container(
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 60,
                    child: Text(
                      AppUtils.formatCurrency(item.value),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      textAlign: TextAlign.end,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}