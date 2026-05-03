import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/utils/app_utils.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Аналитика'),
        leading: const BackButton(color: AppTheme.textPrimary),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Траты по категориям', style: context.titleMedium),
                const SizedBox(height: 24),

                // График
                SizedBox(
                  height: 200,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 0,
                      centerSpaceRadius: 40,
                      sections: [
                        PieChartSectionData(
                          color: context.colors.primary,
                          value: 40,
                          title: '40%',
                          radius: 50,
                          titleStyle: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        PieChartSectionData(
                          color: context.colors.secondary,
                          value: 30,
                          title: '30%',
                          radius: 50,
                          titleStyle: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        PieChartSectionData(
                          color: Colors.purpleAccent,
                          value: 15,
                          title: '15%',
                          radius: 50,
                          titleStyle: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        PieChartSectionData(
                          color: Colors.orangeAccent,
                          value: 15,
                          title: '15%',
                          radius: 50,
                          titleStyle: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 48),

                // Статистика в карточках
                Row(
                  children: [
                    _buildStatCard(
                        context, 'Макс. цена', '2 400 ₽', Icons.trending_up),
                    const SizedBox(width: 16),
                    _buildStatCard(
                        context, 'В среднем', '830 ₽', Icons.bar_chart),
                  ],
                ),
                const SizedBox(height: 32),

                Text('Детализация', style: context.titleMedium),
                const SizedBox(height: 16),

                // Список категорий
                _buildCategoryItem(
                    context, 'Развлечения', 4500, context.colors.primary),
                _buildCategoryItem(
                    context, 'Музыка', 1200, context.colors.secondary),
                _buildCategoryItem(
                    context, 'Работа', 3200, Colors.purpleAccent),
                _buildCategoryItem(
                    context, 'Здоровье', 800, Colors.orangeAccent),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
      BuildContext context, String title, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: context.colors.primary, size: 20),
            const SizedBox(height: 12),
            Text(title, style: context.bodyMedium?.copyWith(fontSize: 12)),
            const SizedBox(height: 4),
            Text(value,
                style:
                    context.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryItem(
      BuildContext context, String name, double amount, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Text(name, style: context.bodyMedium),
          const Spacer(),
          Text(
            AppUtils.formatCurrency(amount),
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
          ),
        ],
      ),
    );
  }
}
