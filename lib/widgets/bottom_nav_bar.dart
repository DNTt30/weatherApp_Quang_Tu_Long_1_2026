import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../service/settings_service.dart';

/// BottomNavBar — Purple Glassmorphism Theme
/// Palette: bg #1F1D47 | active #C427FB | inactive #EBEBF5
class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: SettingsService.footerBgColor,
        border: Border(top: BorderSide(color: SettingsService.dividerColor)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(icon: Icons.home_outlined,      activeIcon: Icons.home_rounded,      label: 'Home',     isSelected: currentIndex == 0, onTap: () => onTap(0)),
              _NavItem(icon: Icons.explore_outlined,   activeIcon: Icons.explore_rounded,   label: 'Discover', isSelected: currentIndex == 1, onTap: () => onTap(1)),
              _NavItem(icon: Icons.cloud_outlined,     activeIcon: Icons.cloud_rounded,     label: 'Forecast', isSelected: currentIndex == 2, onTap: () => onTap(2)),
              _NavItem(icon: Icons.person_outline_rounded, activeIcon: Icons.person_rounded, label: 'More',     isSelected: currentIndex == 3, onTap: () => onTap(3)),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(colors: [SettingsService.primaryGradientStart, SettingsService.primaryGradientEnd])
              : null,
          color: isSelected ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSelected
              ? [BoxShadow(color: const Color(0xFFC427FB).withValues(alpha: 0.25), blurRadius: 8, offset: const Offset(0, 2))]
              : [],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
              child: Icon(
                isSelected ? activeIcon : icon,
                key: ValueKey(isSelected),
                color: isSelected ? Colors.white : SettingsService.textMutedColor,
                size: 24,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                color: isSelected ? Colors.white : SettingsService.textMutedColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
