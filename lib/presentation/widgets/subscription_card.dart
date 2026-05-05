import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/extensions/context_extensions.dart';
import '../../core/utils/app_utils.dart';
import '../../../domain/entities/subscription.dart';

class SubscriptionCard extends StatelessWidget {
  final Subscription subscription;
  final VoidCallback? onTap;

  const SubscriptionCard({
    super.key,
    required this.subscription,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Row(
          children: [
            // Иконка категории
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: context.colors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(_getCategoryIcon(subscription.category),
                  color: context.colors.primary, size: 28),
            ),
            const SizedBox(width: 16),

            // Инфо
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(subscription.name,
                      style: context.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(subscription.category,
                      style: const TextStyle(
                          color: AppTheme.textSecondary, fontSize: 12)),
                ],
              ),
            ),

            // Цена и дата
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  AppUtils.formatCurrency(subscription.price),
                  style: TextStyle(
                    color: context.colors.primary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  AppUtils.formatDate(subscription.nextBillingDate),
                  style:
                      const TextStyle(color: AppTheme.textHint, fontSize: 11),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Развлечения':
        return Icons.movie_outlined;
      case 'Музыка':
        return Icons.music_note_outlined;
      case 'Видео':
        return Icons.play_circle_outline;
      case 'Работа':
        return Icons.work_outline;
      case 'Здоровье':
        return Icons.favorite_border;
      default:
        return Icons.subscript_outlined;
    }
  }
}
