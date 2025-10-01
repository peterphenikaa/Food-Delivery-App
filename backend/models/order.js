const mongoose = require("mongoose");

const OrderItemSchema = new mongoose.Schema(
  {
    food: { type: mongoose.Schema.Types.ObjectId, ref: "Food", required: true },
    name: { type: String, required: true },
    quantity: { type: Number, required: true, min: 1 },
    unitPrice: { type: Number, required: true, min: 0 },
    subtotal: { type: Number, required: true, min: 0 },
  },
  { _id: false }
);

const AddressSchema = new mongoose.Schema(
  {
    houseNumber: { type: String, required: true },
    ward: { type: String, required: true },
    city: { type: String, required: true },
  },
  { _id: false }
);

const OrderSchema = new mongoose.Schema(
  {
    user: { type: mongoose.Schema.Types.ObjectId, ref: "Login", required: true, index: true },
    items: { type: [OrderItemSchema], required: true, validate: v => Array.isArray(v) && v.length > 0 },
    deliveryAddress: { type: AddressSchema, required: true },

    // requested: người dùng đã đặt nhưng chưa được chấp nhận
    // preparing: đã được chấp nhận và đang chuẩn bị ("running orders" trên dashboard)
    // delivering: đang giao
    // completed: hoàn thành
    // cancelled: hủy
    status: {
      type: String,
      enum: ["requested", "preparing", "delivering", "completed", "cancelled"],
      default: "requested",
      index: true,
      required: true,
    },

    // Ghi chú của nội bộ (admin/chef) nếu cần
    note: { type: String },
    // Ghi chú của người dùng khi đặt hàng
    userNote: { type: String },

    // Tài chính
    totalQuantity: { type: Number, required: true, min: 1 },
    totalAmount: { type: Number, required: true, min: 0 },

    // Thanh toán
    paymentMethod: { type: String, enum: ["cod", "card", "wallet"], default: "cod" },
    paymentStatus: { type: String, enum: ["unpaid", "paid", "refunded"], default: "paid", index: true },
    paidAt: { type: Date },
  },
  { timestamps: true }
);

module.exports = mongoose.model("Order", OrderSchema);

