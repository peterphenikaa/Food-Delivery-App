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

  // First, seed restaurants to get their IDs
  const Restaurant = require("./models/restaurant");
  await Restaurant.deleteMany({});
  
  const restaurants = [
    {
      name: 'The Pizza Place',
      address: '123 Main St',
      description: 'Pizza ngon nổi tiếng.',
      image: 'pizza_place.jpg',
      rating: 4.8,
      deliveryTime: 30,
      categories: ['Pizza', 'Salad', 'Drinks'],
      reviews: [
        { user: 'Alice', rating: 5, comment: 'Rất ngon!' },
        { user: 'Bob', rating: 4, comment: 'Phục vụ tốt.' }
      ]
    },
    {
      name: 'Burger Heaven',
      address: '456 Burger Road',
      description: 'Burger thơm ngon, tươi mới.',
      image: 'burger_heaven.jpg',
      rating: 4.5,
      deliveryTime: 25,
      categories: ['Burger', 'Hot Dog', 'Fast Food', 'Fries'],
      reviews: [
        { user: 'Charlie', rating: 5, comment: 'Burger tuyệt vời!' }
      ]
    }
  ];

  const createdRestaurants = await Restaurant.insertMany(restaurants);
  console.log("Inserted restaurants:", createdRestaurants.map(r => r.name));
  
  // Get restaurant IDs
  const pizzaPlaceId = createdRestaurants[0]._id; // The Pizza Place
  const burgerHeavenId = createdRestaurants[1]._id; // Burger Heaven

  const seedFoods = [
    // BURGER HEAVEN - Burger, Hot Dog, Fast Food
    {
      name: "Burger Classic",
      category: "Burger",
      price: 35000,
      image: "assets/homepageUser/burger_img1.jpg",
      description: "Burger thịt bò ngon với rau xanh tươi và sốt đặc biệt",
      restaurantId: burgerHeavenId,
      isAvailable: true,
      rating: 4.5,
      deliveryTime: 30,
      ingredients: ["Bánh burger", "Thịt bò", "Rau xà lách", "Cà chua", "Phô mai", "Sốt đặc biệt"],
      reviews: [
        { user: 'Alice', rating: 5, comment: 'Rất ngon!', createdAt: new Date() },
        { user: 'Bob', rating: 4, comment: 'Tạm ổn, bánh hơi khô', createdAt: new Date() }
      ],
    },
    {
      name: "Hot Dog Special",
      category: "Hot Dog",
      price: 25000,
      image: "assets/homepageUser/restaurant_img2.jpg",
      description: "Hot dog đặc biệt với xúc xích Đức và tương cà",
      restaurantId: burgerHeavenId,
      isAvailable: true,
      rating: 4.2,
      deliveryTime: 30,
      ingredients: ["Bánh mì dài", "Xúc xích Đức", "Tương cà", "Mù tạt"],
    },
    {
      name: "Combo Fast Food",
      category: "Fast Food",
      price: 99000,
      image: "assets/homepageUser/restaurant_img1.jpg",
      description: "Combo gồm burger, khoai tây chiên và nước ngọt",
      restaurantId: burgerHeavenId,
      isAvailable: true,
      rating: 4.6,
      deliveryTime: 18,
      ingredients: ["Burger", "Khoai tây chiên", "Nước ngọt"]
    },
    {
      name: "Beef Steak",
      category: "Fast Food",
      price: 120000,
      image: "assets/homepageUser/restaurant_img1.jpg",
      description: "Bít tết thịt bò Úc nướng vừa chín tới",
      restaurantId: burgerHeavenId,
      isAvailable: true,
      rating: 4.8,
      deliveryTime: 35,
      ingredients: ["Thịt bò", "Muối", "Tiêu", "Bơ", "Tỏi"],
    },
    {
      name: "Fish and Chips",
      category: "Fast Food",
      price: 65000,
      image: "assets/homepageUser/restaurant_img2.jpg",
      description: "Cá chiên giòn với khoai tây chiên kiểu Anh",
      restaurantId: burgerHeavenId,
      isAvailable: true,
      rating: 4.1,
      deliveryTime: 25,
      ingredients: ["Cá tuyết", "Bột chiên giòn", "Khoai tây", "Muối", "Dầu chiên"],
    },
    
    // THE PIZZA PLACE - Pizza, Salad
    {
      name: "Pepperoni Pizza",
      category: "Pizza",
      price: 89000,
      image: "assets/homepageUser/pizza_img1.webp",
      description: "Pizza pepperoni với phô mai mozzarella thơm ngon",
      restaurantId: pizzaPlaceId,
      isAvailable: true,
      rating: 4.7,
      deliveryTime: 25,
      reviews: [
        { user: 'Charlie', rating: 5, comment: 'Phô mai thơm, topping nhiều', createdAt: new Date() }
      ],
    },
    {
      name: "Caesar Salad",
      category: "Salad",
      price: 52000,
      image: "assets/homepageUser/restaurant_img2.jpg",
      description: "Salad Caesar với rau xà lách tươi và sốt Caesar đặc biệt",
      restaurantId: pizzaPlaceId,
      isAvailable: true,
      rating: 4.4,
      deliveryTime: 15,
    },
    {
      name: "Chicken Sandwich",
      category: "Sandwich",
      price: 45000,
      image: "assets/homepageUser/restaurant_img2.jpg",
      description: "Sandwich gà nướng với rau tươi và sốt mayonnaise",
      restaurantId: pizzaPlaceId,
      isAvailable: true,
      rating: 4.3,
      deliveryTime: 20,
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
