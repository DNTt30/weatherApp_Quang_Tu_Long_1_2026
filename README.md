# 🌤️ Weather App — Nhóm 1
### Trường Đại học Phenikaa | Khoa Công nghệ Thông tin | Môn: Lập Trình Di Động

---

## 👥 Thành viên nhóm

| STT | Họ và Tên | MSSV | Màn hình phụ trách | Vai trò |
|-----|-----------|------|-------------------|---------|
| 1 | Dương Ngọc Tú | 22010052 | About / More Screen | Git Manager, Docs |
| 2 | Ngô Thành Long | 23010032 | Home Screen | Developer |
| 3 | Lê Minh Quang | 21012086 | Forecast Screen | Developer |

---

## 🔗 Links quan trọng

| Mục | Link |
|-----|------|
| 📁 **Git Repository** | https://github.com/DNTt30/weatherApp_Quang_Tu_Long_1_2026 |
| 🎬 **Demo YouTube** | *(Cập nhật sau khi quay video)* |

---

## 📱 Giới thiệu dự án

**Weather App** là ứng dụng xem thời tiết được xây dựng bằng **Flutter** kết hợp **Firebase**, thuộc dự án học kỳ môn Lập Trình Di Động — Đại học Phenikaa.

### Tính năng chính:
- 🔐 **Đăng ký / Đăng nhập** bằng Firebase Authentication
- 🏙️ **Xem thời tiết** 5 thành phố Việt Nam (Hà Nội, Đà Nẵng, HCM, Hải Phòng, Cần Thơ)
- 📊 **Dự báo 5 ngày** với biểu đồ xác suất mưa
- 🗃️ **So sánh thành phố** bằng bảng dữ liệu
- 📈 **Thống kê** nhiệt độ TB, độ ẩm, số ngày mưa
- ☁️ **Kết nối Firestore** — lưu thêm thành phố vào NoSQL
- 👤 **About screen** giới thiệu nhóm & thành viên

---

## 🛠️ Công nghệ sử dụng

| Thành phần | Công nghệ | Phiên bản |
|-----------|-----------|----------|
| Framework | Flutter | SDK ^3.11.3 |
| Language | Dart | - |
| Authentication | Firebase Auth | ^6.5.1 |
| Database | Cloud Firestore | ^6.4.1 |
| Core | Firebase Core | ^4.9.0 |
| Font | Google Fonts | ^6.2.1 |
| Icons | Material Icons | built-in |

---

## 📂 Cấu trúc dự án

```
lib/
├── main.dart                   # App entry point, MainShell, routing
├── firebase_options.dart        # Firebase configuration
│
├── models/
│   ├── weather.dart             # Class Weather (city, temp, status, humidity, isRaining)
│   ├── forecast.dart            # Class Forecast (id, dateTime, min/maxTemp, rainProbability)
│   └── city.dart                # Class City (id, name)
│
├── screens/
│   ├── login_screen.dart        # Đăng nhập (US-02)
│   ├── register_screen.dart     # Đăng ký (US-01)
│   ├── home_screen.dart         # Thời tiết hiện tại (US-03,04,05,06,09) — Long
│   ├── content_screen.dart      # Dự báo chi tiết (US-07,08) — Quang
│   └── about_screen.dart        # Giới thiệu nhóm (US-10) — Tú
│
├── service/
│   ├── auth_service.dart        # Firebase Auth wrapper (signIn, signUp, signOut)
│   └── firestore_service.dart   # Firestore CRUD (addCity)
│
└── widgets/
    ├── bottom_nav_bar.dart      # Bottom Navigation Bar (3 tab)
    ├── app_drawer.dart          # Side Drawer
    └── shared_widgets.dart      # GroupPhotoHeader, MemberInfoFooter, AppConstants

test/
└── widget_test.dart             # 25 Unit Tests (Model + Business Logic + Widget)
```

---

## 🏗️ Kiến trúc & Thiết kế

### Object Classes

| Class | Thuộc tính | Phương thức |
|-------|-----------|-------------|
| `Weather` | city, temperature, status, humidity, isRaining | `getWeatherInfo()` |
| `Forecast` | id, dateTime, minTemp, maxTemp, rainProbability | `getForecast()`, `getTemperatureDifference()` |
| `City` | id, name | `printName()` |
| `AuthService` | _auth, _db | `signIn()`, `signUp()`, `signOut()` |
| `FirestoreService` | cities | `addCity()` |

### Firestore Collections

