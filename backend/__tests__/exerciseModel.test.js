const mongoose = require('mongoose');
const { MongoMemoryServer } = require('mongodb-memory-server');
const Exercise = require('../models/exercise');

let mongoServer;

beforeAll(async () => {
  mongoServer = await MongoMemoryServer.create();
  const uri = mongoServer.getUri();
  await mongoose.connect(uri);
}, 20000);

afterAll(async () => {
  await mongoose.disconnect();
  if (mongoServer) {
    await mongoServer.stop();
  }
});

describe('Exercise model', () => {
  it('should create a valid exercise', async () => {
    const validExercise = new Exercise({
      name: 'Pompes',
      muscle: 'Pectoraux',
      type: 'MMA',
      duration: 15,
      description: 'Exercice de base pour les pectoraux.',
      gifFileName: 'pompes.gif',
    });

    const saved = await validExercise.save();
    expect(saved._id).toBeDefined();
    expect(saved.name).toBe('Pompes');
  });

  it('should fail if required fields are missing', async () => {
    const invalidExercise = new Exercise({
      name: 'Pompes',
      // muscle manquant
      type: 'MMA',
      duration: 10,
      description: 'Test',
    });

    let err;
    try {
      await invalidExercise.save();
    } catch (error) {
      err = error;
    }

    expect(err).toBeDefined();
    expect(err.errors.muscle).toBeDefined();
  });
});
