import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/medicine_provider.dart';
import '../services/auth_service.dart';
import '../utils/app_colors.dart';
import '../widgets/medicine_card.dart';
import '../widgets/search_filter_bar.dart';
import 'add_medicine_screen.dart';
import 'history_screen.dart';
import 'login_screen.dart';
import 'settings_screen.dart';
import 'profiles_screen.dart';
import 'statistics_dashboard_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  int _currentIndex = 0;
  // Tracks which bottom nav tab is selected

  // List of screens for each tab
  final List<Widget> _screens = [
    const _HomeTab(),
    const StatisticsDashboardScreen(),
    const HistoryScreen(),
    const ProfilesScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      // Show screen based on selected tab
      body: _screens[_currentIndex],

      // FAB only on Home tab
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const AddMedicineScreen()),
              ),
              backgroundColor: AppColors.primary,
              icon: const Icon(Icons.add, color: AppColors.white),
              label: const Text(
                'Add Medicine',
                style: TextStyle(color: AppColors.white),
              ),
            )
          : null,

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        // onTap updates currentIndex → rebuilds UI with new screen
        selectedItemColor:   AppColors.primary,
        unselectedItemColor: AppColors.textGrey,
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.white,
        items: const [
          BottomNavigationBarItem(
            icon:       Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon:       Icon(Icons.bar_chart_outlined),
            activeIcon: Icon(Icons.bar_chart),
            label: 'Stats',
          ),
          BottomNavigationBarItem(
            icon:       Icon(Icons.history_outlined),
            activeIcon: Icon(Icons.history),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon:       Icon(Icons.people_outline),
            activeIcon: Icon(Icons.people),
            label: 'Profiles',
          ),
          BottomNavigationBarItem(
            icon:       Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

// ── Home tab content (extracted from old HomeScreen) ────────
class _HomeTab extends StatefulWidget {
  const _HomeTab();

  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> {
  bool _showSearchFilter = false;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MedicineProvider>();
    final filtered = provider.filteredMedicines;
    final pending  = filtered.where((m) => !m.isTaken).toList();
    final taken    = filtered.where((m) => m.isTaken).toList();
    final lowStock = provider.lowStockMedicines;

    return SafeArea(
      child: CustomScrollView(
        slivers: [

          // ── Header ──────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.only(
                  bottomLeft:  Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Good Morning! 👋',
                            style: TextStyle(
                              color: AppColors.white.withOpacity(0.8),
                              fontSize: 14,
                            ),
                          ),
                          const Text(
                            'Your Medicines',
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: AppColors.white.withOpacity(0.2),
                        child: PopupMenuButton(
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'logout',
                              child: Row(
                                children: [
                                  Icon(Icons.logout, size: 20),
                                  SizedBox(width: 8),
                                  Text('Logout'),
                                ],
                              ),
                            ),
                          ],
                          onSelected: (value) async {
                            if (value == 'logout') {
                              await AuthService().logout();
                              if (context.mounted) {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const LoginScreen()),
                                );
                              }
                            }
                          },
                          child: const Icon(
                              Icons.person, color: AppColors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      _StatCard(
                        label: 'Total',
                        value: '${provider.medicines.length}',
                        icon: Icons.medication_rounded,
                      ),
                      const SizedBox(width: 12),
                      _StatCard(
                        label: 'Taken',
                        value: '${taken.length}',
                        icon: Icons.check_circle_outline,
                      ),
                      const SizedBox(width: 12),
                      _StatCard(
                        label: 'Pending',
                        value: '${pending.length}',
                        icon: Icons.pending_outlined,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ── Search & Filter Bar ──────────────────────
          if (_showSearchFilter)
            SliverToBoxAdapter(
              child: SearchAndFilterBar(
                onClose: () {
                  setState(() {
                    _showSearchFilter = false;
                  });
                },
              ),
            ),

          // ── Search Toggle Button ─────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: SizedBox(
                height: 40,
                child: ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _showSearchFilter = !_showSearchFilter;
                    });
                  },
                  icon: const Icon(Icons.search),
                  label: Text(_showSearchFilter ? 'Hide Search' : 'Search & Filter'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                  ),
                ),
              ),
            ),
          ),

          // ── Low stock warning ────────────────────────
          if (lowStock.isNotEmpty)
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber_rounded,
                        color: Colors.red.shade600),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${lowStock.map((m) => m.name).join(', ')} need refill soon!',
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // ── Pending section ──────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Upcoming Doses',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  Text(
                    '${pending.length} remaining',
                    style: const TextStyle(color: AppColors.textGrey),
                  ),
                ],
              ),
            ),
          ),

          // ── Pending list ─────────────────────────────
          pending.isEmpty
              ? SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 16),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.check_circle,
                              size: 48, color: Colors.green.shade300),
                          const SizedBox(height: 8),
                          Text(
                            'All medicines taken for today! 🎉',
                            style: TextStyle(color: AppColors.textGrey),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final medicine = pending[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24),
                        child: MedicineCard(
                          medicine: medicine,
                          onTaken: () => context
                              .read<MedicineProvider>()
                              .toggleTaken(medicine.id!),
                        ),
                      );
                    },
                    childCount: pending.length,
                  ),
                ),

          // ── Taken today ──────────────────────────────
          if (taken.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                child: Row(
                  children: [
                    Icon(Icons.check_circle,
                        color: Colors.green.shade400, size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      'Taken Today',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final medicine = taken[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: MedicineCard(
                      medicine: medicine,
                      onTaken: () => context
                          .read<MedicineProvider>()
                          .toggleTaken(medicine.id!),
                    ),
                  );
                },
                childCount: taken.length,
              ),
            ),
          ],

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}

// ── Stat card ──────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final String   label;
  final String   value;
  final IconData icon;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.white, size: 20),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: AppColors.white.withOpacity(0.8),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}