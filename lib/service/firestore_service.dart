import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  // Collection Reference cho bảng 'cities' chung
  CollectionReference get cities =>
      FirebaseFirestore.instance.collection('cities');

  // Collection Reference cho 'weather'
  CollectionReference get weather =>
      FirebaseFirestore.instance.collection('weather');

  // Collection Reference cho 'forecasts'
  CollectionReference get forecasts =>
      FirebaseFirestore.instance.collection('forecasts');
  // 1. CRUD cho danh sách Thành Phố (cities collection)
  // ==========================================

  // [C]reate: Thêm thành phố mới vào Firestore
  Future<DocumentReference> addCity(Map<String, dynamic> cityData) async {
    return await cities.add({
      ...cityData,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // [C]reate / Update: Lưu thông tin thời tiết vào Firestore (Quang phụ trách)
  Future<void> saveWeather(String cityName, Map<String, dynamic> weatherData) async {
    await weather.doc(cityName).set({
      ...weatherData,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // [C]reate / Update: Lưu thông tin dự báo vào Firestore (Tú phụ trách)
  Future<void> saveForecast(String cityName, List<Map<String, dynamic>> forecastData) async {
    await forecasts.doc(cityName).set({
      'data': forecastData,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // [R]ead: Đọc danh sách tất cả thành phố từ Firestore
  Stream<QuerySnapshot> getCitiesStream() {
    return cities.orderBy('createdAt', descending: true).snapshots();
  }

  // [U]pdate: Cập nhật thông tin thời tiết của một thành phố
  Future<void> updateCity(String docId, Map<String, dynamic> updatedData) async {
    await cities.doc(docId).update({
      ...updatedData,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // [D]elete: Xóa thành phố khỏi Firestore
  Future<void> deleteCity(String docId) async {
    await cities.doc(docId).delete();
  }

  // ==========================================
  // 2. CRUD cho danh sách Yêu Thích của User (Sub-collection)
  // ==========================================

  // [C]reate / [D]elete: Thêm hoặc Xóa thành phố yêu thích
  Future<void> toggleFavoriteCity(String cityName, bool isFavorite) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .doc(cityName);

    if (isFavorite) {
      await docRef.set({
        'name': cityName,
        'addedAt': FieldValue.serverTimestamp(),
      });
    } else {
      await docRef.delete();
    }
  }

  // [R]ead: Lấy danh sách thành phố yêu thích của User
  Future<List<String>> getFavoriteCities() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];

    final querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .get();

    return querySnapshot.docs.map((doc) => doc.id).toList();
  }

  // ==========================================
  // 3. Lịch sử Hoạt động (Search History)
  // ==========================================

  // Ghi lại lịch sử xem thành phố
  Future<void> saveSearchHistory(String cityName) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Sử dụng docId tự động để tạo bản ghi mới mỗi lần tìm kiếm
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('history')
        .add({
      'cityName': cityName,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // Lấy lịch sử xem (giới hạn 10 bản ghi gần nhất)
  Future<List<Map<String, dynamic>>> getSearchHistory() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];

    final querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('history')
        .orderBy('timestamp', descending: true)
        .limit(10)
        .get();

    return querySnapshot.docs.map((doc) => doc.data()).toList();
  }
}