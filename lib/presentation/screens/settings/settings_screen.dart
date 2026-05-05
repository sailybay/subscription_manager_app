import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/utils/app_utils.dart';
import '../../../core/services/export_service.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../blocs/auth/auth_state.dart';
import '../../blocs/subscription/subscription_bloc.dart';
import '../../blocs/subscription/subscription_event.dart';
import '../../blocs/subscription/subscription_state.dart';
import '../../blocs/theme/theme_bloc.dart';
import '../../blocs/theme/theme_event.dart';
import '../../blocs/theme/theme_state.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Настройки')),
      body: Container(
        decoration: BoxDecoration(
          gradient: Theme.of(context).brightness == Brightness.dark
              ? AppTheme.backgroundGradient
              : null,
          color: Theme.of(context).brightness == Brightness.light
              ? AppTheme.backgroundLight
              : null,
        ),
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, authState) {
            final userEmail = authState is Authenticated
                ? authState.user.email
                : 'user@example.com';

            return ListView(
              padding: const EdgeInsets.all(24.0),
              children: [
                // --- Секция профиля ---
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(24),
                    border:
                        Border.all(color: Colors.white.withValues(alpha: 0.05)),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor:
                            context.colors.primary.withValues(alpha: 0.1),
                        child: Icon(Icons.person,
                            color: context.colors.primary, size: 30),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Мой профиль', style: context.titleMedium),
                            Text(userEmail,
                                style: TextStyle(
                                    color: context.colors.onSurface
                                        .withValues(alpha: 0.6),
                                    fontSize: 13)),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => _confirmLogout(context),
                        icon: const Icon(Icons.logout,
                            color: Colors.redAccent, size: 20),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                Text('Приложение', style: context.titleMedium),
                const SizedBox(height: 16),

                _buildSettingTile(
                  icon: Icons.notifications_active_outlined,
                  title: 'Напоминания',
                  subtitle: 'Уведомления за день до оплаты',
                  trailing: Switch(
                    value: _notificationsEnabled,
                    onChanged: (val) =>
                        setState(() => _notificationsEnabled = val),
                    activeThumbColor: context.colors.primary,
                  ),
                ),
                const SizedBox(height: 24),

                _buildSettingTile(
                  icon: Icons.dark_mode_outlined,
                  title: 'Темная тема',
                  subtitle: 'Использовать темную палитру',
                  trailing: BlocBuilder<ThemeBloc, ThemeState>(
                    builder: (context, state) {
                      return Switch(
                        value: state.themeMode == ThemeMode.dark,
                        onChanged: (val) {
                          context.read<ThemeBloc>().add(ThemeChanged(val));
                        },
                        activeThumbColor: context.colors.primary,
                      );
                    },
                  ),
                ),

                const SizedBox(height: 32),
                Text('Данные', style: context.titleMedium),
                const SizedBox(height: 16),

                _buildSettingTile(
                  icon: Icons.auto_awesome,
                  title: 'Импорт из почты',
                  subtitle: 'Найти подписки автоматически',
                  titleColor: Colors.amberAccent,
                  onTap: () => context.push(AppRoutes.importOnboarding),
                ),
                const SizedBox(height: 12),

                _buildSettingTile(
                  icon: Icons.file_download_outlined,
                  title: 'Экспорт в CSV',
                  subtitle: 'Выгрузить список подписок в таблицу',
                  onTap: () => _exportData(context),
                ),
                const SizedBox(height: 12),

                _buildSettingTile(
                  icon: Icons.delete_forever_outlined,
                  title: 'Очистить базу',
                  subtitle: 'Удалить все данные безвозвратно',
                  titleColor: Colors.redAccent,
                  onTap: () => _confirmClearData(context),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    Color? titleColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(icon,
                color: titleColor ??
                    context.colors.onSurface.withValues(alpha: 0.7),
                size: 22),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          color: titleColor ?? context.colors.onSurface,
                          fontWeight: FontWeight.w600)),
                  Text(subtitle,
                      style: TextStyle(
                          color:
                              context.colors.onSurface.withValues(alpha: 0.5),
                          fontSize: 12)),
                ],
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }

  // Вся файловая/sharing логика делегирована в ExportService.
  // Экран отвечает только за отображение результата пользователю.
  Future<void> _exportData(BuildContext context) async {
    final subState = context.read<SubscriptionBloc>().state;
    if (subState is! SubscriptionLoaded) return;

    final result =
        await ExportService.exportSubscriptionsCsv(subState.allSubscriptions);

    if (!context.mounted) return;

    switch (result) {
      case ExportSuccess():
        AppUtils.showSnackBar(context, 'Файл успешно экспортирован');
      case ExportSavedOnly(:final fileName):
        AppUtils.showSnackBar(context, 'Файл сохранён: $fileName');
      case ExportEmpty():
        AppUtils.showSnackBar(context, 'Нет данных для экспорта',
            isError: true);
      case ExportFailure(:final error):
        AppUtils.showSnackBar(context, 'Ошибка: $error', isError: true);
    }
  }

  void _confirmClearData(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Очистить все данные?'),
        content: const Text(
            'Это удалит все ваши подписки и уведомления. Действие необратимо.'),
        actions: [
          TextButton(
              onPressed: () => context.pop(), child: const Text('Отмена')),
          TextButton(
            onPressed: () {
              context
                  .read<SubscriptionBloc>()
                  .add(SubscriptionDeleteAllRequested());
              context.pop();
              AppUtils.showSnackBar(context, 'База данных успешно очищена');
            },
            child: const Text('Удалить всё',
                style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Выйти из аккаунта?'),
        actions: [
          TextButton(
              onPressed: () => context.pop(), child: const Text('Отмена')),
          TextButton(
            onPressed: () {
              context.read<AuthBloc>().add(AuthLogoutRequested());
              context.pop();
            },
            child:
                const Text('Выход', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}
