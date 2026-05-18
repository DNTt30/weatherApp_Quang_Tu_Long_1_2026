// ============================================================
// Class City — Long phụ trách
// Thuộc tính: id, name, latitude, longitude, isFavorite
// ============================================================
class City {
  int id;
  String name;
  double latitude;
  double longitude;
  bool isFavorite;

  City({
    required this.id,
    required this.name,
    this.latitude = 0.0,
    this.longitude = 0.0,
    this.isFavorite = false,
  });

  // ── Phương thức đổi trạng thái yêu thích ─────────────────
  void toggleFavorite() {
    isFavorite = !isFavorite;
  }

  // ── Phương thức trả về thông tin thành phố ───────────────
  String getCityInfo() {
    return 'Thành phố: $name | Lat: $latitude, Lon: $longitude | Yêu thích: ${isFavorite ? "★" : "☆"}';
  }

  // ── Phương thức in tên thành phố ─────────────────────────
  void printName() {
    // ignore: avoid_print
    print('City: $name (ID: $id)');
  }

  // ── Chuyển sang Map (dùng khi lưu Firestore) ─────────────
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'isFavorite': isFavorite,
    };
  }

  // ── Tạo từ Map (dùng khi đọc Firestore) ─────────────────
  factory City.fromMap(Map<String, dynamic> map) {
    return City(
      id: map['id'] ?? 0,
      name: map['name'] ?? '',
      latitude: (map['latitude'] ?? 0.0).toDouble(),
      longitude: (map['longitude'] ?? 0.0).toDouble(),
      isFavorite: map['isFavorite'] ?? false,
    );
  }

  @override
  String toString() => getCityInfo();
}
