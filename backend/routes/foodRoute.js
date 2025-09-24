const express = require('express');
const router = express.Router();
const Food = require('../models/food');

router.get('/', async (req, res) => {
  try {
    const foods = await Food.find({});
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
