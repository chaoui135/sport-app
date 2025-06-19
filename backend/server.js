const express = require('express');
const mongoose = require('mongoose');
const bodyParser = require('body-parser');
const cors = require('cors');

const exercisesRoutes = require('./routes/exercises');
const usersRoutes = require('./routes/users');
const activitiesRoutes = require('./routes/activities');
const productRoutes = require('./routes/products');
const cartRoutes = require('./routes/carts');
const paymentRoutes = require('./routes/payments');

require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;

// Middlewares
app.use(cors());
app.use(bodyParser.json());
app.use((req, res, next) => {
  console.log(`${req.method} ${req.url}`);
  next();
});

// Connexion à MongoDB Atlas
mongoose.connect(process.env.DB_URL)
  .then(() => {
    console.log('✅ Connexion à MongoDB Atlas réussie');
    app.listen(PORT, () => {
      console.log(`🚀 Serveur démarré sur le port ${PORT}`);
    });
  })
  .catch((err) => {
    console.error('❌ Erreur de connexion à MongoDB Atlas :', err);
  });

// Routes
app.use('/api/exercises', exercisesRoutes);
app.use('/api/users', usersRoutes);
app.use('/api/activities', activitiesRoutes);
app.use('/api/products', productRoutes);
app.use('/api/cart', cartRoutes);
app.use('/api/payment', paymentRoutes);

module.exports = app;

