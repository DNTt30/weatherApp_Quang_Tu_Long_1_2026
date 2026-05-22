import 'package:flutter/material.dart';

class CustomBottomBar extends StatelessWidget {
  final VoidCallback? onLocationTap;
  final VoidCallback? onFabTap;
  final VoidCallback? onMenuTap;

  const CustomBottomBar({
    super.key,
    this.onLocationTap,
    this.onFabTap,
    this.onMenuTap,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Container(
          height: 80,
          decoration: BoxDecoration(
            color: Colors.black87.withValues(alpha: 0.7),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Location button
              IconButton(
                onPressed: onLocationTap,
                icon: const Icon(Icons.location_on, color: Colors.white70, size: 28),
              ),
              const Spacer(),
              // Menu button
              IconButton(
                onPressed: onMenuTap,
                icon: const Icon(Icons.menu, color: Colors.white70, size: 28),
              ),
            ],
          ),
        ),
        // Floating action button
        Positioned(
          bottom: 40,
          child: GestureDetector(
            onTap: onFabTap,
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Colors.blue.shade400, Colors.purple.shade400],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withValues(alpha: 0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 32),
            ),
          ),
        ),
      ],
    );
  }
}
