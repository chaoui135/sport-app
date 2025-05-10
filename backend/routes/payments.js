// routes/payment.js
const express = require('express');
const router = express.Router();
const { sendEmail } = require('../utils/email');
const Cart = require('../models/cart');

// Traiter le paiement
router.post('/', async (req, res) => {
  try {
    const cart = await Cart.findOne();
    if (!cart || cart.items.length === 0) {
      return res.status(400).json({ message: 'Le panier est vide' });
    }

    // Logique de paiement ici (intégration avec un service de paiement)

    // Envoyer un email de confirmation
    const emailContent = `Merci pour votre achat !\n\nTotal: \$${cart.totalPrice}`;
    await sendEmail(req.body.email, 'Confirmation de commande', emailContent);

    // Vider le panier après le paiement
    cart.items = [];
    cart.totalPrice = 0;
    await cart.save();

    res.status(200).json({ message: 'Paiement réussi et email envoyé' });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

module.exports = router;
