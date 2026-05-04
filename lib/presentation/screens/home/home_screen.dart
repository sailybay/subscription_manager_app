import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/utils/app_utils.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../blocs/subscription/subscription_bloc.dart';
import '../../blocs/subscription/subscription_event.dart';
import '../../blocs/subscription/subscription_state.dart';
import '../../widgets/subscription_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: BlocBuilder<SubscriptionBloc, SubscriptionState>(
            builder: (context, state) {
              if (state is SubscriptionLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              final subscriptions =
                  state is SubscriptionLoaded ? state.subscriptions : [];
              final totalSpend =
                  state is SubscriptionLoaded ? state.totalMonthlySpend : 0.0;

              return CustomScrollView(
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
                              Text('Твои подписки',
                                  style: context.headlineMedium),
                            ],
                          ),
                          InkWell(
                            onTap: () => context
                                .read<AuthBloc>()
                                .add(AuthLogoutRequested()),
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
                              color:
                                  AppTheme.primaryColor.withValues(alpha: 0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Траты в этом месяце',
                                style: TextStyle(
                                    color: Colors.white70, fontSize: 14)),
                            const SizedBox(height: 8),
                            Text(
                              AppUtils.formatCurrency(totalSpend),
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildMiniStat(
                                    'Активных', '${subscriptions.length}'),
                                _buildMiniStat('Ближайший',
                                    subscriptions.isEmpty ? 'Нет' : 'Скоро'),
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
                            onPressed: () =>
                                context.push(AppRouter.analyticsPath),
                            child: const Text('Все'),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // List of Subscriptions
                  if (subscriptions.isEmpty)
                    const SliverToBoxAdapter(
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.only(top: 40),
                          child: Text('У вас пока нет подписок',
                              style: TextStyle(color: AppTheme.textSecondary)),
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final sub = subscriptions[index];
                            return Dismissible(
                              key: Key(sub.id.toString()),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 20),
                                margin: const EdgeInsets.only(bottom: 16),
                                decoration: BoxDecoration(
                                  color:
                                      Colors.redAccent.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                child: const Icon(Icons.delete_outline,
                                    color: Colors.redAccent),
                              ),
                              onDismissed: (direction) {
                                context
                                    .read<SubscriptionBloc>()
                                    .add(SubscriptionDeleted(sub.id));
                              },
                              child: InkWell(
                                onTap: () => context.push(
                                    AppRouter.addSubscriptionPath,
                                    extra: sub),
                                child: SubscriptionCard(
                                  title: sub.name,
                                  category: sub.category,
                                  price: sub.price,
                                  nextBillingDate: sub.nextBillingDate,
                                  icon: _getCategoryIcon(sub.category),
                                ),
                              ),
                            );
                          },
                          childCount: subscriptions.length,
                        ),
                      ),
                    ),

                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              );
            },
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
        return Icons.medical_services_outlined;
      default:
        return Icons.category_outlined;
    }
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
