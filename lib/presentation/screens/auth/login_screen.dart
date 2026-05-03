import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_utils.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../blocs/auth/auth_state.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLogin() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
            AuthLoginRequested(
              _emailController.text.trim(),
              _passwordController.text.trim(),
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            AppUtils.showSnackBar(context, state.message, isError: true);
          }
        },
        child: Container(
          decoration:
              const BoxDecoration(gradient: AppTheme.backgroundGradient),
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('С возвращением',
                          style: Theme.of(context).textTheme.displayLarge),
                      const SizedBox(height: 8),
                      Text('Войдите, чтобы управлять подписками',
                          style: Theme.of(context).textTheme.bodyMedium),
                      const SizedBox(height: 48),

                      // Поле Email
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          hintText: 'Email',
                          prefixIcon: Icon(Icons.email_outlined,
                              color: AppTheme.textSecondary),
                        ),
                        validator: AppUtils.validateEmail,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),

                      // Поле Пароля
                      TextFormField(
                        controller: _passwordController,
                        decoration: const InputDecoration(
                          hintText: 'Пароль',
                          prefixIcon: Icon(Icons.lock_outline,
                              color: AppTheme.textSecondary),
                        ),
                        obscureText: true,
                        validator: AppUtils.validatePassword,
                      ),
                      const SizedBox(height: 32),

                      // Кнопка входа
                      BlocBuilder<AuthBloc, AuthState>(
                        builder: (context, state) {
                          return ElevatedButton(
                            onPressed: state is AuthLoading ? null : _onLogin,
                            child: state is AuthLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                        color: Colors.white, strokeWidth: 2),
                                  )
                                : const Text('Войти'),
                          );
                        },
                      ),
                      const SizedBox(height: 24),

                      // Переход к регистрации
                      Center(
                        child: TextButton(
                          onPressed: () => context.push(AppRouter.registerPath),
                          child: RichText(
                            text: const TextSpan(
                              text: 'Нет аккаунта? ',
                              style: TextStyle(color: AppTheme.textSecondary),
                              children: [
                                TextSpan(
                                  text: 'Создать',
                                  style: TextStyle(
                                      color: AppTheme.primaryColor,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
