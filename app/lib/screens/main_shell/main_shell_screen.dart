import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../config/theme.dart';
import '../forum/forum_screen.dart';
import '../home/home_screen.dart';
import 'science/science_screen.dart';

class MainShellScreen extends StatelessWidget {
  const MainShellScreen({super.key, required this.selectedPath});

  final String selectedPath;

  int get _currentIndex {
    if (selectedPath == '/forum') return 1;
    if (selectedPath == '/science') return 2;
    return 0;
  }

  void _onTap(BuildContext context, int index) {
    if (index == 0) context.go('/');
    if (index == 1) context.go('/forum');
    if (index == 2) context.go('/science');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex.clamp(0, 2),
        children: const [
          HomeScreen(),
          ForumScreen(),
          ScienceScreen(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(
              color: AppColors.cardShadow,
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                  icon: Icons.home_outlined,
                  selectedIcon: Icons.home_rounded,
                  label: '主页',
                  isSelected: _currentIndex == 0,
                  onTap: () => _onTap(context, 0),
                ),
                _NavItem(
                  icon: Icons.forum_outlined,
                  selectedIcon: Icons.forum_rounded,
                  label: '论坛',
                  isSelected: _currentIndex == 1,
                  onTap: () => _onTap(context, 1),
                ),
                _NavItem(
                  icon: Icons.auto_stories_outlined,
                  selectedIcon: Icons.auto_stories_rounded,
                  label: '今日科普',
                  isSelected: _currentIndex == 2,
                  onTap: () => _onTap(context, 2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? selectedIcon : icon,
              size: 26,
              color: isSelected ? AppColors.primary : AppColors.textHint,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? AppColors.primary : AppColors.textHint,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
