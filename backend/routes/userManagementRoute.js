const express = require('express');
const router = express.Router();
const Login = require('../models/login');

// Lấy danh sách tất cả người dùng
router.get('/', async (req, res) => {
  try {
    const { role } = req.query;
    const filter = role ? { role } : { role: 'user' }; // Default to 'user' if no role specified
    const users = await Login.find(filter).select('-password');
    res.json(users);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Lấy thông tin chi tiết một người dùng
router.get('/:id', async (req, res) => {
  try {
    const user = await Login.findById(req.params.id).select('-password');
    if (!user) {
      return res.status(404).json({ error: 'Không tìm thấy người dùng' });
    }
    res.json(user);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Cập nhật thông tin người dùng
router.put('/:id', async (req, res) => {
  try {
    const { name, email, phoneNumber, address } = req.body;
    
    const updatedUser = await Login.findByIdAndUpdate(
      req.params.id,
      { 
        name, 
        email, 
        phoneNumber, 
        address 
      },
      { new: true }
    ).select('-password');
    
    if (!updatedUser) {
      return res.status(404).json({ error: 'Không tìm thấy người dùng' });
    }
    
    res.json(updatedUser);
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
});

// Xóa người dùng
router.delete('/:id', async (req, res) => {
  try {
    const deletedUser = await Login.findByIdAndDelete(req.params.id);
    if (!deletedUser) {
      return res.status(404).json({ error: 'Không tìm thấy người dùng' });
    }
    res.json({ success: true, message: 'Đã xóa người dùng thành công' });
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
});

// Lấy tổng số lượng người dùng
router.get('/stats/count', async (req, res) => {
  try {
    const { role } = req.query;
    const filter = role ? { role } : { role: 'user' }; // Default to 'user' if no role specified
    const count = await Login.countDocuments(filter);
    res.json({ totalUsers: count });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;
