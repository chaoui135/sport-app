// models/cart.js
const mongoose = require('mongoose');

const cartItemSchema = new mongoose.Schema({
  productId: { type: mongoose.Schema.Types.ObjectId, ref: 'Product', required: true },
  quantity: { type: Number, required: true, default: 1 },
});

const cartSchema = new mongoose.Schema({
  items: [cartItemSchema],
  totalPrice: { type: Number, default: 0 },
});

module.exports = mongoose.model('Cart', cartSchema);

