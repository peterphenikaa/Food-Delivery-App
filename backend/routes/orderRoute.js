const express = require("express");
const router = express.Router();
const mongoose = require('mongoose');
const Order = require('../models/order');
const Food = require('../models/food');
const Restaurant = require('../models/restaurant');

// POST /api/orders - Create new order
router.post('/', async (req, res) => {
  try {
    const { userId, userName, userPhone, items, subtotal, deliveryFee, serviceFee, total, deliveryAddress, note, estimatedDeliveryTime } = req.body;
    
    if (!userId || !userName || !userPhone || !items || !total || !deliveryAddress) {
      return res.status(400).json({ error: 'Missing required fields' });
    }

    // Get restaurant info from the first food item's restaurantId
    let restaurantName = 'Unknown Restaurant';
    let restaurantAddress = 'Unknown Address';

    if (items && items.length > 0) {
      try {
        // Get the first food item to find restaurantId
        const firstItem = items[0];
        if (firstItem.foodId) {
          const food = await Food.findById(firstItem.foodId);
          if (food && food.restaurantId) {
            const restaurant = await Restaurant.findById(food.restaurantId);
            if (restaurant) {
              restaurantName = restaurant.name;
              restaurantAddress = restaurant.address;
            }
          }
        }
      } catch (err) {
        console.error('Error fetching restaurant info:', err);
        // Use default values if restaurant lookup fails
      }
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

    if (!mongoose.Types.ObjectId.isValid(shipperId)) {
      return res.status(400).json({ error: 'Invalid shipperId format' });
    }

    order.shipperId = new mongoose.Types.ObjectId(shipperId);
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

// PUT /api/orders/:id/cancel - Cancel order (by user/shipper)
router.put('/:id/cancel', async (req, res) => {
  try {
    const order = await Order.findOne({ orderId: req.params.id });
    if (!order) return res.status(404).json({ error: 'Order not found' });

    order.status = 'CANCELLED';
    order.shipperId = undefined;
    order.shipperName = undefined;
    order.updatedAt = Date.now();
    await order.save();

    res.json({ message: 'Order cancelled', order });
  } catch (err) {
    console.error('Error cancelling order:', err);
    res.status(500).json({ error: 'Server error' });
  }
});
// GET /api/orders/stats/counters
// running = status "preparing"; requests = status "requested"
router.get("/stats/counters", async (req, res) => {
  try {
    const [running, requests] = await Promise.all([
      Order.countDocuments({ status: "preparing" }),
      Order.countDocuments({ status: "requested" }),
    ]);
    res.json({ running, requests });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Server error" });
  }
});

// GET /api/orders/stats/revenue
// Query: granularity = daily|weekly|monthly (default daily)
//        days/weeks/months = number of recent periods to include (default 7 for daily)
//        paidOnly = true|false (default true)
router.get("/stats/revenue", async (req, res) => {
  try {
    const granularity = (req.query.granularity || "daily").toLowerCase();
    const paidOnly = (req.query.paidOnly || "true").toLowerCase() === "true";

    const match = {};
    if (paidOnly) match.paymentStatus = "paid";

    const now = new Date();

    if (granularity === "daily") {
      // Current week (Mon-Fri) labels T2..T6
      const labels = ["T2", "T3", "T4", "T5", "T6"];
      const cur = new Date(now);
      const dow = (cur.getDay() + 6) % 7; // Mon=0
      const monday = new Date(cur);
      monday.setDate(cur.getDate() - dow);
      const out = [];
      for (let i = 0; i < 5; i++) {
        const d0 = new Date(monday.getFullYear(), monday.getMonth(), monday.getDate() + i);
        const d1 = new Date(monday.getFullYear(), monday.getMonth(), monday.getDate() + i + 1);
        const sumRows = await Order.aggregate([
          { $match: { ...match, createdAt: { $gte: d0, $lt: d1 } } },
          { $group: { _id: null, totalAmount: { $sum: "$totalAmount" } } },
        ]);
        const sum = sumRows.length ? sumRows[0].totalAmount : 0;
        const tooltip = `${String(d0.getDate()).padStart(2, "0")}/${String(d0.getMonth() + 1).padStart(2, "0")}/${d0.getFullYear()}`;
        out.push({ period: labels[i], total: sum, tooltip });
      }
      return res.json({ series: out });
    }

    if (granularity === "weekly") {
      const firstOfMonth = new Date(now.getFullYear(), now.getMonth(), 1);
      const nextMonth = new Date(now.getFullYear(), now.getMonth() + 1, 1);
      const out = [];
      let cursor = new Date(firstOfMonth);
      // align to Monday of the week containing the 1st
      const day = cursor.getDay();
      const diffToMon = (day + 6) % 7; // 0=>Mon
      cursor.setDate(cursor.getDate() - diffToMon);
      for (let idx = 0; idx < 4; idx++) {
        const weekStart = new Date(cursor);
        const weekEnd = new Date(weekStart);
        weekEnd.setDate(weekStart.getDate() + 7); // exclusive end
        const startClamped = new Date(Math.max(weekStart.getTime(), firstOfMonth.getTime()));
        const endClampedExclusive = new Date(Math.min(weekEnd.getTime(), nextMonth.getTime()));

        const sumRows = await Order.aggregate([
          { $match: { ...match, createdAt: { $gte: startClamped, $lt: endClampedExclusive } } },
          { $group: { _id: null, totalAmount: { $sum: "$totalAmount" } } },
        ]);
        const sum = sumRows.length ? sumRows[0].totalAmount : 0;

        const endInclusive = new Date(endClampedExclusive.getTime() - 24 * 60 * 60 * 1000);
        const tooltip = `${String(startClamped.getDate()).padStart(2, "0")} - ${String(endInclusive.getDate()).padStart(2, "0")}/${String(endInclusive.getMonth() + 1).padStart(2, "0")}/${endInclusive.getFullYear()}`;
        out.push({ period: `Tuần ${idx + 1}`, total: sum, tooltip });
        cursor.setDate(cursor.getDate() + 7);
        if (cursor >= nextMonth) break;
      }
      return res.json({ series: out });
    }

    // monthly: last 6 months
    const startMonth = new Date(now.getFullYear(), now.getMonth() - 4, 1); // last 5 months
    const pipeline = [
      { $match: { ...match, createdAt: { $gte: startMonth } } },
      { $addFields: { month: { $dateTrunc: { date: "$createdAt", unit: "month" } } } },
      { $group: { _id: "$month", totalAmount: { $sum: "$totalAmount" } } },
      { $sort: { _id: 1 } },
    ];
    const rows = await Order.aggregate(pipeline);
    const out = [];
    for (let i = 4; i >= 0; i--) {
      const m = new Date(now.getFullYear(), now.getMonth() - i, 1);
      const found = rows.find((r) => {
        const d = new Date(r._id);
        return d.getFullYear() === m.getFullYear() && d.getMonth() === m.getMonth();
      });
      const label = `${String(m.getMonth() + 1).padStart(2, "0")}/${m.getFullYear()}`;
      const tooltip = label; // mm/yyyy
      out.push({ period: label, total: found ? found.totalAmount : 0, tooltip });
    }
    return res.json({ series: out });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Server error" });
  }
});

module.exports = router;

// GET /api/orders/stats/top-foods?limit=3
// Returns top N foods by aggregated ordered quantity from PAID orders
router.get("/stats/top-foods", async (req, res) => {
  try {
    const limit = Math.max(1, Math.min(parseInt(req.query.limit) || 3, 10));
    const pipeline = [
      { $match: { paymentStatus: "paid" } },
      { $unwind: "$items" },
      {
        $group: {
          _id: { $ifNull: ["$items.food", "$items.foodId"] },
          totalQuantity: { $sum: "$items.quantity" }
        }
      },
      { $sort: { totalQuantity: -1 } },
      { $limit: limit },
      {
        $lookup: {
          from: "foods",
          localField: "_id",
          foreignField: "_id",
          as: "food"
        }
      },
      { $unwind: "$food" },
      {
        $project: {
          _id: 0,
          id: "$food._id",
          name: "$food.name",
          image: "$food.image",
          price: "$food.price",
          category: "$food.category",
          restaurantId: "$food.restaurantId",
          totalQuantity: 1
        }
      }
    ];
    const rows = await Order.aggregate(pipeline);
    return res.json(rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Server error" });
  }
});
