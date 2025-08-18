const express = require('express');
const mongoose = require('mongoose');
const Mood = require('../models/mood');

const router = express.Router();

// Valeurs d'humeur autorisées
const ALLOWED_MOODS = ['Heureux', 'Triste', 'Stressé', 'Calme', 'Neutre'];

/**
 * POST /api/moods — Enregistrer une humeur
 */
router.post('/', async (req, res, next) => {
  try {
    const { mood, user } = req.body || {};

    // 1) Champs requis
    if (!mood || typeof mood !== 'string') {
      return res
        .status(400)
        .json({ message: "Champ 'mood' requis (string)", fields: ['mood'] });
    }
    if (!user) {
      return res
        .status(400)
        .json({ message: "Champ 'user' requis (ObjectId)", fields: ['user'] });
    }

    // 2) Valeur d'humeur autorisée
    if (!ALLOWED_MOODS.includes(mood)) {
      return res
        .status(400)
        .json({ message: "Valeur 'mood' invalide", allowed: ALLOWED_MOODS });
    }

    // 3) user doit être un ObjectId MongoDB valide
    if (!mongoose.isValidObjectId(user)) {
      return res
        .status(400)
        .json({ message: "Identifiant 'user' invalide (ObjectId attendu)" });
    }

    // 4) Création
    const doc = await Mood.create({ mood, user });
    return res.status(201).json(doc);
  } catch (err) {
    // Mappe les erreurs Mongoose en 400
    if (err?.name === 'ValidationError' || err?.name === 'CastError') {
      return res.status(400).json({ message: 'Données invalides' });
    }
    return next(err); // laisser le handler global gérer le reste
  }
});

/**
 * GET /api/moods — Historique des humeurs
 */
router.get('/', async (req, res, next) => {
  try {
    const moods = await Mood.find().sort({ createdAt: -1 });
    return res.status(200).json(moods);
  } catch (err) {
    return next(err);
  }
});

module.exports = router;