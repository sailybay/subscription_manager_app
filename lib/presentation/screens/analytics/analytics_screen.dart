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
      appBar: AppBar(
        title: const Text('Аналитика'),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: BlocBuilder<SubscriptionBloc, SubscriptionState>(
            builder: (context, state) {
              if (state is SubscriptionLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              // Используем allSubscriptions для аналитики, чтобы видеть всю картину
              final subscriptions = state is SubscriptionLoaded
                  ? state.allSubscriptions
                  : <Subscription>[];

              if (subscriptions.isEmpty) {
                return const Center(
                  child: Text('Добавьте подписки для анализа',
                      style: TextStyle(color: AppTheme.textSecondary)),
                );
              }

              // --- Логика расчетов ---
              final categoryData = _calculateCategoryData(subscriptions);
              final maxPriceSub =
                  subscriptions.reduce((a, b) => a.price > b.price ? a : b);
              final avgPrice = state is SubscriptionLoaded
                  ? (state.totalMonthlySpend / subscriptions.length)
                  : 0.0;

              return SingleChildScrollView(
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
                          sectionsSpace: 2,
                          centerSpaceRadius: 40,
                          sections: categoryData.entries.map((entry) {
                            return PieChartSectionData(
                              color: _getCategoryColor(entry.key),
                              value: entry.value,
                              title: '${entry.value.toStringAsFixed(0)}₽',
                              radius: 50,
                              titleStyle: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 48),

                    // Реальная Статистика
                    Row(
                      children: [
                        _buildStatCard(
                            context,
                            'Макс. цена',
                            AppUtils.formatCurrency(maxPriceSub.price),
                            Icons.trending_up),
                        const SizedBox(width: 16),
                        _buildStatCard(context, 'В среднем',
                            AppUtils.formatCurrency(avgPrice), Icons.bar_chart),
                      ],
                    ),
                    const SizedBox(height: 32),

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
            Icon(icon, color: AppTheme.primaryColor, size: 20),
            const SizedBox(height: 12),
            Text(title, style: context.bodyMedium?.copyWith(fontSize: 12)),
            const SizedBox(height: 4),
            Text(value,
                style: context.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold, fontSize: 14)),
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