```
Firestore (NoSQL):
├── users/{uid}
│   ├── uid: String
│   ├── email: String
│   ├── username: String
│   └── createdAt: Timestamp
└── cities/{auto-id}
    ├── name: String
    ├── temperature: Number
    └── status: String
```

---

## 🚀 Hướng dẫn cài đặt & chạy

### Yêu cầu hệ thống
- Flutter SDK >= 3.11.3
- Dart >= 3.0
- Android Studio / VS Code
- Firebase project đã cấu hình

### Bước 1: Clone repository
```bash
git clone https://github.com/DNTt30/weatherApp_Quang_Tu_Long_1_2026.git
cd weatherApp_Quang_Tu_Long_1_2026
```

### Bước 2: Cài đặt dependencies
```bash
flutter pub get
```

### Bước 3: Chạy ứng dụng
```bash
flutter run
```

### Bước 4: Chạy unit tests
```bash
flutter test
```

---

## 🧪 Unit Tests (25 Test Cases)

| Nhóm | Số test | Mô tả |
|------|---------|-------|
| Weather Model | 5 | Khởi tạo, getWeatherInfo(), edge cases |
| Forecast Model | 6 | Khởi tạo, getTemperatureDifference(), getForecast() |
| City Model | 3 | Khởi tạo, danh sách, edge case |
| Business Logic | 6 | Phân loại thời tiết, tính toán thống kê |
| Widget Tests | 5 | LoginScreen, WeatherCard, BottomNav, AppBar |
| **Tổng** | **25** | |

---

## 🎨 Thiết kế UI

### Bảng màu
| Tên | Hex | Dùng cho |
|-----|-----|---------|
| Primary Blue | `#1565C0` | AppBar, tiêu đề, nút |
| Light Blue | `#1E88E5` | Card header, accent |
| Sky Blue | `#42A5F5` | Gradient end |
| Amber | `#FFB300` | Icon nắng |
| Dark Navy | `#2E335A` | Login background |
| Purple | `#48319D` | Login gradient |

### Font
- **Poppins** — font chính toàn app (Google Fonts)
- **Inter** — About screen
- **Lora** — About screen heading

---

## 📊 Phân công & Commits

| Thành viên | Files chính | Nội dung commit |
|-----------|-------------|----------------|
| **Ngô Thành Long** | `home_screen.dart` | HomeScreen: Weather card, City selector, 5-day forecast, Firestore button |
| **Lê Minh Quang** | `content_screen.dart` | ForecastScreen: Detailed forecast, city comparison table, stat cards |
| **Dương Ngọc Tú** | `about_screen.dart`, `README.md` | AboutScreen, Git management, documentation |
| **Chung (nhóm)** | `main.dart`, `auth_service.dart`, `models/`, `widgets/` | Core framework, Firebase Auth, shared components |

---

## 📋 User Stories

| ID | Câu chuyện |
|----|-----------|
| US-01 | Người dùng **đăng ký** tài khoản mới bằng email, username, mật khẩu |
| US-02 | Người dùng **đăng nhập** bằng email & mật khẩu |
| US-03 | Xem **thời tiết hiện tại** của thành phố đang chọn |
| US-04 | **Chọn thành phố** từ danh sách chip ngang |
| US-05 | Xem **dự báo 5 ngày** kế tiếp |
| US-06 | Xem **chi tiết**: nhiệt độ min/max, xác suất mưa, độ ẩm |
| US-07 | **So sánh thời tiết** giữa các thành phố trong bảng |
| US-08 | Xem **thống kê tổng quan** (nhiệt độ TB, độ ẩm TB, số ngày mưa) |
| US-09 | **Thêm thành phố** vào Firestore NoSQL |
| US-10 | Xem **trang About** với thông tin nhóm & thành viên |
| US-11 | **Đăng xuất** khỏi tài khoản |

---

## ✅ Checklist hoàn thiện

- [x] Đăng ký / Đăng nhập Firebase Auth
- [x] Màn hình Home (Long) — Weather card, City selector, 5-day forecast
- [x] Màn hình Forecast (Quang) — Detailed cards, comparison table, stats
- [x] Màn hình About (Tú) — Team info, personal intro
- [x] Kết nối Firestore NoSQL (addCity)
- [x] Bottom Navigation Bar (3 tab, IndexedStack)
- [x] GroupPhotoHeader & MemberInfoFooter trên tất cả màn hình
- [x] 25 Unit Tests (flutter test)
- [x] Git Repository public
- [ ] Demo YouTube video
- [ ] Báo cáo in chuẩn Phenikaa

---

*Dự án thuộc môn Lập Trình Di Động — Đại học Phenikaa — Học kỳ 2, Năm học 2025-2026*