// models/Activity.js
const mongoose = require('mongoose');

const activitySchema = new mongoose.Schema({
  userId: { type: String, required: true }, // Référence à l'utilisateur
  type: { type: String, required: true }, // Type d'exercice (course, boxe, etc.)
  duration: { type: Number, required: true }, // Durée en minutes
  distance: { type: Number, required: true }, // Distance en kilomètres
  caloriesBurned: { type: Number, required: true }, // Calories brûlées
  date: { type: Date, default: Date.now }, // Date de l'exercice
});

module.exports = mongoose.model('Activity', activitySchema);
