import 'package:fluentiq/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sliding_clipped_nav_bar/sliding_clipped_nav_bar.dart';

/// Persistent navigation for the authenticated experience.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.child});
  final Widget child;
  static const _locations = ['/home', '/assessments', '/results', '/settings'];

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    final selected = _locations.indexWhere(location.startsWith).clamp(0, 3);
    return Scaffold(
      body: child,
      bottomNavigationBar: SafeArea(
        child: SlidingClippedNavBar(
          fontSize: 14,
          iconSize: 25,
          selectedIndex: selected,
          onButtonPressed: (int index) {
            context.go(_locations[index]);
          },
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          activeColor: AppColors.brandGreen,
          inactiveColor: AppColors.lightTextMuted,

          barItems: [
            BarItem(icon: Icons.home_outlined, title: 'Home'),
            BarItem(icon: Icons.assignment_outlined, title: 'Assessments'),
            BarItem(icon: Icons.insights_outlined, title: 'Results'),
            BarItem(icon: Icons.settings_outlined, title: 'Settings'),

          ],

        ),
      )
      // bottomNavigationBar: NavigationBar(
      //   selectedIndex: selected,
      //   onDestinationSelected: (index) => context.go(_locations[index]),
      //   destinations: const [
      //     NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
      //     NavigationDestination(icon: Icon(Icons.assignment_outlined), selectedIcon: Icon(Icons.assignment), label: 'Assessments'),
      //     NavigationDestination(icon: Icon(Icons.insights_outlined), selectedIcon: Icon(Icons.insights), label: 'Results'),
      //     NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: 'Settings'),
      //   ],
      // ),
    );
  }
}
