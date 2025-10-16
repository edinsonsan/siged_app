import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';

import 'core/config/environment.dart';
import 'core/services/http_service.dart';
// ...existing imports
import 'domain/repositories/auth_repository.dart';
import 'domain/repositories/dashboard_repository.dart';
import 'domain/repositories/tramite_repository.dart';
import 'domain/repositories/admin_repository.dart';
import 'presentation/admin/user_management_screen.dart';
import 'presentation/admin/area_management_screen.dart';
import 'presentation/auth/auth_cubit.dart';
import 'domain/models/user.dart';
import 'presentation/auth/login_screen.dart';
import 'presentation/home/home_screen.dart';
import 'presentation/tramites/dashboard_screen.dart';
import 'presentation/tramites/bandeja_tramites_screen.dart';
import 'presentation/tramites/tramite_detail_screen.dart';
import 'presentation/settings/settings_cubit.dart';
import 'presentation/admin/admin_users_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Environment.initEnvironment();

  // Initialize core dependencies
  final dio = Dio();
  final httpService = DioHttpService(dio);
  final authRepository = AuthRepository(httpService);
  final dashboardRepository = DashboardRepository(httpService);
  final tramiteRepository = TramiteRepository(httpService);
  final adminRepository = AdminRepository(httpService);

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: authRepository),
        RepositoryProvider.value(value: dashboardRepository),
        RepositoryProvider.value(value: tramiteRepository),
        RepositoryProvider.value(value: adminRepository),
      ],
      child: BlocProvider(
        create: (_) {
          final cubit = AuthCubit(authRepository);
          // Immediately check auth status
          cubit.checkAuthStatus();
          return cubit;
        },
        child: MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => SettingsCubit()),
          ],
          child: const MainApp(),
        ),
      ),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsState = context.watch<SettingsCubit>().state;
    final themeMode = settingsState.themeMode;

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

          // RBAC: Protect admin routes - only allow ADMIN role to access /home/admin/* and /home/users
          final role = authState.user.rol;
          final isAdmin = role == UserRole.ADMIN;
          final isAdminRoute = dest != null && (dest.startsWith('/home/admin') || dest == '/home/users');
          if (isAdminRoute && !isAdmin) return '/home/dashboard';

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
            GoRoute(path: '/home/dashboard', builder: (context, state) => const DashboardScreen()),
            GoRoute(path: '/home/bandeja', builder: (context, state) => const BandejaTramitesScreen()),
            GoRoute(
              path: '/home/bandeja/:id',
              builder: (context, state) {
                // 1. Extraer el ID de los parámetros de la ruta. Es un String.
                final idString = state.pathParameters['id'];
                // 3. Convertir el String a int. Si falla (es null o no es un número), será null.
                final id = int.tryParse(idString ?? '');
                // 4. Pasar el id (que puede ser null si hay error) a la pantalla.
                return TramiteDetailScreen.fromId(id: id);
              },
            ),
            GoRoute(path: '/home/users', builder: (context, state) => const AdminUsersScreen()),
            GoRoute(path: '/home/admin/users', builder: (context, state) => const UserManagementScreen()),
            GoRoute(path: '/home/admin/areas', builder: (context, state) => const AreaManagementScreen()),
          ],
        ),
      ],
    );

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal, brightness: Brightness.dark),
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      themeMode: themeMode,
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

