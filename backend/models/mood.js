const mongoose = require('mongoose');

const MoodSchema = new mongoose.Schema({
  user: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: false }, // Optionnel, si tu veux rattacher l’humeur à un utilisateur
  mood: { type: String, required: true },
  date: { type: Date, default: Date.now }
});

module.exports = mongoose.model('Mood', MoodSchema);
