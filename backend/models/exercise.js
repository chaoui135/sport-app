const mongoose = require('mongoose');

const exerciseSchema = new mongoose.Schema({
  name: { type: String, required: true },
  muscle: { type: String, required: true },
  type: { type: String, required: true }, // 'MMA', 'Lutte', 'Football', 'Natation'
  duration: { type: Number, required: true }, // en minutes
  description: { type: String, required: true },
  gifFileName: { type: String, required: false }, // Nom du fichier GIF dans les assets
});

module.exports = mongoose.model('Exercise', exerciseSchema);
