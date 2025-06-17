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

// Connexion à MongoDB
mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/sports_exercises', {
  useNewUrlParser: true,
  useUnifiedTopology: true,
});

// Routes
app.use('/api/exercises', exercisesRoutes);
app.use('/api/users', usersRoutes);
app.use('/api/activities', activitiesRoutes);
app.use('/api/products', productRoutes);
app.use('/api/cart', cartRoutes);
app.use('/api/payment', paymentRoutes);

// Si ce fichier est exécuté directement, on lance le serveur
if (require.main === module) {
  app.listen(PORT, () => {
    console.log(`Serveur démarré sur le port ${PORT}`);
  });
}

module.exports = app;
