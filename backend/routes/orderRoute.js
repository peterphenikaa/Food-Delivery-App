const express = require("express");
const router = express.Router();
const Order = require("../models/order");

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


