var app = require('../app');
var request = require('supertest');

describe('Web App', function() {
  describe('GET /health', function() {
    it('should return 200', function(done) {
      request(app)
        .get('/health')
        .expect(200, done);
    });
  });

  describe('GET /stylesheets/style.css', function() {
    it('should serve static assets', function(done) {
      request(app)
        .get('/stylesheets/style.css')
        .expect(200, done);
    });
  });
});
