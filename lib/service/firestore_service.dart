import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  CollectionReference get cities =>
      FirebaseFirestore.instance.collection('cities');

  Future<void> addCity() async {
    await cities.add({
      'name': 'Ha Noi',
      'temperature': 32,
      'status': 'Sunny',
    });
  }
}