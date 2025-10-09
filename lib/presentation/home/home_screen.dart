import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../domain/models/user.dart';
import '../auth/auth_cubit.dart';

class HomeScreen extends StatefulWidget {
  final Widget? child;
  const HomeScreen({super.key, this.child});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const _paths = ['/home/dashboard', '/home/bandeja', '/home/admin/users', '/home/admin/areas'];

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;
    String userName = '';
    String userRole = '';
    bool isAdmin = false;
    if (authState is AuthAuthenticated) {
      userName = '${authState.user.nombre} ${authState.user.apellido}';
      userRole = authState.user.rol.toString().split('.').last;
      isAdmin = authState.user.rol == UserRole.admin;
    }

    // determine selected index from current location (dynamic-safe across go_router versions)
    String loc = '/home/dashboard';
    try {
      loc = (GoRouterState.of(context) as dynamic).location as String;
    } catch (_) {
      try {
        loc = (GoRouterState.of(context) as dynamic).subloc as String;
      } catch (_) {
        try {
          final uri = (GoRouterState.of(context) as dynamic).uri as Uri;
          loc = uri.toString();
        } catch (_) {
          try {
            loc = (GoRouter.of(context) as dynamic).location as String;
          } catch (_) {
            // fallback stays as default
          }
        }
      }
    }
    int selectedIndex = 0;
    for (var i = 0; i < _paths.length; i++) {
      if (loc.startsWith(_paths[i])) {
        selectedIndex = i;
        break;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('SIGED App'),
        actions: [
          if (userName.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Center(child: Text('$userName ($userRole)')),
            ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => context.read<AuthCubit>().logout(),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: LayoutBuilder(builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 800;
        return Row(
          children: [
            if (isWide)
              NavigationRail(
                selectedIndex: selectedIndex,
                onDestinationSelected: (i) => GoRouter.of(context).go(_paths[i]),
                labelType: NavigationRailLabelType.all,
                destinations: [
                  const NavigationRailDestination(icon: Icon(Icons.dashboard), label: Text('Dashboard')),
                  const NavigationRailDestination(icon: Icon(Icons.inbox), label: Text('Bandeja')),
                  if (isAdmin) const NavigationRailDestination(icon: Icon(Icons.group), label: Text('Usuarios')),
                  if (isAdmin) const NavigationRailDestination(icon: Icon(Icons.business), label: Text('Áreas')),
                ],
              ),
            Expanded(
              child: Column(
                children: [
                  if (!isWide)
                    SizedBox(
                      height: 56,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          for (var i = 0; i < _paths.length; i++)
                            if ((i < 2) || isAdmin)
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                                child: ElevatedButton(
                                  onPressed: () => GoRouter.of(context).go(_paths[i]),
                                  child: Text(i == 0
                                      ? 'Dashboard'
                                      : i == 1
                                          ? 'Bandeja'
                                          : i == 2
                                              ? 'Usuarios'
                                              : 'Áreas'),
                                ),
                              ),
                        ],
                      ),
                    ),
                  Expanded(child: widget.child ?? const SizedBox.shrink()),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }
}
