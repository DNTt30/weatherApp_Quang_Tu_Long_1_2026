class City {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  bool isFavorite;

  City({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    this.isFavorite = false,
  });

  void toggleFavorite() {
    isFavorite = !isFavorite;
  }

  Map<String, dynamic> getCityInfo() {
    return toMap();
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'isFavorite': isFavorite,
    };
  }

  factory City.fromMap(Map<String, dynamic> map) {
    final latitudeValue = map['latitude'];
    final longitudeValue = map['longitude'];

    return City(
      id: map['id'] as String,
      name: map['name'] as String,
      latitude: latitudeValue is double
          ? latitudeValue
          : (latitudeValue as num).toDouble(),
      longitude: longitudeValue is double
          ? longitudeValue
          : (longitudeValue as num).toDouble(),
      isFavorite: map['isFavorite'] as bool? ?? false,
    );
  }
}
