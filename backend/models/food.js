const mongoose = require('mongoose');

const ReviewSchema = new mongoose.Schema({
  user: { type: String, required: true },
  rating: { type: Number, required: true },
  comment: { type: String, required: true },
  createdAt: { type: Date, default: Date.now }
});

const FoodSchema = new mongoose.Schema({
  name: { type: String, required: true },
  image: { type: String },
  description: { type: String },
  category: { type: String, required: true },
  price: { type: Number, required: true },
  restaurantId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Restaurant',
    required: true
  },
  isAvailable: { type: Boolean, default: true },
  rating: { type: Number, default: 0 },
  deliveryTime: { type: Number, default: 30 },
  reviews: [ReviewSchema]
});

module.exports = mongoose.model('Food', FoodSchema);
