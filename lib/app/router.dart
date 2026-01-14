import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/bills',
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          return _ScaffoldWithNav(child: child);
        },
        routes: [
          GoRoute(
            path: '/bills',
          ),
          GoRoute(
            path: '/projects',
          ),
          GoRoute(
            path: '/settings',
          ),
        ],
      ),
    ],
  );
});

class _ScaffoldWithNav extends StatelessWidget {
  const _ScaffoldWithNav({required this.child});

  final Widget child;

  int _indexFromLocation(String location) {
    if (location.startsWith('/projects')) return 1;
    if (location.startsWith('/settings')) return 2;
    return 0; // bills
  }

  void _onTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/bills');
        break;
      case 1:
        context.go('/projects');
        break;
      case 2:
        context.go('/settings');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final index = _indexFromLocation(location);

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBarTheme(
        data: const NavigationBarThemeData(
          height: 46,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
        ),
        child: NavigationBar(
          selectedIndex: index,
          onDestinationSelected: (i) => _onTap(context, i),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.receipt_long), label: 'Bills'),
            NavigationDestination(icon: Icon(Icons.folder_open), label: 'Projects'),
            NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
          ],
        ),
      ),
    );
  }
}