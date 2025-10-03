require("dotenv").config();
const mongoose = require("mongoose");
const Food = require("./models/food");

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

  const restaurantMongoId = new mongoose.Types.ObjectId('65123f0e8efc71f888d2a112');

  const seedFoods = [
    {
      name: "Burger Classic",
      category: "Burger",
      price: 35000,
      image: "homepageUser/burger_classic.jpg",
      description: "Burger thịt bò ngon với rau xanh tươi và sốt đặc biệt",
      restaurantId: restaurantMongoId,
      isAvailable: true,
      rating: 4.5,
      deliveryTime: 30,
      reviews: [
        { user: 'Alice', rating: 5, comment: 'Rất ngon!', createdAt: new Date() },
        { user: 'Bob', rating: 4, comment: 'Tạm ổn, bánh hơi khô', createdAt: new Date() }
      ],
    },
    {
      name: "Pepperoni Pizza",
      category: "Pizza",
      price: 89000,
      image: "homepageUser/pepperoni_pizza.jpg",
      description: "Pizza pepperoni với phô mai mozzarella thơm ngon",
      restaurantId: restaurantMongoId,
      isAvailable: true,
      rating: 4.7,
      deliveryTime: 25,
      reviews: [
        { user: 'Charlie', rating: 5, comment: 'Phô mai thơm, topping nhiều', createdAt: new Date() }
      ],
    },
    {
      name: "Chicken Sandwich",
      category: "Sandwich",
      price: 45000,
      image: "homepageUser/chicken_sandwich.jpg",
      description: "Sandwich gà nướng với rau tươi và sốt mayonnaise",
      restaurantId: restaurantMongoId,
      isAvailable: true,
      rating: 4.3,
      deliveryTime: 20,
    },
    {
      name: "Hot Dog Special",
      category: "Hot Dog",
      price: 25000,
      image: "homepageUser/hot_dog_special.jpg",
      description: "Hot dog đặc biệt với xúc xích Đức và tương cà",
      restaurantId: restaurantMongoId,
      isAvailable: true,
      rating: 4.2,
      deliveryTime: 30,
    },
    {
      name: "Combo Fast Food",
      category: "Fast Food",
      price: 99000,
      image: "homepageUser/combo_fast_food.jpg",
      description: "Combo gồm burger, khoai tây chiên và nước ngọt",
      restaurantId: restaurantMongoId,
      isAvailable: true,
      rating: 4.6,
      deliveryTime: 18,
    },
    {
      name: "Caesar Salad",
      category: "Salad",
      price: 52000,
      image: "homepageUser/caesar_salad.jpg",
      description: "Salad Caesar với rau xà lách tươi và sốt Caesar đặc biệt",
      restaurantId: restaurantMongoId,
      isAvailable: true,
      rating: 4.4,
      deliveryTime: 15,
    },
    {
      name: "Beef Steak",
      category: "Fast Food",
      price: 120000,
      image: "homepageUser/beef_steak.webp",
      description: "Bít tết thịt bò Úc nướng vừa chín tới",
      restaurantId: restaurantMongoId,
      isAvailable: true,
      rating: 4.8,
      deliveryTime: 35,
    },
    {
      name: "Fish and Chips",
      category: "Fast Food",
      price: 65000,
      image: "homepageUser/fish_and_chips.jpg",
      description: "Cá chiên giòn với khoai tây chiên kiểu Anh",
      restaurantId: restaurantMongoId,
      isAvailable: true,
      rating: 4.1,
      deliveryTime: 25,
    },
    {
      name: "European Pizza",
      category: "Pizza",
      price: 95000,
      image: "homepageUser/european_pizza.jpg",
      description: "Pizza phong cách Châu Âu với hương vị độc đáo và tinh tế",
      restaurantId: restaurantMongoId,
      isAvailable: true,
      rating: 4.7,
      deliveryTime: 30,
      reviews: [
        { user: 'Emma', rating: 5, comment: 'Pizza phong cách Châu Âu tuyệt vời!', createdAt: new Date() }
      ],
    },
    {
      name: "Buffalo Pizza",
      category: "Pizza",
      price: 92000,
      image: "homepageUser/buffano_pizza.jpg",
      description: "Pizza Buffalo với phô mai mozzarella và sốt cay đặc biệt",
      restaurantId: restaurantMongoId,
      isAvailable: true,
      rating: 4.8,
      deliveryTime: 28,
      reviews: [
        { user: 'John', rating: 5, comment: 'Pizza Buffalo cay ngon tuyệt!', createdAt: new Date() }
      ],
    },
  ];

  await Food.deleteMany({});
  const createdFoods = await Food.insertMany(seedFoods);
  console.log(
    "Inserted foods:",
    createdFoods.map((food) => food.name)
  );

  await mongoose.disconnect();
  console.log("Disconnected");
}

run().catch((err) => {
  console.error(err);
  process.exit(1);
});
