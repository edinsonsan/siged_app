import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_cubit.dart';
import '../home/home_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Card(
            margin: const EdgeInsets.all(24),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: BlocListener<AuthCubit, AuthState>(
                listener: (context, state) {
                  if (state is AuthLoading) {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (_) => const Center(child: CircularProgressIndicator()),
                    );
                  } else {
                    // Close any open dialogs when not loading
                    if (Navigator.canPop(context)) Navigator.pop(context);
                  }

                  if (state is AuthAuthenticated) {
                    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()));
                  }
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Iniciar Sesión', style: TextStyle(fontSize: 24)),
                    const SizedBox(height: 12),
                    Form(
                      key: formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: emailController,
                            decoration: const InputDecoration(labelText: 'Email'),
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Email is required';
                              final emailRegex = RegExp(r"^[^@\s]+@[^@\s]+\.[^@\s]+$");
                              if (!emailRegex.hasMatch(v)) return 'Enter a valid email';
                              return null;
                            },
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: passwordController,
                            decoration: const InputDecoration(labelText: 'Password'),
                            obscureText: true,
                            validator: (v) => (v == null || v.isEmpty) ? 'Password is required' : null,
                          ),
                          const SizedBox(height: 16),
                          BlocBuilder<AuthCubit, AuthState>(builder: (context, state) {
                            String? error;
                            if (state is AuthError) error = state.message;

                            return Column(
                              children: [
                                if (error != null) ...[
                                  Text(error, style: const TextStyle(color: Colors.red)),
                                  const SizedBox(height: 8),
                                ],
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      if (formKey.currentState?.validate() ?? false) {
                                        final email = emailController.text.trim();
                                        final password = passwordController.text;
                                        context.read<AuthCubit>().login(email, password);
                                      }
                                    },
                                    child: const Text('Ingresar'),
                                  ),
                                ),
                              ],
                            );
                          }),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
