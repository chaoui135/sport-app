const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
require('dotenv').config();

// Import des routes
const exercisesRoutes = require('./routes/exercises');
const usersRoutes = require('./routes/users');
const activitiesRoutes = require('./routes/activities');
const productRoutes = require('./routes/products');
const cartRoutes = require('./routes/carts');
const paymentRoutes = require('./routes/payments');

const app = express();
const PORT = process.env.PORT || 3000;

// ✅ Middlewares
app.use(cors());
app.use(express.json()); // IMPORTANT pour recevoir le body JSON
app.use(express.urlencoded({ extended: true }));

// Logger simple
app.use((req, res, next) => {
  console.log(`${req.method} ${req.url}`);
  next();
});

// ✅ Health check route pour Render
app.get('/', (req, res) => {
  res.status(200).send('🚀 FitVista API is running');
});

// ✅ Connexion MongoDB
mongoose.connect(process.env.DB_URL || 'mongodb://localhost:27017/sports_exercises')
  .then(() => {
    console.log('✅ Connexion à MongoDB réussie');
    app.listen(PORT, () => {
      console.log(`🚀 Serveur Express sur le port ${PORT}`);
    });
  })
  .catch(err => {
    console.error('❌ Connexion MongoDB échouée :', err);
  });

// ✅ Routes API
app.use('/api/exercises', exercisesRoutes);
app.use('/api/users', usersRoutes);
app.use('/api/activities', activitiesRoutes);
app.use('/api/products', productRoutes);
app.use('/api/cart', cartRoutes);
app.use('/api/payment', paymentRoutes);

module.exports = app;
