// YÊU CẦU 5: CLASS - Tạo class City với biến và phương thức
class City {
  int id;
  String name;

  City({required this.id, required this.name});

  // Phương thức printName
  void printName() {
    // ignore: avoid_print
    print('City: $name (ID: $id)');
  }
}
