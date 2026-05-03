import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/utils/app_utils.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../widgets/subscription_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              // Header
              SliverPadding(
                padding: const EdgeInsets.all(24.0),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Привет, 👋', style: context.bodyMedium),
                          Text('Твои подписки', style: context.headlineMedium),
                        ],
                      ),
                      InkWell(
                        onTap: () =>
                            context.read<AuthBloc>().add(AuthLogoutRequested()),
                        child: CircleAvatar(
                          radius: 24,
                          backgroundColor: AppTheme.surfaceColor,
                          child: Icon(Icons.logout,
                              color: context.colors.primary, size: 20),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Total Spending Card
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                sliver: SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryColor.withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Траты в этом месяце',
                            style:
                                TextStyle(color: Colors.white70, fontSize: 14)),
                        const SizedBox(height: 8),
                        Text(
                          AppUtils.formatCurrency(12450),
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildMiniStat('Активных', '12'),
                            _buildMiniStat('Ближайший', 'Завтра'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Subscriptions List Title
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Предстоящие платежи',
                          style: context.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold)),
                      TextButton(
                        onPressed: () => context.push(AppRouter.analyticsPath),
                        child: const Text('Все'),
                      ),
                    ],
                  ),
                ),
              ),

              // List of Subscriptions (Mock data)
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    SubscriptionCard(
                      title: 'Netflix',
                      category: 'Развлечения',
                      price: 990,
                      nextBillingDate:
                          DateTime.now().add(const Duration(days: 2)),
                      icon: Icons.movie_outlined,
                    ),
                    SubscriptionCard(
                      title: 'Spotify',
                      category: 'Музыка',
                      price: 299,
                      nextBillingDate:
                          DateTime.now().add(const Duration(days: 5)),
                      icon: Icons.music_note_outlined,
                    ),
                    SubscriptionCard(
                      title: 'YouTube Premium',
                      category: 'Видео',
                      price: 399,
                      nextBillingDate:
                          DateTime.now().add(const Duration(days: 12)),
                      icon: Icons.play_circle_outline,
                    ),
                  ]),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRouter.addSubscriptionPath),
        backgroundColor: AppTheme.primaryColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Добавить',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildMiniStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(color: Colors.white60, fontSize: 12)),
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold)),
      ],
    );
  }
}
