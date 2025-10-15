import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'auth_cubit.dart';

// Design constants
const double _kBreakpointWide = 600.0;
const double _kLeftPanelFraction = 0.6; // ~60%
const double _kRightPanelFraction = 0.4; // ~40%
const double _kMaxFormWidth = 420.0;
const Duration _kFadeDuration = Duration(milliseconds: 400);

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  late final AnimationController _animController = AnimationController(
    vsync: this,
    duration: _kFadeDuration,
  );
  late final Animation<double> _fade = CurvedAnimation(
    parent: _animController,
    curve: Curves.easeInOut,
  );

  @override
  void initState() {
    super.initState();
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthCubit, AuthState>(
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

          if (state is AuthError) {
            // Non-blocking error feedback using SnackBar
            _showSnackBar(state.message);
          }

          if (state is AuthAuthenticated) {
            context.go('/home');
          }
        },
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > _kBreakpointWide;
            if (isWide) {
              // Two-panel layout for web/desktop
              return Row(
                children: [
                  // Left informational panel
                  Expanded(
                    flex: (_kLeftPanelFraction * 100).toInt(),
                    child: Container(
                      color: Theme.of(context).colorScheme.primary.withAlpha((0.06 * 255).toInt()),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Placeholder corporate logo: replace with Image.asset if available
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.account_balance,
                                      color: Colors.white,
                                      size: 28,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Municipalidad de Querecotillo - SIGED ',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall
                                        ?.copyWith(fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 18),
                              Text(
                                'Gestión integral de trámites administrativos con seguridad y trazabilidad.',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(color: Colors.black87),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Right form panel
                  Expanded(
                    flex: (_kRightPanelFraction * 100).toInt(),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: _kMaxFormWidth,
                        ),
                        child: FadeTransition(
                          opacity: _fade,
                          child: Card(
                            elevation: 6,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 28.0,
                                vertical: 24.0,
                              ),
                              child: _buildForm(context),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }

            // Narrow/mobile layout: single column
            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 32,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Compact logo/title at top
                    Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.account_balance,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'SIGED',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                    const SizedBox(height: 12),
                    FadeTransition(
                      opacity: _fade,
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: _buildForm(context),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Iniciar Sesión',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            'Ingrese sus credenciales para acceder al panel',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 18),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'Correo electrónico',
              prefixIcon: const Icon(Icons.email),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'El email es requerido';
              final emailRegex = RegExp(r"^[^@\s]+@[^@\s]+\.[^@\s]+$");
              if (!emailRegex.hasMatch(v)) return 'Ingrese un email válido';
              return null;
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _passwordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Contraseña',
              prefixIcon: const Icon(Icons.lock),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            validator:
                (v) =>
                    (v == null || v.isEmpty)
                        ? 'La contraseña es requerida'
                        : null,
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                if (_formKey.currentState?.validate() ?? false) {
                  final email = _emailController.text.trim();
                  final password = _passwordController.text;
                  context.read<AuthCubit>().login(email, password);
                }
              },
              child: const Text('Ingresar'),
            ),
          ),
        ],
      ),
    );
  }
}
