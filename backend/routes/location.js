const express = require("express");
const router = express.Router();
const { client } = require("../redisClient");

// POST /api/location
// Body: { userId, lat, lng, timestamp }
router.post("/", async (req, res) => {
  try {
    const { userId, lat, lng, timestamp } = req.body;
    if (!userId || lat == null || lng == null) {
      return res
        .status(400)
        .json({ error: "Missing fields (userId, lat, lng required)" });
    }

    const item = {
      userId,
      lat: Number(lat),
      lng: Number(lng),
      timestamp: timestamp || Date.now(),
    };

    // Store per-user list: locations:<userId>
    const key = `locations:${userId}`;
    await client.rPush(key, JSON.stringify(item));

    // Optionally trim list to last N items (e.g., 100)
    await client.lTrim(key, -100, -1);

    res.json({ message: "Location saved", item });
  } catch (err) {
    console.error("Error saving location", err);
    res.status(500).json({ error: "Server error" });
  }
});

module.exports = router;
