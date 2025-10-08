import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';

import 'core/config/environment.dart';
import 'core/services/http_service.dart';
// ...existing imports
import 'domain/repositories/auth_repository.dart';
import 'presentation/auth/auth_cubit.dart';
import 'presentation/auth/login_screen.dart';
import 'presentation/home/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Environment.initEnvironment();

  // Initialize core dependencies
  final dio = Dio();
  final httpService = DioHttpService(dio);
  final authRepository = AuthRepository(httpService);

  runApp(
    RepositoryProvider.value(
      value: authRepository,
      child: BlocProvider(
        create: (_) {
          final cubit = AuthCubit(authRepository);
          // Immediately check auth status
          cubit.checkAuthStatus();
          return cubit;
        },
        child: const MainApp(),
      ),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final router = GoRouter(
      initialLocation: '/',
      refreshListenable: _AuthChangeNotifier(context.read<AuthCubit>()),
      redirect: (context, state) {
        final authState = context.read<AuthCubit>().state;
        // Some go_router versions expose different properties on GoRouterState
        // Use a dynamic-safe lookup to extract the destination path.
        String? dest;
        try {
          dest = (state as dynamic).location as String?;
        } catch (_) {
          try {
            dest = (state as dynamic).subloc as String?;
          } catch (_) {
            try {
              final uri = (state as dynamic).uri as Uri?;
              dest = uri?.toString();
            } catch (_) {
              dest = null;
            }
          }
        }

  final goingToLogin = dest == '/login';

        if (authState is AuthLoading) {
          // while loading, stay on a splash screen (handled by routes)
          return null;
        }

        if (authState is AuthAuthenticated) {
          // If authenticated, prevent going to login
          if (goingToLogin) return '/home/dashboard';
          // allow navigation
          return null;
        }

        // Unauthenticated or Error -> always go to login
        if (!goingToLogin) return '/login';
        return null;
      },
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) {
            final authState = context.watch<AuthCubit>().state;
            if (authState is AuthLoading) return const SplashScreen();
            if (authState is AuthAuthenticated) return const HomeScreen();
            return const LoginScreen();
          },
        ),
        GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
        ShellRoute(
          builder: (context, state, child) => HomeScreen(child: child),
          routes: [
            GoRoute(
              path: '/home',
              redirect: (context, state) => '/home/dashboard',
            ),
            GoRoute(path: '/home/dashboard', builder: (context, state) => const Center(child: Text('Dashboard'))),
            GoRoute(path: '/home/bandeja', builder: (context, state) => const Center(child: Text('Bandeja de Trámites'))),
            GoRoute(path: '/home/users', builder: (context, state) => const Center(child: Text('Administración de Usuarios'))),
          ],
        ),
      ],
    );

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerDelegate: router.routerDelegate,
      routeInformationParser: router.routeInformationParser,
      routeInformationProvider: router.routeInformationProvider,
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

class _AuthChangeNotifier extends ChangeNotifier {
  final AuthCubit cubit;
  late final StreamSubscription _sub;

  _AuthChangeNotifier(this.cubit) {
    _sub = cubit.stream.listen((_) => notifyListeners());
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}

