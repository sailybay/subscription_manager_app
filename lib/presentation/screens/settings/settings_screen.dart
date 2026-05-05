import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/utils/app_utils.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../blocs/auth/auth_state.dart';
import '../../blocs/subscription/subscription_bloc.dart';
import '../../blocs/subscription/subscription_state.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _darkMode = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Настройки')),
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
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
                    color: AppTheme.surfaceColor,
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
                                style: const TextStyle(
                                    color: AppTheme.textSecondary,
                                    fontSize: 13)),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () =>
                            context.read<AuthBloc>().add(AuthLogoutRequested()),
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
                    activeColor: context.colors.primary,
                  ),
                ),
                const SizedBox(height: 12),

                _buildSettingTile(
                  icon: Icons.dark_mode_outlined,
                  title: 'Темная тема',
                  subtitle: 'Использовать темную палитру',
                  trailing: Switch(
                    value: _darkMode,
                    onChanged: (val) => setState(() => _darkMode = val),
                    activeColor: context.colors.primary,
                  ),
                ),

                const SizedBox(height: 32),
                Text('Данные', style: context.titleMedium),
                const SizedBox(height: 16),

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
                  onTap: () {
                    // TODO: Добавить подтверждение
                  },
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
          color: AppTheme.cardColor.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(icon, color: titleColor ?? AppTheme.textSecondary, size: 22),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          color: titleColor ?? AppTheme.textPrimary,
                          fontWeight: FontWeight.w600)),
                  Text(subtitle,
                      style: const TextStyle(
                          color: AppTheme.textHint, fontSize: 12)),
                ],
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }

  void _exportData(BuildContext context) {
    final subState = context.read<SubscriptionBloc>().state;
    if (subState is SubscriptionLoaded) {
      final csv = AppUtils.generateSubscriptionCsv(subState.allSubscriptions);
      debugPrint('Generated CSV:\n$csv'); // Используем переменную для лога
      AppUtils.showSnackBar(context, 'Файл экспортирован успешно (имитация)');
    }
  }
}
