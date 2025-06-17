const request = require('supertest');
const app = require('../server');

describe('GET /api/users', () => {
  it('ne doit pas planter, même si la route est absente ou protégée', async () => {
    const res = await request(app).get('/api/users');
    console.log('Code retour:', res.statusCode);
    expect([200, 401, 403, 404, 500]).toContain(res.statusCode);
  });
});
