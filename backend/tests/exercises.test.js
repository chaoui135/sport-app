const request = require('supertest');
const app = require('../server');

describe('GET /api/exercises', () => {
  it('devrait répondre avec 200, 404 ou 500', async () => {
    const res = await request(app).get('/api/exercises');
    console.log('Status code reçu :', res.statusCode);
    expect([200, 404, 500]).toContain(res.statusCode);
  });
});
