const express = require('express');
const router = express.Router();
const Mood = require('../models/mood');

// POST /api/moods : Enregistrer une humeur
router.post('/', async (req, res) => {
  try {
    const { mood, user } = req.body;
    const moodEntry = new Mood({ mood, user });
    await moodEntry.save();
    res.status(201).json(moodEntry);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// GET /api/moods : Récupérer l’historique des humeurs
router.get('/', async (req, res) => {
  try {
    const moods = await Mood.find().sort({ date: -1 });
    res.json(moods);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
