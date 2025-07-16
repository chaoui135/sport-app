const request = require('supertest');
const express = require('express');
const mongoose = require('mongoose');
const { MongoMemoryServer } = require('mongodb-memory-server');
const moodRoutes = require('../routes/moods');
const Mood = require('../models/mood');

let app;
let mongoServer;

beforeAll(async () => {
  mongoServer = await MongoMemoryServer.create();
  await mongoose.connect(mongoServer.getUri());

  app = express();
  app.use(express.json());
  app.use('/api/moods', moodRoutes);
}, 20000);

afterAll(async () => {
  await mongoose.disconnect();
  if (mongoServer) await mongoServer.stop();
});

beforeEach(async () => {
  await Mood.deleteMany({});
});

describe('Mood routes', () => {
  it('enregistre une humeur', async () => {
    const res = await request(app).post('/api/moods').send({ mood: 'Heureux' });
    expect(res.statusCode).toBe(201);
    expect(res.body.mood).toBe('Heureux');
    const moods = await Mood.find();
    expect(moods.length).toBe(1);
    expect(moods[0].mood).toBe('Heureux');
  });

  it('rejette l’ajout d’une humeur sans champ mood', async () => {
    const res = await request(app).post('/api/moods').send({});
    expect(res.statusCode).toBe(500);
  });

  it('récupère l’historique des humeurs', async () => {
    await new Mood({ mood: 'Calme' }).save();
    await new Mood({ mood: 'Stressé' }).save();
    const res = await request(app).get('/api/moods');
    expect(res.statusCode).toBe(200);
    expect(res.body.length).toBe(2);
    expect(res.body[0]).toHaveProperty('mood');
    expect(res.body[1]).toHaveProperty('date');
  });
});
