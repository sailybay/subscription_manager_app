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
    final categories = [
      'Развлечения',
      'Музыка',
      'Видео',
      'Работа',
      'Здоровье',
      'Другое'
    ];

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: BlocBuilder<SubscriptionBloc, SubscriptionState>(
            builder: (context, state) {
              if (state is SubscriptionLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              final subscriptions = state is SubscriptionLoaded
                  ? state.filteredSubscriptions
                  : [];
              final allSubscriptions =
                  state is SubscriptionLoaded ? state.allSubscriptions : [];
              final totalSpend =
                  state is SubscriptionLoaded ? state.totalMonthlySpend : 0.0;
              final selectedCategory =
                  state is SubscriptionLoaded ? state.selectedCategory : null;

              return CustomScrollView(
                slivers: [
                  // --- Header ---
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

                  // --- Search Bar ---
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    sliver: SliverToBoxAdapter(
                      child: TextField(
                        onChanged: (query) => context
                            .read<SubscriptionBloc>()
                            .add(SubscriptionSearchQueryChanged(query)),
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Поиск подписок...',
                          hintStyle: const TextStyle(color: AppTheme.textHint),
                          prefixIcon: const Icon(Icons.search,
                              color: AppTheme.textHint),
                          filled: true,
                          fillColor: AppTheme.surfaceColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ),

                  // --- Category Filters ---
                  SliverPadding(
                    padding: const EdgeInsets.only(top: 24),
                    sliver: SliverToBoxAdapter(
                      child: SizedBox(
                        height: 40,
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          scrollDirection: Axis.horizontal,
                          itemCount: categories.length + 1,
                          separatorBuilder: (_, __) => const SizedBox(width: 8),
                          itemBuilder: (context, index) {
                            if (index == 0) {
                              final isAll = selectedCategory == null;
                              return ChoiceChip(
                                label: const Text('Все'),
                                selected: isAll,
                                onSelected: (_) => context
                                    .read<SubscriptionBloc>()
                                    .add(
                                        const SubscriptionCategoryFilterChanged(
                                            null)),
                                backgroundColor: AppTheme.surfaceColor,
                                selectedColor: context.colors.primary,
                                labelStyle: TextStyle(
                                    color: isAll
                                        ? Colors.white
                                        : AppTheme.textSecondary),
                              );
                            }
                            final cat = categories[index - 1];
                            final isSelected = selectedCategory == cat;
                            return ChoiceChip(
                              label: Text(cat),
                              selected: isSelected,
                              onSelected: (_) => context
                                  .read<SubscriptionBloc>()
                                  .add(SubscriptionCategoryFilterChanged(cat)),
                              backgroundColor: AppTheme.surfaceColor,
                              selectedColor: context.colors.primary,
                              labelStyle: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : AppTheme.textSecondary),
                            );
                          },
                        ),
                      ),
                    ),
                  ),

                  // --- Total Spending Card ---
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
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
                            const Text('Всего в месяц',
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
                                    'Активных', '${allSubscriptions.length}'),
                                _buildMiniStat(
                                    'Показано', '${subscriptions.length}'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // --- Subscriptions List ---
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

                  if (subscriptions.isEmpty)
                    SliverToBoxAdapter(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 40),
                          child: Text(
                              state is SubscriptionLoaded &&
                                      state.searchQuery.isNotEmpty
                                  ? 'Ничего не найдено'
                                  : 'У вас пока нет подписок',
                              style: const TextStyle(
                                  color: AppTheme.textSecondary)),
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
                              onDismissed: (_) {
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
