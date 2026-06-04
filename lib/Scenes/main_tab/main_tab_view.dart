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
  late final PageController _pageController;

  final List<Widget> _pages = [
    const HomeView(),
    const DashboardView(),
    const ProfileView(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final navBarWidth = screenWidth - 48; // 24px margin each side

    return Scaffold(
      body: LiquidGlassView(
        backgroundWidget: Stack(
          children: [
            PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              children: _pages,
            ),
            // Shadow layer placed in the background so it is drawn behind the navbar
            Align(
              alignment: Alignment.bottomCenter,
              child: IgnorePointer(
                child: Container(
                  width: navBarWidth,
                  height: 64,
                  margin: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom + 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        realTimeCapture: true,
        refreshRate: LiquidGlassRefreshRate.medium,
        children: [
          LiquidGlassBottomNavBar(
            width: navBarWidth,
            height: 64,
            chromaticAberration: 0,
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
              _pageController.animateToPage(
                index,
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOutCubic,
              );
            },
            // #9FD9FF at 30% opacity for selected tab
            selectionColor: AppColors.primary.withValues(alpha: 0.30),
            selectedItemColor: AppColors.textPrimary,
            unselectedItemColor: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }
}
