const request = require('supertest');
const express = require('express');
const mongoose = require('mongoose');
const { MongoMemoryServer } = require('mongodb-memory-server');
const authRoutes = require('../routes/users'); // adapte le chemin si différent
const User = require('../models/user');

process.env.JWT_SECRET = 'testsecret';

let app;
let mongoServer;

beforeAll(async () => {
  mongoServer = await MongoMemoryServer.create();
  await mongoose.connect(mongoServer.getUri());

  app = express();
  app.use(express.json());
  app.use('/auth', authRoutes);
}, 20000);

afterAll(async () => {
  await mongoose.disconnect();
  if (mongoServer) await mongoServer.stop();
});

describe('Auth routes', () => {
  const testUser = {
    userName: 'testuser',
    password: 'testpass123',
    fullName: 'Test User'
  };

  it('should register a new user', async () => {
    const res = await request(app).post('/auth/register').send(testUser);

    expect(res.statusCode).toBe(201);
    expect(res.body.message).toBe('Inscription réussie');

    const user = await User.findOne({ userName: testUser.userName });
    expect(user).toBeDefined();
    expect(user.fullName).toBe('Test User');
  });

  it('should log in the registered user and return a JWT token', async () => {
    const res = await request(app).post('/auth/login').send({
      userName: testUser.userName,
      password: testUser.password
    });

    expect(res.statusCode).toBe(200);
    expect(res.body).toHaveProperty('token');
    expect(typeof res.body.token).toBe('string');
  });

  it('should fail to log in with wrong password', async () => {
    const res = await request(app).post('/auth/login').send({
      userName: testUser.userName,
      password: 'wrongpassword'
    });

    expect(res.statusCode).toBe(401);
  });

  it('should fail to log in with unknown user', async () => {
    const res = await request(app).post('/auth/login').send({
      userName: 'nonexistent',
      password: 'any'
    });

    expect(res.statusCode).toBe(401);
  });
});
