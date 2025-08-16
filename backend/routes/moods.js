

const express = require('express');
const router = express.Router();
const Mood = require('../models/mood');

// POST /api/moods — Enregistrer une humeur
router.post('/', async (req, res, next) => {
  try {
    const { mood, user } = req.body || {};

    // ✅ Validation d'entrée
    if (!mood || typeof mood !== 'string') {
      return res.status(400).json({ message: "Champ 'mood' requis (string)" });
    }

    // Optionnel : restreindre aux valeurs attendues
    const allowed = ['Heureux', 'Triste', 'Stressé', 'Calme', 'Neutre'];
    if (!allowed.includes(mood)) {
      return res.status(400).json({ message: "Valeur 'mood' invalide" });
    }

    const moodEntry = new Mood({ mood, user });
    await moodEntry.save();

    return res.status(201).json(moodEntry);
  } catch (err) {
    next(err);
  }
});

// GET /api/moods — Historique
router.get('/', async (req, res, next) => {
  try {
    const moods = await Mood.find().sort({ date: -1 });
    res.json(moods);
  } catch (err) {
    next(err);
  }
});

module.exports = router;