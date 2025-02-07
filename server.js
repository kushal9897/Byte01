const express = require('express');
const client = require('prom-client');

const app = express();
const register = new client.Registry();

// Create default metrics
client.collectDefaultMetrics({ register });

// Custom metrics
const httpRequestDuration = new client.Histogram({
  name: 'http_request_duration_seconds',
  help: 'Duration of HTTP requests in seconds',
  labelNames: ['method', 'route', 'status_code'],
  buckets: [0.1, 0.3, 0.5, 1, 3, 5, 10] // Buckets for latency
});

register.registerMetric(httpRequestDuration);

app.get('/', (req, res) => {
  const end = httpRequestDuration.startTimer();
  res.send('Hello, Prometheus!');
  end({ method: 'GET', route: '/', status_code: 200 });
});

app.get('/metrics', async (req, res) => {
  res.set('Content-Type', register.contentType);
  res.end(await register.metrics());
});

app.listen(3000, () => {
  console.log('Server running on http://localhost:3000');
});






// // Import the built-in http module
// const http = require('http');

// // Create a server that responds with "Hello, World!"
// const server = http.createServer((req, res) => {
//     res.writeHead(200, { 'Content-Type': 'text/plain' });
//     res.end('Hello, World!\n');
// });

// // Define the port the server will listen on
// const PORT = 3000;
// server.listen(PORT, () => {
//     console.log(`Server is running at http://localhost:${PORT}/`);
// });
