# README - Phần thực hiện của Quang

## Thành viên thực hiện
- Họ và tên: Lê Minh Quang

## Nội dung được phân công
Quang phụ trách xây dựng đối tượng **Weather** trong project Weather App.

## Đối tượng: Weather
### Vai trò
Đối tượng `Weather` dùng để miêu tả tình trạng thời tiết hiện tại của một thành phố tại một thời điểm thực.

### Thuộc tính
- `id`: mã định danh của bản ghi thời tiết
- `temperature`: nhiệt độ hiện tại
- `humidity`: độ ẩm không khí
- `windSpeed`: tốc độ gió
- `status`: trạng thái thời tiết như nắng, mưa, nhiều mây
- `uvIndex`: chỉ số tia UV
- `icon`: mã icon thời tiết

### Phương thức
- `formatTemperature()`: định dạng nhiệt độ thành chuỗi, ví dụ `32.5°C`
- `evaluateDangerLevel()`: đánh giá mức độ nguy hiểm của thời tiết dựa trên chỉ số UV hoặc trạng thái bão

## File đã thực hiện
- `lib/models/weather.dart`
- `lib/models/list_weather.dart`

## Chức năng đã hoàn thành
### 1. Xây dựng class `Weather`
Class `Weather` mô tả thông tin thời tiết hiện tại với các thuộc tính và phương thức cần thiết cho ứng dụng.

### 2. Xây dựng danh sách `ListWeather`
Class `ListWeather` dùng để quản lý danh sách các đối tượng `Weather`.

### 3. Thực hiện CRUD cơ bản cho `Weather`
- **Create**: tạo và thêm một bản ghi thời tiết vào danh sách
- **Edit**: sửa thông tin một bản ghi thời tiết theo `id`
- **Read**: đọc và hiển thị tất cả bản ghi thời tiết trong danh sách

## Công nghệ sử dụng
- Flutter
- Dart

## Ghi chú
Phần của Quang tập trung vào mô hình dữ liệu thời tiết hiện tại và thao tác quản lý danh sách thời tiết trong project.
