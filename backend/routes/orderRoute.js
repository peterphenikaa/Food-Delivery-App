const express = require('express');
const router = express.Router();
const Order = require('../models/order');

// POST /api/orders - Create new order
router.post('/', async (req, res) => {
  try {
    const { userId, userName, userPhone, items, subtotal, deliveryFee, serviceFee, total, deliveryAddress, note, estimatedDeliveryTime, restaurantName, restaurantAddress } = req.body;
    
    if (!userId || !userName || !userPhone || !items || !total || !deliveryAddress) {
      return res.status(400).json({ error: 'Missing required fields' });
    }

    const orderId = `ORD${Date.now()}${Math.random().toString(36).substr(2, 9).toUpperCase()}`;
    
    const order = new Order({
      orderId,
      userId,
      userName,
      userPhone,
      items,
      subtotal,
      deliveryFee: deliveryFee || 15000,
      serviceFee: serviceFee || 0,
      total,
      deliveryAddress,
      note,
      status: 'PENDING',
      estimatedDeliveryTime: estimatedDeliveryTime || '20-30 phút',
      restaurantName,
      restaurantAddress,
    });

    await order.save();
    res.status(201).json({ message: 'Order created', order });
  } catch (err) {
    console.error('Error creating order:', err);
    res.status(500).json({ error: 'Server error' });
  }
});

// GET /api/orders - Get all orders (with optional status filter)
router.get('/', async (req, res) => {
  try {
    const { status, shipperId } = req.query;
    const filter = {};
    if (status) filter.status = status;
    if (shipperId) filter.shipperId = shipperId;
    
    const orders = await Order.find(filter).sort({ createdAt: -1 });
    res.json(orders);
  } catch (err) {
    console.error('Error fetching orders:', err);
    res.status(500).json({ error: 'Server error' });
  }
});

// GET /api/orders/:id - Get order by ID
router.get('/:id', async (req, res) => {
  try {
    const order = await Order.findOne({ orderId: req.params.id });
    if (!order) return res.status(404).json({ error: 'Order not found' });
    res.json(order);
  } catch (err) {
    console.error('Error fetching order:', err);
    res.status(500).json({ error: 'Server error' });
  }
});

// PUT /api/orders/:id/assign - Assign shipper to order
router.put('/:id/assign', async (req, res) => {
  try {
    const { shipperId, shipperName } = req.body;
    if (!shipperId || !shipperName) {
      return res.status(400).json({ error: 'Missing shipperId or shipperName' });
    }

    const order = await Order.findOne({ orderId: req.params.id });
    if (!order) return res.status(404).json({ error: 'Order not found' });
    
    if (order.status !== 'PENDING') {
      return res.status(400).json({ error: 'Order already assigned or completed' });
    }

    order.shipperId = shipperId;
    order.shipperName = shipperName;
    order.status = 'ASSIGNED';
    order.updatedAt = Date.now();
    await order.save();

    res.json({ message: 'Order assigned', order });
  } catch (err) {
    console.error('Error assigning order:', err);
    res.status(500).json({ error: 'Server error' });
  }
});

// PUT /api/orders/:id/status - Update order status
router.put('/:id/status', async (req, res) => {
  try {
    const { status } = req.body;
    if (!status) return res.status(400).json({ error: 'Missing status' });

    const order = await Order.findOne({ orderId: req.params.id });
    if (!order) return res.status(404).json({ error: 'Order not found' });

    order.status = status;
    order.updatedAt = Date.now();
    await order.save();

    res.json({ message: 'Status updated', order });
  } catch (err) {
    console.error('Error updating status:', err);
    res.status(500).json({ error: 'Server error' });
  }
});

module.exports = router;

