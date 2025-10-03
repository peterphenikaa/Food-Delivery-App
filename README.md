# 🍔 Food Delivery App

Một ứng dụng giao đồ ăn trực tuyến hoàn chỉnh với Flutter frontend và Node.js backend, kết nối User, Chef và Shipper với trải nghiệm realtime đầy đủ.

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

## 📱 Screenshots

### Màn hình chính
- Trang chủ với danh sách nhà hàng
- Tìm kiếm và lọc món ăn
- Chi tiết món ăn
- Giỏ hàng

### Quản lý đơn hàng
- Tạo đơn hàng
- Theo dõi trạng thái
- Chat với shipper
- Bản đồ theo dõi

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
