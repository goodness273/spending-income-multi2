import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:spending_income/utils/app_theme/index.dart';

class ExpenseChart extends StatelessWidget {
  final Map<String, double> monthlyData;
  final bool isDark;
  final NumberFormat currencyFormat;
  final String currentTimeFilter;
  final Function(String) onTimeFilterChanged;

  const ExpenseChart({
    super.key,
    required this.monthlyData,
    required this.isDark,
    required this.currencyFormat,
    required this.currentTimeFilter,
    required this.onTimeFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCardBackground : Colors.white,
        borderRadius: BorderRadius.circular(20),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Expenses',
                style: AppThemeHelpers.getSubheadingStyle(isDark),
              ),
              _buildTimePeriodDropdown(),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: _buildBarChart(),
          ),
        ],
      ),
    );
  }

  Widget _buildTimePeriodDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCardBackground : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.darkDividerColor : AppColors.lightDividerColor,
          width: 0.5,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: currentTimeFilter,
          icon: const Icon(Icons.keyboard_arrow_down, size: 16),
          isDense: true,
          items: ['Daily', 'Weekly', 'Monthly', 'Yearly'].map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(
                value,
                style: AppThemeHelpers.getBodyStyle(isDark),
              ),
            );
          }).toList(),
          onChanged: (newValue) {
            if (newValue != null) {
              onTimeFilterChanged(newValue);
            }
          },
        ),
      ),
    );
  }

  Widget _buildBarChart() {
    final List<String> months = monthlyData.keys.toList();
    final double maxAmount = monthlyData.values.isEmpty 
        ? 100 
        : monthlyData.values.reduce((a, b) => a > b ? a : b);
        
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxAmount * 1.2,
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 && value.toInt() < months.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      months[value.toInt()],
                      style: AppThemeHelpers.getSmallStyle(isDark),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
              reservedSize: 30,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        barGroups: List.generate(months.length, (index) {
          final String month = months[index];
          final double amount = monthlyData[month] ?? 0;
          final bool isHighlighted = index == months.length ~/ 2; // Highlight a middle bar (April in our case)
          
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: amount,
                color: isHighlighted 
                    ? const Color(0xFFFFC107) // Gold/Yellow for highlight
                    : isDark 
                        ? Colors.blueGrey.shade200 
                        : Colors.blueGrey.shade100,
                width: 20,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(6),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
} 