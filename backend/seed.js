// Simple seed script to create example users in MongoDB
require("dotenv").config();
const mongoose = require("mongoose");
const Login = require("./models/login");

const MONGO =
  process.env.MONGO_URL ||
  process.env.MONGO ||
  "mongodb://localhost:27017/FoodDeliveryApp";

async function run() {
  await mongoose.connect(MONGO, {
    useNewUrlParser: true,
    useUnifiedTopology: true,
  });
  console.log("Connected to", MONGO);

  const users = [
    {
      email: "alice@example.com",
      password: "password123", // For demo only. Hash in production.
      name: "Alice Nguyen",
      phoneNumber: "0912345678",
      address: { houseNumber: "12A", ward: "Phuong 1", city: "Ho Chi Minh" },
    },
    {
      email: "bob@example.com",
      password: "password456",
      name: "Bob Tran",
      phoneNumber: "0987654321",
      address: { houseNumber: "45B", ward: "Phuong 2", city: "Ha Noi" },
    },
  ];

  await Login.deleteMany({});
  const created = await Login.insertMany(users);
  console.log(
    "Inserted users:",
    created.map((u) => u.email)
  );
  await mongoose.disconnect();
  console.log("Disconnected");
}

run().catch((err) => {
  console.error(err);
  process.exit(1);
});
