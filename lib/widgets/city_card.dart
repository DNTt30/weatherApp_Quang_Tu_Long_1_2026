import 'package:flutter/material.dart';
import '../models/city.dart';

class CityCard extends StatefulWidget {
  final City city;
  final double? temperature;
  final VoidCallback? onTap;

  const CityCard({super.key, required this.city, this.temperature, this.onTap});

  @override
  State<CityCard> createState() => _CityCardState();
}

class _CityCardState extends State<CityCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF15233C),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: widget.onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: Colors.blue.shade800,
                ),
                child: const Icon(Icons.location_city, size: 28, color: Colors.white70),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.city.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${widget.temperature?.toStringAsFixed(0) ?? '--'}°',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    widget.city.toggleFavorite();
                  });
                },
                icon: Icon(
                  widget.city.isFavorite ? Icons.star : Icons.star_border,
                  color: widget.city.isFavorite ? Colors.amber : Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
