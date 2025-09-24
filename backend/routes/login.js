const express = require("express");
const router = express.Router();
const Login = require("../models/login");

// Register a new user
router.post("/register", async (req, res) => {
  try {
    const { email, password, name, address } = req.body;
    if (!email || !password || !name || !address)
      return res.status(400).json({ error: "Missing fields" });

    // NOTE: For production you MUST hash passwords (bcrypt) and validate inputs.
    const existing = await Login.findOne({ email });
    if (existing)
      return res.status(409).json({ error: "Email already registered" });

    const user = new Login({ email, password, name, address });
    await user.save();
    res.status(201).json({ message: "User created", userId: user._id });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Server error" });
  }
});

// Simple login (plaintext check)
router.post("/login", async (req, res) => {
  try {
    const { email, password } = req.body;
    if (!email || !password)
      return res.status(400).json({ error: "Missing fields" });

    const user = await Login.findOne({ email });
    if (!user) return res.status(401).json({ error: "Invalid credentials" });

    // Replace with bcrypt.compare in real app
    if (user.password !== password)
      return res.status(401).json({ error: "Invalid credentials" });

    res.json({
      message: "Login successful",
      user: { id: user._id, email: user.email, name: user.name },
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Server error" });
  }
});

module.exports = router;
