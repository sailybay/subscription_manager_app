import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/utils/app_utils.dart';
import '../../blocs/subscription/subscription_bloc.dart';
import '../../blocs/subscription/subscription_state.dart';
import '../../../domain/entities/subscription.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Аналитика')),
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: BlocBuilder<SubscriptionBloc, SubscriptionState>(
            builder: (context, state) {
              if (state is SubscriptionLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              final subscriptions = state is SubscriptionLoaded
                  ? state.allSubscriptions
                  : <Subscription>[];

              if (subscriptions.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.analytics_outlined,
                          size: 64,
                          color: context.colors.primary.withValues(alpha: 0.2)),
                      const SizedBox(height: 16),
                      const Text('Добавьте подписки для анализа',
                          style: TextStyle(color: AppTheme.textSecondary)),
                    ],
                  ),
                );
              }

              final totalMonthly =
                  state is SubscriptionLoaded ? state.totalMonthlySpend : 0.0;
              final totalYearly = totalMonthly * 12;

              // В реальном приложении здесь должен быть расчет на основе истории, пока используем заглушку
              const prevMonthSpend = 12000.0;
              final diff = totalMonthly - prevMonthSpend;
              final diffPercent = prevMonthSpend > 0
                  ? (diff / prevMonthSpend * 100).abs()
                  : 0.0;

              final categoryData = _calculateCategoryData(subscriptions);

              // Находим самую затратную категорию для инсайта
              final maxCategoryEntry = categoryData.entries.isNotEmpty
                  ? categoryData.entries
                      .reduce((a, b) => a.value > b.value ? a : b)
                  : null;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- Сводка ---
                    Row(
                      children: [
                        _buildSummaryCard(
                            context,
                            'Ежемесячно',
                            AppUtils.formatCurrency(totalMonthly),
                            diff >= 0 ? Icons.trending_up : Icons.trending_down,
                            diff >= 0 ? Colors.redAccent : Colors.greenAccent,
                            '${diff >= 0 ? '+' : '-'}${diffPercent.toStringAsFixed(1)}% к пр. мес.'),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // --- Прогноз ---
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceColor,
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.05)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Прогноз расходов', style: context.titleMedium),
                          const SizedBox(height: 16),
                          _buildForecastRow('За полгода',
                              AppUtils.formatCurrency(totalMonthly * 6)),
                          const Divider(color: Colors.white10, height: 24),
                          _buildForecastRow(
                              'За год', AppUtils.formatCurrency(totalYearly),
                              isBold: true),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    if (maxCategoryEntry != null) ...[
                      Text('Инсайты', style: context.titleMedium),
                      const SizedBox(height: 12),
                      _buildInsightCard(context, maxCategoryEntry.key),
                      const SizedBox(height: 32),
                    ],

                    Text('По категориям', style: context.titleMedium),
                    const SizedBox(height: 24),

                    // График
                    SizedBox(
                      height: 200,
                      child: PieChart(
                        PieChartData(
                          sectionsSpace: 4,
                          centerSpaceRadius: 40,
                          sections: categoryData.entries.map((entry) {
                            final percentage = totalMonthly > 0
                                ? (entry.value / totalMonthly * 100)
                                : 0;
                            return PieChartSectionData(
                              color: _getCategoryColor(entry.key),
                              value: entry.value,
                              title: percentage > 5
                                  ? '${percentage.toStringAsFixed(0)}%'
                                  : '',
                              radius: 50,
                              titleStyle: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    ...categoryData.entries.map((entry) => _buildCategoryItem(
                        context,
                        entry.key,
                        entry.value,
                        _getCategoryColor(entry.key))),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, String title, String value,
      IconData icon, Color color, String subtitle) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: AppTheme.textSecondary, fontSize: 14)),
                Icon(icon, color: color, size: 22),
              ],
            ),
            const SizedBox(height: 12),
            Text(value,
                style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 32,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(subtitle,
                style: TextStyle(
                    color: color, fontSize: 12, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightCard(BuildContext context, String category) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.colors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(24),
        border:
            Border.all(color: context.colors.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: context.colors.primary,
            child:
                const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'Больше всего вы тратите в категории "$category". Может быть, пора пересмотреть активные подписки?',
              style: context.bodyMedium?.copyWith(fontSize: 13, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForecastRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style:
                const TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
        Text(value,
            style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: isBold ? 18 : 16,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
      ],
    );
  }

  Map<String, double> _calculateCategoryData(List<Subscription> subs) {
    final Map<String, double> data = {};
    for (var sub in subs) {
      data[sub.category] = (data[sub.category] ?? 0) + sub.price;
    }
    return data;
  }

  Color _getCategoryColor(String category) {
    final index = AppConstants.categories.indexOf(category);
    if (index == -1) return Colors.grey;

    // Генерация цветов на основе списка категорий
    final colors = [
      Colors.blueAccent,
      Colors.greenAccent,
      Colors.redAccent,
      Colors.purpleAccent,
      Colors.orangeAccent,
      Colors.tealAccent,
      Colors.pinkAccent,
    ];
    return colors[index % colors.length];
  }

  Widget _buildCategoryItem(
      BuildContext context, String name, double amount, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: AppTheme.cardColor.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 12),
          Text(name, style: context.bodyMedium),
          const Spacer(),
          Text(AppUtils.formatCurrency(amount),
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
        ],
      ),
    );
  }
}
