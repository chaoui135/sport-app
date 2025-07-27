const express = require('express');
const mongoose = require('mongoose');

const router = express.Router();

router.get('/', (req, res) => {
  const mongoStatus = mongoose.connection.readyState; // 1 = connecté
  res.status(200).json({
    status: 'ok',
    mongo: mongoStatus === 1 ? 'connected' : 'disconnected',
  });
});

module.exports = router;
