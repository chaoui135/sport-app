const request = require('supertest');
const express = require('express');
const mongoose = require('mongoose');
const { MongoMemoryServer } = require('mongodb-memory-server');
const usersRoutes = require('../routes/users');

let app, mongo;
beforeAll(async () => {
  mongo = await MongoMemoryServer.create();
  await mongoose.connect(mongo.getUri());
  app = express();
  app.use(express.json());
  app.use('/api/users', usersRoutes);
}, 20000);

afterAll(async () => {
  await mongoose.disconnect();
  await mongo.stop();
});

test('refuse un mot de passe faible', async () => {
  const res = await request(app)
    .post('/api/users/register')
    .send({ userName: 'bob', password: '123456', fullName: 'Bob Test' });
  expect(res.statusCode).toBe(400);
  expect(res.body.message).toMatch(/Mot de passe trop faible/i);
});

test('accepte un mot de passe fort', async () => {
  const res = await request(app)
    .post('/api/users/register')
    .send({ userName: 'alice', password: 'Abcde!23', fullName: 'Alice Test' });
  expect(res.statusCode).toBe(201);
});
