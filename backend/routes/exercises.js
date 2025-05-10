const express = require('express');
const router = express.Router();
const Exercise = require('../models/exercise');

// Ajouter un exercice
router.post('/', async (req, res) => {
  try {
    const exercise = new Exercise(req.body);
    await exercise.save();
    res.status(201).send(exercise);
  } catch (error) {
    res.status(400).send(error);
  }
});

// Récupérer tous les exercices
router.get('/', async (req, res) => {
  try {
    const exercises = await Exercise.find();
    res.send(exercises);
  } catch (error) {
    res.status(500).send(error);
  }
});

module.exports = router;
