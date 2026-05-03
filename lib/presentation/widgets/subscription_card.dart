import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/extensions/context_extensions.dart';
import '../../core/utils/app_utils.dart';

class SubscriptionCard extends StatelessWidget {
  final String title;
  final double price;
  final String category;
  final DateTime nextBillingDate;
  final IconData icon;

  const SubscriptionCard({
    super.key,
    required this.title,
    required this.price,
    required this.category,
    required this.nextBillingDate,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          // Иконка
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: context.colors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: context.colors.primary, size: 28),
          ),
          const SizedBox(width: 16),

          // Инфо
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: context.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(category,
                    style: context.bodyMedium?.copyWith(fontSize: 12)),
              ],
            ),
          ),

          // Цена и дата
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                AppUtils.formatCurrency(price),
                style: context.titleMedium?.copyWith(
                  color: context.colors.secondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${AppUtils.formatDate(nextBillingDate)}',
                style: context.bodyMedium?.copyWith(fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
