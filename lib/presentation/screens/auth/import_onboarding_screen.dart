import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/di/service_locator.dart';
import '../../../data/services/email_import_service.dart';
import '../../../domain/entities/subscription.dart';
import '../../blocs/subscription/subscription_bloc.dart';
import '../../blocs/subscription/subscription_event.dart';
import '../../blocs/subscription/subscription_state.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/subscription_card.dart';

class ImportOnboardingScreen extends StatefulWidget {
  const ImportOnboardingScreen({super.key});

  @override
  State<ImportOnboardingScreen> createState() => _ImportOnboardingScreenState();
}

class _ImportOnboardingScreenState extends State<ImportOnboardingScreen> {
  bool _isScanning = false;
  List<Subscription>? _foundSubscriptions;
  final List<int> _selectedIds = [];

  void _startScan() async {
    setState(() {
      _isScanning = true;
    });

    // Получаем результаты сканирования
    final results = await sl<EmailImportService>().scanEmails();

    // Захватываем state ДО await, чтобы избежать использования контекста
    // после асинхронного разрыва
    if (!mounted) return;

    final currentState = context.read<SubscriptionBloc>().state;
    List<Subscription> existingSubs = [];
    if (currentState is SubscriptionLoaded) {
      existingSubs = currentState.allSubscriptions;
    }

    // Фильтруем: оставляем только те подписки, которых еще нет в базе
    final filteredResults = results.where((found) {
      return !existingSubs.any((existing) =>
          existing.name.toLowerCase() == found.name.toLowerCase());
    }).toList();

    setState(() {
      _isScanning = false;
      _foundSubscriptions = filteredResults;
      _selectedIds.addAll(filteredResults.map((e) => e.id));
    });
  }

  void _finishImport() {
    if (_foundSubscriptions == null) return;

    for (var sub in _foundSubscriptions!) {
      if (_selectedIds.contains(sub.id)) {
        context.read<SubscriptionBloc>().add(SubscriptionAdded(
              name: sub.name,
              price: sub.price,
              category: sub.category,
              nextBillingDate: sub.nextBillingDate,
            ));
      }
    }

    context.go(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: Theme.of(context).brightness == Brightness.dark
              ? AppTheme.backgroundGradient
              : null,
          color: Theme.of(context).brightness == Brightness.light
              ? AppTheme.backgroundLight
              : null,
        ),
        child: SafeArea(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              child: _isScanning
                  ? _buildScanningState()
                  : (_foundSubscriptions == null
                      ? _buildWelcomeState()
                      : _buildResultsState()),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeState() {
    return Column(
      key: const ValueKey('welcome'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.auto_awesome, size: 80, color: AppTheme.primaryColor),
        const SizedBox(height: 32),
        Text(
          'Сэкономим ваше время? 🚀',
          textAlign: TextAlign.center,
          style: context.displayLarge?.copyWith(fontSize: 28),
        ),
        const SizedBox(height: 16),
        Text(
          'Я могу автоматически найти ваши подписки в почте Gmail. Вам не придется вводить их вручную.',
          textAlign: TextAlign.center,
          style: TextStyle(
              color: context.colors.onSurface.withValues(alpha: 0.7),
              fontSize: 16),
        ),
        const SizedBox(height: 48),
        AppButton(
          text: 'Сканировать почту',
          onPressed: _startScan,
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () => context.go(AppRoutes.home),
          child: const Text('Я введу всё вручную',
              style: TextStyle(color: AppTheme.textHint)),
        ),
      ],
    );
  }

  Widget _buildScanningState() {
    return Column(
      key: const ValueKey('scanning'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(
          width: 100,
          height: 100,
          child: CircularProgressIndicator(
            strokeWidth: 8,
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
          ),
        ),
        const SizedBox(height: 48),
        Text(
          'Магия в процессе...',
          style: context.titleMedium?.copyWith(fontSize: 20),
        ),
        const SizedBox(height: 8),
        Text(
          'Ищем чеки от Netflix, Spotify и других сервисов',
          textAlign: TextAlign.center,
          style:
              TextStyle(color: context.colors.onSurface.withValues(alpha: 0.5)),
        ),
      ],
    );
  }

  Widget _buildResultsState() {
    if (_foundSubscriptions!.isEmpty) {
      return Column(
        key: const ValueKey('no_results'),
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle_outline,
              size: 80, color: Colors.greenAccent),
          const SizedBox(height: 24),
          Text(
            'Всё уже под контролем!',
            style: context.titleLarge,
          ),
          const SizedBox(height: 12),
          const Text(
            'Я не нашел новых подписок в вашей почте. Все найденные сервисы уже есть в вашем списке.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 48),
          AppButton(
            text: 'На главный экран',
            onPressed: () => context.go(AppRoutes.home),
          ),
        ],
      );
    }

    return Column(
      key: const ValueKey('results'),
      children: [
        Text(
          'Чудесно! ✨',
          style: context.displayLarge?.copyWith(fontSize: 28),
        ),
        const SizedBox(height: 8),
        Text(
          'Я нашел ${_foundSubscriptions!.length} новые подписки. Выберите те, которые хотите добавить:',
          textAlign: TextAlign.center,
          style:
              TextStyle(color: context.colors.onSurface.withValues(alpha: 0.7)),
        ),
        const SizedBox(height: 32),
        Expanded(
          child: ListView.builder(
            itemCount: _foundSubscriptions!.length,
            itemBuilder: (context, index) {
              final sub = _foundSubscriptions![index];
              final isSelected = _selectedIds.contains(sub.id);
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedIds.remove(sub.id);
                      } else {
                        _selectedIds.add(sub.id);
                      }
                    });
                  },
                  borderRadius: BorderRadius.circular(24),
                  child: Row(
                    children: [
                      Checkbox(
                        value: isSelected,
                        onChanged: (val) {
                          setState(() {
                            if (val == true) {
                              _selectedIds.add(sub.id);
                            } else {
                              _selectedIds.remove(sub.id);
                            }
                          });
                        },
                        shape: const CircleBorder(),
                        activeColor: AppTheme.primaryColor,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: SubscriptionCard(subscription: sub),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 24),
        AppButton(
          text: 'Добавить выбранные (${_selectedIds.length})',
          onPressed: _finishImport,
        ),
      ],
    );
  }
}
