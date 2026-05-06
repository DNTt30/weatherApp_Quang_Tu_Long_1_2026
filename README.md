# Weather Forecast Application

## Mô tả dự án
Weather Forecast là ứng dụng Flutter cho phép người dùng xem thông tin thời tiết chi tiết, dự báo thời tiết hàng ngày và hàng giờ. Ứng dụng cung cấp giao diện thân thiện với người dùng, responsive design và các tính năng tùy chỉnh.

## Các tính năng chính

### 1. **Màn hình khởi đầu (Home)**
- `lib/home.dart`: Màn hình đầu tiên khi người dùng vào ứng dụng
  - **Header**: Logo/tên app ở bên trái, menu điều hướng ở bên phải (Produce, Solution, Community, Support), nút Đăng nhập/Đăng ký
  - **Responsive**: Ẩn menu và hiển thị hamburger menu khi màn hình hẹp (< 800px)
  - **Body**: Form khảo sát với các trường:
    - Tên
    - Tên đệm
    - Email
    - Tin nhắn gửi đến bên phát triển
  - **Footer**: 3 cột (Kết nối, Trang liên quan, Chính sách) với các liên kết xã hội
  - **Navigation**: Sau khi submit form, người dùng được chuyển đến màn hình ứng dụng chính

### 2. **Màn hình chính (Screen)**
- `lib/screen.dart`: Layout chính với BottomNavigationBar 3 tab
  - **Tab Home**: Hiển thị thông tin thời tiết hiện tại
    - Thành phố hiện tại
    - Nhiệt độ hiện tại
    - Thông tin chi tiết (Mây, Độ ẩm, Gió)
    - Danh sách các thành phố

### 3. **Dự báo thời tiết (Forecast)**
- `lib/forecast.dart`: Hiển thị thông tin dự báo chi tiết
  - Nhiệt độ hôm nay
  - Nhiệt độ từng giờ
  - Nhiệt độ hàng ngày

### 4. **Cài đặt (More)**
- `lib/more.dart`: Các tùy chọn cài đặt
  - Bật/tắt thông báo
  - Chọn vị trí mặc định
  - Đổi theme (sáng/tối)
  - Thông tin phiên bản

### 5. **Quản lý dữ liệu thành phố (ListCity)**
- `lib/listCity.dart`: Quản lý dữ liệu thành phố
  - Lưu trữ thông tin thành phố (tên, tọa độ, yêu thích)
  - Cơ chế CRUD (Create, Read, Update, Delete)

### 6. **Công việc hiện tại (Working)**
- `lib/working.dart`: Các công việc đang phát triển hoặc tính năng thử nghiệm

## Cấu trúc thư mục

```
lib/
├── main.dart                 # Điểm vào ứng dụng
├── home.dart                 # Màn hình khởi đầu (khảo sát)
├── screen.dart               # Màn hình chính ứng dụng
├── forecast.dart             # Màn hình dự báo thời tiết
├── more.dart                 # Màn hình cài đặt
├── listCity.dart             # Quản lý dữ liệu thành phố
├── listWeather.dart          # Quản lý dữ liệu thời tiết
└── working.dart              # Công việc hiện tại/thử nghiệm
```

## Hướng dẫn chạy ứng dụng

### Yêu cầu
- Flutter SDK (phiên bản 3.0 trở lên)
- Dart SDK
- IDE: VS Code hoặc Android Studio

### Cài đặt
```bash
# Clone repository
git clone <repository-url>
cd weatherApp_Quang_Tu_Long_1_2026

# Cài đặt dependencies
flutter pub get

# Chạy ứng dụng
flutter run
```

## Thông tin nhóm
- **Quang**: 21012086
- **Long**: 23010032
- **Tú**: 22010052

**Trường**: Phenikaa University

## Cập nhật gần đây

- Tạo màn hình khởi đầu (home.dart) với form khảo sát responsive
- Cập nhật layout header với responsive design (LayoutBuilder)
- Tích hợp footer cuộn cùng nội dung
- Implement navigation từ màn hình khảo sát sang ứng dụng chính

