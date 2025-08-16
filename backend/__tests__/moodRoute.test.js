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

test('POST /api/moods with empty body -> 400', async () => {
  const res = await request(app).post('/api/moods').send({});
  expect(res.statusCode).toBe(400);
  expect(res.body).toHaveProperty('message');
});

test('POST /api/moods with valid body -> 201', async () => {
  const res = await request(app).post('/api/moods').send({ mood: 'Calme', user: '68542272a057a62686eea3b1' });
  expect(res.statusCode).toBe(201);
  expect(res.body).toHaveProperty('_id');
});