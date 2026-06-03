import 'package:flutter/material.dart';
import 'package:liquid_glass_easy/liquid_glass_easy.dart';

import 'package:app_ludiprof/Scenes/home/home_view.dart';
import 'package:app_ludiprof/Scenes/dashboard/dashboard_view.dart';
import 'package:app_ludiprof/Scenes/profile/profile_view.dart';
import 'package:app_ludiprof/Design System/Shared/colors.dart';

class MainTabView extends StatefulWidget {
  const MainTabView({super.key});

  @override
  State<MainTabView> createState() => _MainTabViewState();
}

class _MainTabViewState extends State<MainTabView> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomeView(),
    const DashboardView(),
    const ProfileView(),
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final navBarWidth = screenWidth - 48; // 24px margin each side

    return Scaffold(
      body: LiquidGlassView(
        backgroundWidget: _pages[_currentIndex],
        realTimeCapture: true,
        children: [
          LiquidGlassBottomNavBar(
            width: navBarWidth,
            height: 64,
            bottomMargin: MediaQuery.of(context).padding.bottom + 16,
            items: const [
              LiquidGlassTabBarItem(
                icon: Icons.menu_book_outlined,
                selectedIcon: Icons.menu_book,
                label: 'Inicio',
              ),
              LiquidGlassTabBarItem(
                icon: Icons.bar_chart_outlined,
                selectedIcon: Icons.bar_chart,
                label: 'Estatisticas',
              ),
              LiquidGlassTabBarItem(
                icon: Icons.person_outline,
                selectedIcon: Icons.person,
                label: 'Perfil',
              ),
            ],
            selectedIndex: _currentIndex,
            onChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            // #9FD9FF at 30% opacity for selected tab
            selectionColor: AppColors.primary.withValues(alpha: 0.30),
            selectedItemColor: AppColors.textPrimary,
            unselectedItemColor: AppColors.textSecondary,
            glassColor: AppColors.primary.withValues(alpha: 0.25),
          ),
        ],
      ),
    );
  }
}
