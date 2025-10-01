Food Delivery App


Ứng dụng giao đồ ăn với tính năng quản lý đơn hàng, giỏ hàng, thanh toán và chat thời gian thực.

Mô tả dự án

Dự án này là một ứng dụng Food Delivery được xây dựng với mục tiêu cung cấp trải nghiệm hoàn chỉnh từ phía User, Chef đến Shipper. Ứng dụng hỗ trợ:

Đăng nhập và quản lý tài khoản cho User, Chef và Shipper.

Quản lý sản phẩm, giỏ hàng và thanh toán.

Tính năng chat thời gian thực giữa khách hàng và Shipper.

Cập nhật vị trí Shipper trên bản đồ realtime.

Thiết kế UI/UX tham khảo từ Figma: Link Figma

Các tính năng chính
Task 1: Quản lý tài khoản và Chef

Giao diện đăng nhập/đăng ký cho User và Chef.

Chef Dashboard: nhận đơn, quản lý món ăn, chỉnh sửa thông tin sản phẩm.

Shipper Account: xem thông tin đơn hàng được giao, lịch sử giao hàng.

Task 2: Giao diện User và quản lý giỏ hàng

Trang chủ Client: danh sách sản phẩm, bộ lọc theo loại, giá, đánh giá.

Chi tiết sản phẩm: mô tả, đánh giá, thêm vào giỏ hàng.

Giỏ hàng: CRUD đầy đủ (Thêm, Xóa, Cập nhật số lượng, Xem tổng).

Thanh toán: tích hợp cơ chế thanh toán an toàn.

Database Design: lưu trữ thông tin người dùng, sản phẩm, đơn hàng, giỏ hàng, và thanh toán.

Task 3: Chat và theo dõi vị trí Shipper

WebSocket Chat Realtime: giao tiếp giữa khách hàng và Shipper.

Bản đồ Realtime: hiển thị vị trí Shipper trong quá trình giao hàng.

Thông báo trạng thái đơn hàng: cập nhật liên tục từ Chef và Shipper.

Công nghệ sử dụng

Frontend: ReactJS / VueJS (tuỳ dự án)

Backend: Node.js / Express / NestJS

Realtime & WebSocket: Socket.IO

Database: PostgreSQL / MongoDB

Thanh toán: Stripe / PayPal (tuỳ dự án)

Bản đồ: Google Maps API / Mapbox
