import 'package:flutter/material.dart';
import '../models/city.dart';
import 'city_card.dart';

class ListCity extends StatelessWidget {
  final List<City> cities;

  const ListCity({super.key, required this.cities});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: cities.length,
      itemBuilder: (context, index) {
        final c = cities[index];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6.0),
          child: CityCard(city: c, temperature: 24 + index.toDouble()),
        );
      },
    );
  }
}
