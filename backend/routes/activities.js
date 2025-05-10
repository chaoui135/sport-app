// routes/activities.js
const express = require('express');
const Activity = require('../models/activity');
const router = express.Router();



// Ajouter une nouvelle activité
router.post('/', async (req, res) => {
  const { userId, type, duration, distance, caloriesBurned } = req.body;

  const newActivity = new Activity({ userId, type, duration, distance, caloriesBurned });
  await newActivity.save();
  res.status(201).send('Activity recorded');
});

// Récupérer les activités d'un utilisateur
router.get('/:userId', async (req, res) => {
  const activities = await Activity.find({ userId: req.params.userId });
  res.json(activities);
});

module.exports = router;
