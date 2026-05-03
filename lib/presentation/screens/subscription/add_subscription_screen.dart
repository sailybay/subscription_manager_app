import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_text_field.dart';

class AddSubscriptionScreen extends StatefulWidget {
  const AddSubscriptionScreen({super.key});

  @override
  State<AddSubscriptionScreen> createState() => _AddSubscriptionScreenState();
}

class _AddSubscriptionScreenState extends State<AddSubscriptionScreen> {
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String _selectedCategory = 'Развлечения';

  final List<String> _categories = [
    'Развлечения',
    'Музыка',
    'Видео',
    'Работа',
    'Здоровье',
    'Другое'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Новая подписка'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Иконка-заглушка
                Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: context.colors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: context.colors.primary.withOpacity(0.3),
                          width: 2),
                    ),
                    child: Icon(Icons.add_photo_alternate_outlined,
                        color: context.colors.primary, size: 32),
                  ),
                ),
                const SizedBox(height: 32),

                AppTextField(
                  controller: _nameController,
                  hintText: 'Название (например, Netflix)',
                  prefixIcon: Icons.edit_outlined,
                ),
                const SizedBox(height: 16),

                AppTextField(
                  controller: _priceController,
                  hintText: 'Стоимость',
                  prefixIcon: Icons.payments_outlined,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 24),

                Text('Категория', style: context.titleMedium),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: _categories.map((cat) {
                    final isSelected = _selectedCategory == cat;
                    return ChoiceChip(
                      label: Text(cat),
                      selected: isSelected,
                      onSelected: (val) =>
                          setState(() => _selectedCategory = cat),
                      backgroundColor: AppTheme.surfaceColor,
                      selectedColor: context.colors.primary,
                      labelStyle: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : AppTheme.textSecondary),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),

                Text('Дата платежа', style: context.titleMedium),
                const SizedBox(height: 12),
                InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime.now(),
                      lastDate:
                          DateTime.now().add(const Duration(days: 365 * 5)),
                    );
                    if (date != null) setState(() => _selectedDate = date);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF2A2A40)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined,
                            color: AppTheme.textSecondary, size: 20),
                        const SizedBox(width: 12),
                        Text(
                          '${_selectedDate.day}.${_selectedDate.month}.${_selectedDate.year}',
                          style: const TextStyle(color: AppTheme.textPrimary),
                        ),
                        const Spacer(),
                        const Icon(Icons.arrow_forward_ios,
                            color: AppTheme.textHint, size: 14),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 48),

                AppButton(
                  text:
                      'Добавить за 0₽ / мес', // Цена будет обновляться динамически
                  onPressed: () {
                    // Пока просто возвращаемся назад
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
