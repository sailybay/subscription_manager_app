import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_theme.dart';
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
                return const Center(
                    child: Text('Добавьте подписки для анализа',
                        style: TextStyle(color: AppTheme.textSecondary)));
              }

              final totalMonthly =
                  state is SubscriptionLoaded ? state.totalMonthlySpend : 0.0;
              final totalYearly = totalMonthly * 12;

              // Для демонстрации сравнения представим, что в прошлом месяце траты были другими.
              // В реальном приложении здесь должен быть запрос к истории транзакций.
              const prevMonthSpend = 15000.0; // Заглушка для сравнения
              final diff = totalMonthly - prevMonthSpend;
              final diffPercent = (diff / prevMonthSpend * 100).abs();

              final categoryData = _calculateCategoryData(subscriptions);
              final maxCategory = categoryData.entries
                  .reduce((a, b) => a.value > b.value ? a : b)
                  .key;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- Сравнение с прошлым месяцем (Новое) ---
                    Row(
                      children: [
                        _buildSummaryCard(
                            context,
                            'Всего в месяц',
                            AppUtils.formatCurrency(totalMonthly),
                            diff >= 0 ? Icons.trending_up : Icons.trending_down,
                            diff >= 0 ? Colors.redAccent : Colors.greenAccent,
                            '${diff >= 0 ? '+' : '-'}${diffPercent.toStringAsFixed(1)}% к пр. мес.'),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // --- Блок прогнозов ---
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceColor,
                        borderRadius: BorderRadius.circular(32),
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.05)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Прогноз', style: context.titleMedium),
                          const SizedBox(height: 16),
                          _buildForecastRow(
                              'В месяц', AppUtils.formatCurrency(totalMonthly)),
                          const Divider(color: Colors.white10, height: 24),
                          _buildForecastRow(
                              'За год', AppUtils.formatCurrency(totalYearly),
                              isBold: true),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    Text('Инсайты', style: context.titleMedium),
                    const SizedBox(height: 12),
                    _buildInsightCard(context, maxCategory),

                    const SizedBox(height: 32),
                    Text('Траты по категориям', style: context.titleMedium),
                    const SizedBox(height: 24),

                    // График
                    SizedBox(
                      height: 180,
                      child: PieChart(
                        PieChartData(
                          sectionsSpace: 2,
                          centerSpaceRadius: 35,
                          sections: categoryData.entries.map((entry) {
                            return PieChartSectionData(
                              color: _getCategoryColor(entry.key),
                              value: entry.value,
                              title:
                                  '${((entry.value / totalMonthly) * 100).toStringAsFixed(0)}%',
                              radius: 45,
                              titleStyle: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11),
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
                Icon(icon, color: color, size: 20),
              ],
            ),
            const SizedBox(height: 8),
            Text(value,
                style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 28,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(subtitle,
                style: TextStyle(
                    color: color, fontSize: 12, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightCard(BuildContext context, String category) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blueAccent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.blueAccent.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: Colors.blueAccent,
            child: Icon(Icons.auto_awesome, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'Вы активный потребитель в категории "$category". Проверьте, не дублируют ли подписки друг друга?',
              style: context.bodyMedium?.copyWith(fontSize: 13),
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
    switch (category) {
      case 'Развлечения':
        return Colors.blueAccent;
      case 'Музыка':
        return Colors.greenAccent;
      case 'Видео':
        return Colors.redAccent;
      case 'Работа':
        return Colors.purpleAccent;
      case 'Здоровье':
        return Colors.orangeAccent;
      default:
        return Colors.grey;
    }
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
