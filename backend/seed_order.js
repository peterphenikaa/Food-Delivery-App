require("dotenv").config();
const mongoose = require("mongoose");
const Order = require("./models/order");
const Food = require("./models/food");
const Login = require("./models/login");

const MONGO =
  process.env.MONGO_URL || process.env.MONGO || "mongodb://localhost:27017/FoodDeliveryApp";

function makeItem(food, qty) {
  const unit = Number(food.price) || 0;
  const quantity = qty;
  const subtotal = unit * quantity;
  return {
    food: food._id,
    name: food.name,
    quantity,
    unitPrice: unit,
    subtotal,
  };
}

async function run() {
  await mongoose.connect(MONGO, { useNewUrlParser: true, useUnifiedTopology: true });
  console.log("Connected to", MONGO);

  const users = await Login.find({}).limit(2);
  if (users.length === 0) throw new Error("No users found. Run seed.js first");

  const foods = await Food.find({}).limit(6);
  if (foods.length < 2) throw new Error("Not enough foods. Run seed_food.js first");

  await Order.deleteMany({});

  const address = (u) => ({
    houseNumber: u.address?.houseNumber || "1",
    ward: u.address?.ward || "Ward 1",
    city: u.address?.city || "Ho Chi Minh",
  });

  const now = new Date();
  function shiftDays(d, n) {
    const x = new Date(d);
    x.setDate(x.getDate() + n);
    return x;
  }

  const docs = [
    // requested (order request - chưa chấp nhận)
    {
      user: users[0]._id,
      items: [makeItem(foods[0], 2), makeItem(foods[1], 1)],
      deliveryAddress: address(users[0]),
      status: "requested",
      userNote: "Không cay, thêm tương cà",
      totalQuantity: 3,
      totalAmount: makeItem(foods[0], 2).subtotal + makeItem(foods[1], 1).subtotal,
      paymentMethod: "cod",
      paymentStatus: "paid",
      paidAt: shiftDays(now, -1),
      createdAt: shiftDays(now, -1),
      updatedAt: shiftDays(now, -1),
    },
    // preparing (đơn đang xử lý)
    {
      user: users[0]._id,
      items: [makeItem(foods[2], 1)],
      deliveryAddress: address(users[0]),
      status: "preparing",
      userNote: "Giao nhanh giúp mình",
      totalQuantity: 1,
      totalAmount: makeItem(foods[2], 1).subtotal,
      paymentMethod: "cod",
      paymentStatus: "paid",
      paidAt: shiftDays(now, -0),
      createdAt: shiftDays(now, -0),
      updatedAt: shiftDays(now, -0),
    },
    // completed (đã thanh toán) - dùng cho doanh thu
    {
      user: users[1]?._id || users[0]._id,
      items: [makeItem(foods[3] || foods[0], 2)],
      deliveryAddress: address(users[1] || users[0]),
      status: "completed",
      userNote: "",
      totalQuantity: 2,
      totalAmount: makeItem(foods[3] || foods[0], 2).subtotal,
      paymentMethod: "card",
      paymentStatus: "paid",
      paidAt: shiftDays(now, -3),
      createdAt: shiftDays(now, -3),
      updatedAt: shiftDays(now, -2),
    },
    // delivering
    {
      user: users[1]?._id || users[0]._id,
      items: [makeItem(foods[4] || foods[1], 1), makeItem(foods[5] || foods[2], 1)],
      deliveryAddress: address(users[1] || users[0]),
      status: "delivering",
      userNote: "Gọi trước khi tới",
      totalQuantity: 2,
      totalAmount: makeItem(foods[4] || foods[1], 1).subtotal + makeItem(foods[5] || foods[2], 1).subtotal,
      paymentMethod: "cod",
      paymentStatus: "paid",
      paidAt: shiftDays(now, -2),
      createdAt: shiftDays(now, -2),
      updatedAt: shiftDays(now, -2),
    },
  ];

  const created = await Order.insertMany(docs);
  console.log("Inserted orders:", created.map((o) => `${o.status}:${o.totalAmount}`));

  await mongoose.disconnect();
  console.log("Disconnected");
}

run().catch((err) => {
  console.error(err);
  process.exit(1);
});


