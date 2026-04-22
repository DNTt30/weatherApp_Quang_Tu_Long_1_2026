class CityData {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  bool isFavourite;

  CityData({required this.id, required this.name, required this.latitude, required this.longitude, this.isFavourite = false});
// Phương thức 1: Hiển thị tọa độ địa lý (Đáp ứng yêu cầu Câu 3)
  void displayLocation() {
    print('Vị trí của $name: Vĩ độ $latitude, Kinh độ $longitude');
  }

  // Phương thức 2: Thay đổi trạng thái yêu thích (Đáp ứng yêu cầu Câu 3)
  void toggleFavorite() {
    isFavourite = !isFavourite;
    if (isFavourite) {
      print('Đã thêm $name vào danh sách yêu thích.');
    } else {
      print('Đã xóa $name khỏi danh sách yêu thích.');
    }
  }
}