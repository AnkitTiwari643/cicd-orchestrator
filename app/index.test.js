const test = require('node:test');
const assert = require('node:assert');
const app = require('./index');

test('health route is registered', () => {
  const routes = app._router.stack
    .filter((l) => l.route)
    .map((l) => l.route.path);
  assert.ok(routes.includes('/health'));
});

test('version route is registered', () => {
  const routes = app._router.stack
    .filter((l) => l.route)
    .map((l) => l.route.path);
  assert.ok(routes.includes('/api/version'));
});
