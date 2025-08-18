const request = require('supertest');
const express = require('express');
const mongoose = require('mongoose');
const { MongoMemoryServer } = require('mongodb-memory-server');
const moodRoutes = require('../routes/moods');

let app, mongoServer;

beforeAll(async () => {
  mongoServer = await MongoMemoryServer.create();
  await mongoose.connect(mongoServer.getUri());
  app = express();
  app.use(express.json());
  app.use('/api/moods', moodRoutes);
}, 20000);

afterAll(async () => {
  await mongoose.disconnect();
  await mongoServer.stop();
});

test('POST /api/moods user manquant -> 400', async () => {
  const r = await request(app).post('/api/moods').send({ mood: 'Calme' });
  expect(r.status).toBe(400);
});

test('POST /api/moods user ObjectId invalide -> 400', async () => {
  const r = await request(app).post('/api/moods').send({ mood: 'Calme', user: 'not-an-id' });
  expect(r.status).toBe(400);
});

test('POST /api/moods mood hors liste -> 400', async () => {
  const r = await request(app).post('/api/moods').send({
    mood: 'Fâché',
    user: new mongoose.Types.ObjectId().toString()
  });
  expect(r.status).toBe(400);
});

test('POST /api/moods valide -> 201', async () => {
  const r = await request(app).post('/api/moods').send({
    mood: 'Calme',
    user: new mongoose.Types.ObjectId().toString()
  });
  expect(r.status).toBe(201);
  expect(r.body).toHaveProperty('_id');
});
