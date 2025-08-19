const mongoose = require('mongoose');
const { MongoMemoryServer } = require('mongodb-memory-server');
const Product = require('../models/product');

let mongoServer;

beforeAll(async () => {
  mongoServer = await MongoMemoryServer.create();
  await mongoose.connect(mongoServer.getUri());
}, 20000);

afterAll(async () => {
  await mongoose.disconnect();
  if (mongoServer) await mongoServer.stop();
});

describe('Product model', () => {
  it('should create a product with valid data', async () => {
    const validProduct = new Product({
      name: 'Tapis de yoga',
      description: 'Antidérapant et confortable',
      price: 29.99,
      imageUrl: 'https://example.com/yoga.jpg',
      category: 'Fitness'
    });

    const saved = await validProduct.save();
    expect(saved._id).toBeDefined();
    expect(saved.name).toBe('Tapis de yoga');
  });

  it('should fail with missing required fields', async () => {
    const invalidProduct = new Product({
      name: 'Chaise romaine',
      price: 89.99,
      imageUrl: 'https://example.com/chaise.jpg'
      // description et category manquants
    });

    let err;
    try {
      await invalidProduct.save();
    } catch (error) {
      err = error;
    }

    expect(err).toBeDefined();
    expect(err.errors.description).toBeDefined();
    expect(err.errors.category).toBeDefined();
  });
});
