import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_theme.dart';

// Placeholder screens
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.dashboard_outlined,
            size: 64,
            color: AppTheme.getPrimaryColor(isDark).withAlpha(128),
          ),
          const SizedBox(height: 24),
          Text('Dashboard', style: AppTheme.getSubheadingStyle(isDark)),
          const SizedBox(height: 8),
          Text('Coming Soon', style: AppTheme.getBodyStyle(isDark)),
        ],
      ),
    );
  }
}

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.swap_horiz_outlined,
            size: 64,
            color: AppTheme.getPrimaryColor(isDark).withAlpha(128),
          ),
          const SizedBox(height: 24),
          Text('Transactions', style: AppTheme.getSubheadingStyle(isDark)),
          const SizedBox(height: 8),
          Text('Coming Soon', style: AppTheme.getBodyStyle(isDark)),
        ],
      ),
    );
  }
}

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_outline,
            size: 64,
            color: AppTheme.getPrimaryColor(isDark).withAlpha(128),
          ),
          const SizedBox(height: 24),
          Text('Profile', style: AppTheme.getSubheadingStyle(isDark)),
          const SizedBox(height: 8),
          Text('Coming Soon', style: AppTheme.getBodyStyle(isDark)),
          const SizedBox(height: 40),
          SizedBox(
            width: 140,
            child: ElevatedButton.icon(
              onPressed: () {
                ref.read(authNotifierProvider.notifier).signOut();
              },
              icon: const Icon(Icons.logout, size: 18),
              label: const Text('Sign Out'),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isDark
                        ? AppTheme.darkCardBackground
                        : AppTheme.lightBackground,
                foregroundColor: AppTheme.getPrimaryColor(isDark),
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: AppTheme.getPrimaryColor(isDark).withAlpha(77),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const TransactionsScreen(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Spending & Income'),
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: AppTheme.getDividerColor(isDark), width: 1),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.swap_horiz_outlined),
              activeIcon: Icon(Icons.swap_horiz),
              label: 'Transactions',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
      floatingActionButton:
          _selectedIndex == 1
              ? FloatingActionButton(
                onPressed: () {
                  //TODO: Open add transaction screen
                },
                elevation: 0,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                ),
                child: const Icon(Icons.add),
              )
              : null,
    );
  }
}
