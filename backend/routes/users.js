const express = require('express');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { v4: uuidv4 } = require('uuid');
const User = require('../models/user');

const router = express.Router();

// 🔐 Inscription
router.post('/register', async (req, res) => {
  const { userName, password, fullName } = req.body;

  try {
    const existingUser = await User.findOne({ userName });
    if (existingUser) {
      return res.status(400).json({ message: 'Nom d\'utilisateur déjà utilisé' });
    }

    const newUser = new User({
      userId: uuidv4(),
      userName,
      password,
      fullName,
    });

    await newUser.save();
    res.status(201).json({ message: 'Inscription réussie' });
  } catch (err) {
    console.error('Erreur inscription :', err);
    res.status(500).json({ message: 'Erreur serveur' });
  }
});

// 🔑 Connexion
router.post('/login', async (req, res) => {
  const { userName, password } = req.body;

  try {
    const user = await User.findOne({ userName });
    if (!user) {
      return res.status(401).json({ message: 'Utilisateur introuvable' });
    }

    const isValid = await bcrypt.compare(password, user.password);
    if (!isValid) {
      return res.status(401).json({ message: 'Mot de passe incorrect' });
    }

    const token = jwt.sign({ userId: user._id }, process.env.JWT_SECRET, { expiresIn: '1h' });

    res.status(200).json({ token });
  } catch (err) {
    console.error('Erreur login :', err);
    res.status(500).json({ message: 'Erreur serveur' });
  }
});

module.exports = router;
