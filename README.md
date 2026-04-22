# 🌤️ Ứng dụng Dự báo Thời tiết (Weather App)

**Dự án Bài tập lớn Lập trình Mobile - Nhóm 1 (2026)**

Ứng dụng dự báo thời tiết đa nền tảng được phát triển bằng framework **Flutter**, cho phép người dùng tra cứu tình trạng thời tiết hiện tại, xem dự báo các ngày tới và quản lý danh sách các thành phố yêu thích.

---

## 👥 Danh sách Thành viên & Phân công Nhiệm vụ

Dự án được chia thành các module cốt lõi (Core Objects) áp dụng triệt để tư duy Lập trình Hướng đối tượng (OOP). Dưới đây là phân công chi tiết cho từng thành viên:

### 1. Phụ trách: Long 👨‍💻
**📍 Đối tượng: `City` (Thành phố / Vị trí)**
* **Vai trò:** Đại diện cho một địa điểm cụ thể mà người dùng muốn theo dõi thời tiết.
* **Thuộc tính (Data):** * `id`: Mã định danh thành phố.
  * `name`: Tên thành phố.
  * `latitude`: Vĩ độ.
  * `longitude`: Kinh độ.
  * `isFavorite`: Có nằm trong danh sách yêu thích không (Boolean).
* **Hành vi (Methods):** * Thay đổi trạng thái thêm/xóa khỏi danh sách yêu thích.
  * Hiển thị tọa độ bản đồ chi tiết.

### 2. Phụ trách: Quang 👨‍💻
**☁️ Đối tượng: `Weather` (Thời tiết hiện tại)**
* **Vai trò:** Miêu tả tình trạng thời tiết tại một thời điểm thực tế (real-time) của một `City` cụ thể.
* **Thuộc tính (Data):** * `temperature`: Nhiệt độ hiện tại.
  * `humidity`: Độ ẩm không khí.
  * `windSpeed`: Tốc độ gió.
  * `status`: Trạng thái (Nắng/Mưa/Nhiều mây...).
  * `uvIndex`: Chỉ số tia UV.
  * `icon`: Mã icon đại diện cho thời tiết.
* **Hành vi (Methods):** * Định dạng nhiệt độ ra chuỗi văn bản (VD: "32°C").
  * Đánh giá và cảnh báo mức độ nguy hiểm (nếu tia UV quá cao hoặc tốc độ gió đạt mức có bão).

### 3. Phụ trách: Tú 👨‍💻
**📅 Đối tượng: `Forecast` (Dự báo thời tiết)**
* **Vai trò:** Đại diện cho một khung thời gian dự báo trong tương lai (có thể là dự báo theo từng giờ hoặc theo từng ngày).
* **Thuộc tính (Data):** * `dateTime`: Ngày/Giờ diễn ra dự báo.
  * `minTemp`: Nhiệt độ dự báo thấp nhất.
  * `maxTemp`: Nhiệt độ dự báo cao nhất.
  * `rainProbability`: Xác suất có mưa (%).
* **Hành vi (Methods):** * Tính toán độ chênh lệch nhiệt độ giữa ngày và đêm.

---

## 🚀 Cấu trúc Dự án (Architecture)

Dự án tuân thủ theo cấu trúc phân chia thư mục rõ ràng:
* `lib/models/`: Chứa các lớp định nghĩa Đối tượng (City, Weather, Forecast).
* `lib/screens/`: Chứa các giao diện màn hình chính (Trang chủ, Chi tiết dự báo).
* `lib/widgets/`: Chứa các thành phần UI dùng chung (Sidebar, Card hiển thị thời tiết).

## 🛠️ Hướng dẫn cài đặt

1. Clone repository về máy tính:
   
      git clone https://github.com/DNTt30/weatherApp_Quang_Tu_Long_1_2026.git
2. Di chuyển vào thư mục dự án:

cd weatherApp_Quang_Tu_Long_1_2026

Cài đặt các gói phụ thuộc:

flutter pub get

3. Chạy ứng dụng trên máy ảo hoặc thiết bị thật:

flutter run
