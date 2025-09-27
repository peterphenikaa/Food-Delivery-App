const express = require('express');
const router = express.Router();
const Food = require('../models/food');

// Escape special regex characters in user input
function escapeRegex(text) {
  return text.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
}

router.get('/', async (req, res) => {
  try {
    const { category, search } = req.query;

    const filter = {};

    if (category && category.trim() && category.trim().toLowerCase() !== 'tất cả danh mục') {
      // Case-insensitive exact match on category
      filter.category = new RegExp('^' + escapeRegex(category.trim()) + '$', 'i');
    }

    if (search && search.trim()) {
      const q = escapeRegex(search.trim());
      filter.$or = [
        { name: { $regex: q, $options: 'i' } },
        { description: { $regex: q, $options: 'i' } },
        { category: { $regex: q, $options: 'i' } },
      ];
    }

    // Debug logs to trace filtering behavior
    console.log('[GET /api/foods] query =', req.query);
    console.log('[GET /api/foods] filter =', JSON.stringify(filter));

    const foods = await Food.find(filter);
    res.json(foods);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

router.post('/', async (req, res) => {
  try {
    const newFood = new Food(req.body);
    await newFood.save();
    res.status(201).json(newFood);
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
});

module.exports = router;
