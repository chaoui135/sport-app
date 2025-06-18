const mongoose = require('mongoose');
const { MongoMemoryServer } = require('mongodb-memory-server');
const User = require('../models/user'); // adapte si chemin différent
const bcrypt = require('bcryptjs');

let mongoServer;

beforeAll(async () => {
  mongoServer = await MongoMemoryServer.create();
  await mongoose.connect(mongoServer.getUri());
}, 20000);

afterAll(async () => {
  await mongoose.disconnect();
  if (mongoServer) await mongoServer.stop();
});

describe('User model', () => {
  it('should create a user and hash the password', async () => {
    const plainPassword = 'mySecret123';

    const user = new User({
      userId: 'u123',
      userName: 'john_doe',
      password: plainPassword,
      fullName: 'John Doe'
    });

    const savedUser = await user.save();

    expect(savedUser._id).toBeDefined();
    expect(savedUser.password).not.toBe(plainPassword);
    const isMatch = await bcrypt.compare(plainPassword, savedUser.password);
    expect(isMatch).toBe(true);
  });

  it('should fail if required fields are missing', async () => {
    const invalidUser = new User({
      userId: 'u456',
      userName: 'jane_doe'
      // password et fullName manquants
    });

    let err;
    try {
      await invalidUser.save();
    } catch (error) {
      err = error;
    }

    expect(err).toBeDefined();
    expect(err.errors.password).toBeDefined();
    expect(err.errors.fullName).toBeDefined();
  });
});
