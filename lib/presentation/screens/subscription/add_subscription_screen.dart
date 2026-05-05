import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/utils/app_utils.dart';
import '../../../domain/entities/subscription.dart';
import '../../blocs/subscription/subscription_bloc.dart';
import '../../blocs/subscription/subscription_event.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_text_field.dart';

class AddSubscriptionScreen extends StatefulWidget {
  final Subscription? subscription;

  const AddSubscriptionScreen({super.key, this.subscription});

  @override
  State<AddSubscriptionScreen> createState() => _AddSubscriptionScreenState();
}

class _AddSubscriptionScreenState extends State<AddSubscriptionScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _priceController;
  late DateTime _selectedDate;
  late String _selectedCategory;

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.subscription?.name ?? '');
    _priceController = TextEditingController(
        text: widget.subscription?.price.toString() ?? '');
    _selectedDate = widget.subscription?.nextBillingDate ?? DateTime.now();
    _selectedCategory =
        widget.subscription?.category ?? AppConstants.categories.first;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.subscription != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Редактировать' : 'Новая подписка'),
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              onPressed: () => _confirmDelete(context),
            ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: context.colors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: context.colors.primary.withValues(alpha: 0.3),
                          width: 2),
                    ),
                    child: Icon(
                        isEditing
                            ? Icons.edit_note
                            : Icons.add_photo_alternate_outlined,
                        color: context.colors.primary,
                        size: 32),
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
                  hintText: 'Стоимость (₽)',
                  prefixIcon: Icons.payments_outlined,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: 24),
                Text('Категория', style: context.titleMedium),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: AppConstants.categories.map((cat) {
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
                      firstDate:
                          DateTime.now().subtract(const Duration(days: 365)),
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
                          AppUtils.formatDate(_selectedDate),
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
                  text: isEditing ? 'Обновить данные' : 'Добавить подписку',
                  onPressed: () => _onSave(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onSave(BuildContext context) {
    final name = _nameController.text.trim();
    final priceStr = _priceController.text.replaceAll(',', '.');
    final price = double.tryParse(priceStr) ?? 0.0;

    if (name.isEmpty) {
      AppUtils.showSnackBar(context, 'Введите название подписки',
          isError: true);
      return;
    }
    if (price <= 0) {
      AppUtils.showSnackBar(context, 'Введите корректную стоимость',
          isError: true);
      return;
    }

    final isEditing = widget.subscription != null;
    if (isEditing) {
      context.read<SubscriptionBloc>().add(
            SubscriptionUpdated(
              id: widget.subscription!.id,
              name: name,
              price: price,
              category: _selectedCategory,
              nextBillingDate: _selectedDate,
            ),
          );
    } else {
      context.read<SubscriptionBloc>().add(
            SubscriptionAdded(
              name: name,
              price: price,
              category: _selectedCategory,
              nextBillingDate: _selectedDate,
            ),
          );
    }
    context.pop();
  }

  void _confirmDelete(BuildContext parentContext) {
    final bloc = parentContext.read<SubscriptionBloc>();
    showDialog(
      context: parentContext,
      builder: (context) => AlertDialog(
        title: const Text('Удалить подписку?'),
        content: const Text('Это действие нельзя будет отменить.'),
        actions: [
          TextButton(
              onPressed: () => context.pop(), child: const Text('Отмена')),
          TextButton(
            onPressed: () {
              bloc.add(SubscriptionDeleted(widget.subscription!.id));
              context.pop(); // Close dialog
              parentContext.pop(); // Return to home
            },
            child: const Text('Удалить',
                style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}
