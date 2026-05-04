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
              final totalWeekly =
                  totalMonthly / 4.345; // Среднее кол-во недель в месяце

              final categoryData = _calculateCategoryData(subscriptions);
              final maxCategory = categoryData.entries
                  .reduce((a, b) => a.value > b.value ? a : b)
                  .key;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- Блок прогнозов (Новый) ---
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(32),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Прогноз расходов',
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 14)),
                          const SizedBox(height: 16),
                          _buildForecastRow(
                              'В неделю', AppUtils.formatCurrency(totalWeekly)),
                          const Divider(color: Colors.white24, height: 24),
                          _buildForecastRow(
                              'В месяц', AppUtils.formatCurrency(totalMonthly)),
                          const Divider(color: Colors.white24, height: 24),
                          _buildForecastRow(
                              'В год', AppUtils.formatCurrency(totalYearly),
                              isBold: true),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // --- Секция "Умные советы" ---
                    Text('Инсайты', style: context.titleMedium),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.orangeAccent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: Colors.orangeAccent.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.lightbulb_outline,
                              color: Colors.orangeAccent),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Ваша самая затратная категория — "$maxCategory". Подумайте, все ли эти подписки вам полезны.',
                              style: context.bodyMedium?.copyWith(
                                  fontSize: 13, color: Colors.orangeAccent),
                            ),
                          ),
                        ],
                      ),
                    ),
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
                    const SizedBox(height: 48),

                    Text('Детализация', style: context.titleMedium),
                    const SizedBox(height: 16),
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

  Widget _buildForecastRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(color: Colors.white70, fontSize: 13)),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: isBold ? 20 : 16,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
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
