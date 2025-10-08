# 🍔 Food Delivery App

[![Flutter](https://img.shields.io/badge/Flutter-3.9.0+-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev/)
[![Node.js](https://img.shields.io/badge/Node.js-16.0+-339933?style=for-the-badge&logo=node.js&logoColor=white)](https://nodejs.org/)
[![MongoDB](https://img.shields.io/badge/MongoDB-4.4+-47A248?style=for-the-badge&logo=mongodb&logoColor=white)](https://mongodb.com/)
[![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)](LICENSE)

Một ứng dụng giao đồ ăn trực tuyến hoàn chỉnh với Flutter frontend và Node.js backend, kết nối User, Chef và Shipper với trải nghiệm realtime đầy đủ.

> 📋 **Xem báo cáo đầy đủ**: [Báo cáo bài tập lớn Kĩ Thuật Phần Mềm - Food Delivery App](https://docs.google.com/document/d/1UKzzk9Ut9GU6Quh3QzpFtDKEdpyo0j8d/edit)  
> 📱 **Demo ứng dụng**: Tất cả screenshots và demo được trình bày chi tiết trong **Chương 5** của báo cáo

## 📱 Tổng quan

Dự án Food Delivery App mô phỏng quy trình đặt món – nấu – giao với các tính năng:
- Quản lý tài khoản User, Chef và Shipper
- Quản lý sản phẩm, giỏ hàng và thanh toán
- Chat thời gian thực giữa khách hàng và Shipper
- Cập nhật vị trí Shipper trên bản đồ realtime
- Thiết kế giao diện tham khảo từ Figma

## 🛠️ Công nghệ sử dụng

### Frontend
- **Flutter** 3.9.0+ (Dart SDK)
- **Provider** - State management
- **HTTP** - API calls
- **Shared Preferences** - Local storage
- **Geolocator** - Location services
- **Permission Handler** - Device permissions

### Backend
- **Node.js** + **Express.js**
- **MongoDB** - Database
- **Redis** - Caching
- **CORS** - Cross-origin requests
- **Mongoose** - ODM

## 🚀 Cài đặt và chạy dự án

### Yêu cầu hệ thống

- **Node.js** 16.0+ 
- **Flutter** 3.9.0+
- **MongoDB** 4.4+
- **Redis** 6.0+ (optional)
- **Git**

### 1. Clone repository

```bash
git clone <repository-url>
cd Food-Delivery-App
```

### 2. Cài đặt Backend

```bash
cd backend
npm install
```

#### Cấu hình môi trường

Tạo file `.env` trong thư mục `backend`:

```env
# Database
MONGO_URL=mongodb://localhost:27017/FoodDeliveryApp
# hoặc MongoDB Atlas
# MONGO_URL=mongodb+srv://username:password@cluster.mongodb.net/FoodDeliveryApp

# Redis (optional)
REDIS_URL=redis://localhost:6379

# Server
PORT=3000
```

#### Chạy Backend

```bash
# Development mode
npm run dev

# Production mode
npm start

# Seed dữ liệu mẫu
npm run seed
```

Backend sẽ chạy tại: `http://localhost:3000`

### 3. Cài đặt Frontend

```bash
cd frontend
flutter pub get
```

#### Chạy Frontend

```bash
# Chạy trên web
flutter run -d chrome

# Chạy trên Android
flutter run

# Chạy trên iOS
flutter run -d ios
```

## 🗄️ Cấu trúc Database

### Models chính

#### User/Login
```javascript
{
  email: String,
  password: String,
  name: String,
  phoneNumber: String,
  address: {
    houseNumber: String,
    ward: String,
    city: String
  },
  role: String // 'user', 'shipper', 'admin'
}
```

#### Restaurant
```javascript
{
  name: String,
  address: String,
  phone: String,
  rating: Number,
  deliveryTime: Number,
  image: String
}
```

#### Food
```javascript
{
  name: String,
  image: String,
  description: String,
  category: String,
  price: Number,
  restaurantId: ObjectId,
  isAvailable: Boolean,
  rating: Number,
  deliveryTime: Number,
  reviews: [ReviewSchema]
}
```

#### Order
```javascript
{
  orderId: String,
  userId: String,
  userName: String,
  userPhone: String,
  items: [OrderItemSchema],
  subtotal: Number,
  deliveryFee: Number,
  serviceFee: Number,
  total: Number,
  deliveryAddress: String,
  note: String,
  status: String, // 'PENDING', 'ASSIGNED', 'PICKED_UP', 'DELIVERING', 'DELIVERED', 'CANCELLED'
  shipperId: ObjectId,
  shipperName: String,
  restaurantName: String,
  restaurantAddress: String,
  estimatedDeliveryTime: String
}
```

## 🔌 API Endpoints

### Authentication
- `POST /api/auth/register` - Đăng ký tài khoản
- `POST /api/auth/login` - Đăng nhập
- `GET /api/auth/users/:id` - Lấy thông tin user
- `GET /api/auth/profile` - Lấy profile user hiện tại

### Restaurants
- `GET /api/restaurants` - Lấy danh sách nhà hàng
- `GET /api/restaurants/:id` - Lấy chi tiết nhà hàng

### Foods
- `GET /api/foods` - Lấy danh sách món ăn
- `GET /api/foods/search?q=keyword` - Tìm kiếm món ăn
- `GET /api/foods/category/:category` - Lấy món theo danh mục
- `GET /api/foods/restaurant/:restaurantId` - Lấy món theo nhà hàng

### Orders
- `POST /api/orders` - Tạo đơn hàng mới
- `GET /api/orders` - Lấy danh sách đơn hàng
- `GET /api/orders/:id` - Lấy chi tiết đơn hàng
- `PUT /api/orders/:id/status` - Cập nhật trạng thái đơn hàng
- `PUT /api/orders/:id/assign` - Gán shipper cho đơn hàng

### Addresses
- `GET /api/addresses/:userId` - Lấy địa chỉ của user
- `POST /api/addresses` - Thêm địa chỉ mới
- `PUT /api/addresses/:id` - Cập nhật địa chỉ
- `DELETE /api/addresses/:id` - Xóa địa chỉ

### Location
- `POST /api/location/geocode` - Chuyển đổi tọa độ thành địa chỉ
- `POST /api/location/reverse-geocode` - Chuyển đổi địa chỉ thành tọa độ

## 🎯 Tính năng chính

### 👤 Quản lý tài khoản
- Đăng ký/Đăng nhập cho User, Chef, Shipper
- Quản lý profile và địa chỉ
- Phân quyền theo vai trò

### 🏪 Quản lý nhà hàng & món ăn
- Danh sách nhà hàng với rating và thời gian giao
- Tìm kiếm món ăn theo tên, danh mục
- Chi tiết món ăn với hình ảnh, mô tả, đánh giá
- Quản lý món ăn cho Chef

### 🛒 Giỏ hàng & Thanh toán
- Thêm/sửa/xóa món trong giỏ hàng
- Tính toán phí giao hàng và phí dịch vụ
- Thanh toán an toàn
- Lưu trữ giỏ hàng local

### 📦 Quản lý đơn hàng
- Tạo đơn hàng từ giỏ hàng
- Theo dõi trạng thái đơn hàng realtime
- Gán shipper cho đơn hàng
- Cập nhật vị trí giao hàng

### 🗺️ Dịch vụ vị trí
- Lấy vị trí hiện tại
- Tìm kiếm địa chỉ
- Chuyển đổi tọa độ ↔ địa chỉ
- Quản lý nhiều địa chỉ giao hàng

### 💬 Chat & Thông báo
- Chat realtime giữa khách hàng và shipper
- Thông báo trạng thái đơn hàng
- Cập nhật vị trí shipper trên bản đồ

## 🧪 Testing

### Test Backend API

```bash
cd backend

# Test với curl
curl http://localhost:3000/api/restaurants
curl http://localhost:3000/api/foods

# Test tạo đơn hàng
curl -X POST http://localhost:3000/api/orders \
  -H "Content-Type: application/json" \
  -d '{
    "userId": "user123",
    "userName": "Test User",
    "userPhone": "0123456789",
    "items": [{"foodId": "food_id", "name": "Pizza", "quantity": 1, "price": 100000}],
    "subtotal": 100000,
    "total": 115000,
    "deliveryAddress": "123 Test Street"
  }'
```

### Test Frontend

```bash
cd frontend

# Chạy tests
flutter test

# Chạy integration tests
flutter drive --target=test_driver/app.dart
```

### Test Database

```bash
# Kết nối MongoDB
mongosh mongodb://localhost:27017/FoodDeliveryApp

# Xem collections
show collections

# Xem dữ liệu
db.restaurants.find()
db.foods.find()
db.orders.find()
```

## 📊 Báo cáo và Demo

### 📋 Báo cáo chi tiết
Xem báo cáo đầy đủ về dự án Food Delivery App tại:
**[📄 Báo cáo bài tập lớn Kĩ Thuật Phần Mềm - Food Delivery App](https://docs.google.com/document/d/1UKzzk9Ut9GU6Quh3QzpFtDKEdpyo0j8d/edit)**

Báo cáo bao gồm:
- 📖 **Chương 1**: Giới thiệu và mục tiêu dự án
- 🔧 **Chương 2**: Phân tích yêu cầu và thiết kế hệ thống
- 🏗️ **Chương 3**: Kiến trúc và công nghệ sử dụng
- 💻 **Chương 4**: Triển khai và phát triển
- 📱 **Chương 5**: Demo và Screenshots ứng dụng
- 📈 **Chương 6**: Đánh giá và kết luận

### 🎬 Demo ứng dụng
Tất cả ảnh demo và screenshots của ứng dụng được trình bày chi tiết trong **Chương 5** của báo cáo, bao gồm:

#### 👤 Giao diện người dùng (User)
- 🏠 **Trang chủ**: Danh sách nhà hàng với rating và thời gian giao
- 🔍 **Tìm kiếm**: Tìm kiếm món ăn theo tên và danh mục
- 🍕 **Chi tiết món**: Thông tin chi tiết, đánh giá và đặt món
- 🛒 **Giỏ hàng**: Quản lý món ăn và tính toán tổng tiền
- 📦 **Đặt hàng**: Form đặt hàng với địa chỉ giao
- 📍 **Theo dõi đơn**: Trạng thái đơn hàng và vị trí shipper
- 💬 **Chat**: Giao tiếp với shipper trong quá trình giao hàng

#### 🏪 Giao diện nhà hàng (Restaurant/Admin)
- 📊 **Dashboard**: Thống kê đơn hàng và doanh thu
- 🍽️ **Quản lý món**: Thêm, sửa, xóa món ăn
- 📋 **Đơn hàng**: Xem và cập nhật trạng thái đơn hàng
- 👥 **Quản lý shipper**: Phân công shipper cho đơn hàng
- 📈 **Báo cáo**: Thống kê doanh thu và đánh giá

#### 🚚 Giao diện shipper
- 📱 **Đơn hàng được giao**: Danh sách đơn hàng được phân công
- 🗺️ **Bản đồ**: Định vị và chỉ đường đến địa chỉ giao
- 📞 **Liên hệ**: Chat với khách hàng và nhà hàng
- ✅ **Cập nhật trạng thái**: Báo cáo tiến độ giao hàng

### 🎯 Tính năng nổi bật được demo
- ⚡ **Realtime**: Cập nhật trạng thái đơn hàng và chat realtime
- 🗺️ **GPS Tracking**: Theo dõi vị trí shipper trên bản đồ
- 🔔 **Push Notifications**: Thông báo trạng thái đơn hàng
- 💳 **Thanh toán**: Tích hợp phương thức thanh toán
- 📊 **Analytics**: Dashboard thống kê cho admin
- 🔐 **Authentication**: Đăng nhập/đăng ký với phân quyền

## 🔧 Troubleshooting

### Lỗi thường gặp

#### Backend không kết nối được MongoDB
```bash
# Kiểm tra MongoDB đang chạy
sudo systemctl status mongod

# Khởi động MongoDB
sudo systemctl start mongod
```

#### Frontend không kết nối được API
- Kiểm tra backend đang chạy tại port 3000
- Kiểm tra CORS settings
- Kiểm tra network configuration cho Android emulator

#### Lỗi permissions trên mobile
- Cấp quyền location cho app
- Cấp quyền camera cho chụp ảnh
- Cấp quyền storage cho lưu trữ

### Debug

```bash
# Backend logs
cd backend && npm run dev

# Frontend logs
cd frontend && flutter run --verbose

# Database logs
mongosh --eval "db.setLogLevel(2)"
```

## 📈 Performance

### Optimization đã áp dụng
- Lazy loading cho danh sách món ăn
- Caching với Redis
- Image optimization
- State management với Provider
- Database indexing

### Monitoring
- API response time
- Database query performance
- Memory usage
- Network requests

## 🙏 Acknowledgments

- Flutter team cho framework tuyệt vời
- MongoDB team cho database mạnh mẽ
- Node.js community cho ecosystem phong phú
- Figma design community cho inspiration
