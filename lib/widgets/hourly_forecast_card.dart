import 'package:flutter/material.dart';
import 'dart:ui';

class HourlyForecastCard extends StatelessWidget {
  final String time;
  final String temp;
  final IconData weatherIcon;
  final String probability;
  final bool isActive;

  const HourlyForecastCard({
    super.key,
    required this.time,
    required this.temp,
    required this.weatherIcon,
    required this.probability,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive ? Colors.blue.shade300 : Colors.white24,
          width: isActive ? 2 : 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: isActive
                  ? LinearGradient(
                      colors: [
                        Colors.blue.shade400.withOpacity(0.3),
                        Colors.purple.shade400.withOpacity(0.2),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0.1),
                        Colors.white.withOpacity(0.05),
                      ],
                    ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    time,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Icon(
                    weatherIcon,
                    color: isActive ? Colors.orange : Colors.white70,
                    size: 28,
                  ),
                  Text(
                    probability,
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 11,
                    ),
                  ),
                  Text(
                    temp,
                    style: TextStyle(
                      color: isActive ? Colors.white : Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
