const mongoose = require('mongoose');
const Restaurant = require('./models/restaurant'); // đúng tên file restaurant.js

mongoose.connect('mongodb://localhost:27017/FoodDeliveryApp')
  .then(async () => {
    // Danh sách 4 nhà hàng mẫu, mỗi nhà hàng có 1-2 review
    const restaurants = [
      {
        name: 'The Pizza Place',
        address: '123 Main St',
        description: 'Pizza ngon nổi tiếng với công thức độc quyền.',
        image: 'homepageUser/pizaa_place.jpg',
        rating: 4.8,
        deliveryTime: 30,
        categories: ['Pizza', 'Drinks'],
        reviews: [
          { user: 'Alice', rating: 5, comment: 'Pizza ngon tuyệt vời!' },
          { user: 'Bob', rating: 4, comment: 'Phục vụ tốt, đồ ăn ngon.' }
        ]
      },
      {
        name: 'American Spicy Burger Shop',
        address: '456 Burger Road',
        description: 'Burger Mỹ cay nồng với gia vị đặc biệt.',
        image: 'homepageUser/american_spicy_burger_shop.jpg',
        rating: 4.6,
        deliveryTime: 25,
        categories: ['Burger', 'American'],
        reviews: [
          { user: 'Charlie', rating: 5, comment: 'Burger cay rất ngon, đúng gu!' }
        ]
      },
      {
        name: 'Cafenio Coffee Club',
        address: '321 Coffee Ave',
        description: 'Quán café phong cách hiện đại với đồ uống và món nhẹ.',
        image: 'homepageUser/Cafenio_coffe_club.jpg',
        rating: 4.5,
        deliveryTime: 20,
        categories: ['Coffee', 'Dessert'],
        reviews: [
          { user: 'David', rating: 5, comment: 'Café ngon, không gian đẹp!' },
          { user: 'Eva', rating: 4, comment: 'Thích các món bánh ngọt ở đây.' }
        ]
      },
      {
        name: 'Panshi Restaurant',
        address: '555 Asian Blvd',
        description: 'Nhà hàng Á Đông với các món ăn đặc sắc.',
        image: 'homepageUser/Panshi_restaurant.jpg',
        rating: 4.9,
        deliveryTime: 30,
        categories: ['Asian', 'Chinese'],
        reviews: [
          { user: 'Frank', rating: 5, comment: 'Món Á tuyệt vời, rất đúng khẩu vị!' }
        ]
      }
    ];

    // Xóa dữ liệu cũ để seed lại nếu muốn
    await Restaurant.deleteMany({});
    await Restaurant.insertMany(restaurants);

    console.log('Seeding restaurants completed!');
    mongoose.disconnect();
  })
  .catch(err => {
    console.error('Error seeding restaurants:', err);
    mongoose.disconnect();
  });
