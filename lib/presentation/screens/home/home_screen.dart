import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../blocs/subscription/subscription_bloc.dart';
import '../../blocs/subscription/subscription_event.dart';
import '../../blocs/subscription/subscription_state.dart';
import '../../widgets/subscription_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Мои подписки'),
        actions: [
          IconButton(
            onPressed: () => context.push(AppRoutes.settings),
            icon: const Icon(Icons.settings_outlined),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: Theme.of(context).brightness == Brightness.dark
              ? AppTheme.backgroundGradient
              : null,
          color: Theme.of(context).brightness == Brightness.light
              ? AppTheme.backgroundLight
              : null,
        ),
        child: BlocBuilder<SubscriptionBloc, SubscriptionState>(
          builder: (context, state) {
            if (state is SubscriptionLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is SubscriptionLoaded) {
              if (state.allSubscriptions.isEmpty) {
                return _buildFullEmptyState(context);
              }

              return Column(
                children: [
                  _buildHeader(context, state),
                  _buildSearchAndFilters(context, state),
                  Expanded(
                    child: state.filteredSubscriptions.isEmpty
                        ? _buildSearchEmptyState()
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: state.filteredSubscriptions.length,
                            itemBuilder: (context, index) {
                              final sub = state.filteredSubscriptions[index];
                              return SubscriptionCard(
                                subscription: sub,
                                onTap: () => context.push(
                                    AppRoutes.addSubscription,
                                    extra: sub),
                              );
                            },
                          ),
                  ),
                ],
              );
            }

            return const Center(child: Text('Что-то пошло не так'));
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(AppRoutes.addSubscription),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFullEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.auto_awesome_motion_outlined,
                size: 100,
                color: context.colors.primary.withValues(alpha: 0.3)),
            const SizedBox(height: 32),
            Text('Ваш список пуст',
                style: context.displayMedium?.copyWith(fontSize: 24)),
            const SizedBox(height: 12),
            Text(
              'Добавьте свою первую подписку, чтобы начать контролировать расходы',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: context.colors.onSurface.withValues(alpha: 0.6),
                  fontSize: 16),
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: 200,
              child: ElevatedButton(
                onPressed: () => context.push(AppRoutes.addSubscription),
                child: const Text('Добавить'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, SubscriptionLoaded state) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Всего в месяц',
                  style: TextStyle(
                      color: context.colors.onSurface.withValues(alpha: 0.6),
                      fontSize: 14)),
              const SizedBox(height: 4),
              Text(
                '${state.totalMonthlySpend.toStringAsFixed(0)}₽',
                style: TextStyle(
                    color: context.colors.onSurface,
                    fontSize: 32,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
          InkWell(
            onTap: () => context.push(AppRoutes.analytics),
            child: CircleAvatar(
              radius: 24,
              backgroundColor: Theme.of(context).cardColor,
              child:
                  Icon(Icons.analytics_outlined, color: context.colors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters(
      BuildContext context, SubscriptionLoaded state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          TextField(
            onChanged: (val) => context
                .read<SubscriptionBloc>()
                .add(SubscriptionSearchQueryChanged(val)),
            decoration: AppTheme.inputDecoration('Поиск подписок').copyWith(
              prefixIcon: Icon(Icons.search,
                  color: context.colors.onSurface.withValues(alpha: 0.4)),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildFilterChip(context, 'Все', state.selectedCategory == null,
                    () {
                  context
                      .read<SubscriptionBloc>()
                      .add(const SubscriptionCategoryFilterChanged(null));
                }),
                ...AppConstants.categories.map((cat) => _buildFilterChip(
                      context,
                      cat,
                      state.selectedCategory == cat,
                      () => context
                          .read<SubscriptionBloc>()
                          .add(SubscriptionCategoryFilterChanged(cat)),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
      BuildContext context, String label, bool isSelected, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onTap(),
        selectedColor: context.colors.primary.withValues(alpha: 0.2),
        labelStyle: TextStyle(
            color: isSelected
                ? context.colors.primary
                : context.colors.onSurface.withValues(alpha: 0.6)),
      ),
    );
  }

  Widget _buildSearchEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off, size: 64, color: AppTheme.textHint),
          const SizedBox(height: 16),
          Text('Ничего не найдено',
              style:
                  TextStyle(color: AppTheme.textHint.withValues(alpha: 0.8))),
        ],
      ),
    );
  }
}
