var app = require('../app');
var request = require('supertest');

describe('API App', function() {
  describe('GET /health', function() {
    it('should return 200', function(done) {
      request(app)
        .get('/health')
        .expect(200, done);
    });
  });

  describe('GET /noendpoint', function() {
    it('should return 404', function(done) {
      request(app)
        .get('/noendpoint')
        .expect(404, done);
    });
  });
});
