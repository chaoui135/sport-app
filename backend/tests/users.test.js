const request = require('supertest');
const app = require('../server');

describe('GET /api/users', () => {
  it('doit retourner un code 200 ou 401 selon le middleware', async () => {
    const res = await request(app).get('/api/users');
    expect([200, 401]).toContain(res.statusCode);
  });
});
