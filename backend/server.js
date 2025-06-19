const express = require('express');
const mongoose = require('mongoose');
const bodyParser = require('body-parser');
const cors = require('cors');
require('dotenv').config();

const exercisesRoutes = require('./routes/exercises');
const usersRoutes = require('./routes/users');
const activitiesRoutes = require('./routes/activities');
const productRoutes = require('./routes/products');
const cartRoutes = require('./routes/carts');
const paymentRoutes = require('./routes/payments');

const app = express();
const PORT = process.env.PORT || 3000;

// Middlewares
app.use(cors());
app.use(bodyParser.json());
app.use((req, res, next) => {
  console.log(`${req.method} ${req.url}`);
  next();
});

// Connexion à MongoDB (Atlas en prod, local sinon)
mongoose.connect(process.env.DB_URL || 'mongodb://localhost:27017/sports_exercises', {
  useNewUrlParser: true,
  useUnifiedTopology: true
})
.then(() => {
  console.log('✅ Connexion à MongoDB réussie');
  app.listen(PORT, () => {
    console.log(`🚀 Serveur Express sur le port ${PORT}`);
  });
})
.catch(err => {
  console.error('❌ Connexion MongoDB échouée :', err);
});

// Routes
app.use('/api/exercises', exercisesRoutes);
app.use('/api/users', usersRoutes);
app.use('/api/activities', activitiesRoutes);
app.use('/api/products', productRoutes);
app.use('/api/cart', cartRoutes);
app.use('/api/payment', paymentRoutes);

// ✅ Route de confirmation pour Render
app.get('/', (req, res) => {
  res.send('🚀 API FitVista is running!');
});

module.exports = app;
