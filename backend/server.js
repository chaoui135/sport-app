const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const bodyParser = require('body-parser');
const morgan = require('morgan')
require('dotenv').config();

const healthRoute = require('./routes/health');
const exercisesRoutes = require('./routes/exercises');
const usersRoutes = require('./routes/users');
const activitiesRoutes = require('./routes/activities');
const productRoutes = require('./routes/products');
const cartRoutes = require('./routes/carts');
const moodsRoutes = require('./routes/moods');



const app = express();
const PORT = process.env.PORT || 3000;

// 🔐 Middlewares
app.use(cors());
app.use(bodyParser.json());

// Forcer le JSON
app.use((req, res, next) => {
  res.setHeader('Content-Type', 'application/json');
  next();
});

app.use(morgan('dev'))

// ✅ Route de health check pour Render
app.get('/', (req, res) => {
  res.status(200).json({ message: '🚀 FitVista API is running' });
});

// 🔗 Connexion MongoDB (Atlas ou locale)
mongoose.connect(process.env.DB_URL || 'mongodb://localhost:27017/sports_exercises')
  .then(() => {
    console.log('✅ Connexion à MongoDB réussie');
    app.listen(PORT, () => console.log(`🚀 Serveur sur le port ${PORT}`));
  })
  .catch(err => {
    console.error('❌ Connexion échouée :', err);
  });

// 📦 Routes
app.use('/health', healthRoute);
app.use('/api/exercises', exercisesRoutes);
app.use('/api/users', usersRoutes);
app.use('/api/activities', activitiesRoutes);
app.use('/api/products', productRoutes);
app.use('/api/cart', cartRoutes);
app.use('/api/moods', moodsRoutes);


app.use((err, req, res, next) => {
  console.error('🔥 API error:', err);
  res.status(err.status || 500).json({ message: err.message || 'Erreur serveur' });
});


module.exports = app;
