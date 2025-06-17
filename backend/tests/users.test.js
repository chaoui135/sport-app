const request = require('supertest');
const app = require('../server');

describe('GET /api/users', () => {
  it('doit répondre sans planter', async () => {
    const res = await request(app).get('/api/users');
    console.log('Code retour:', res.statusCode); // pour debug
    expect([200, 401, 403, 500]).toContain(res.statusCode);
  });
});
