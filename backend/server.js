const http = require('http');
const tasks = require('./src/handlers/tasks');

const PORT = process.env.PORT || 3001;

const router = async (req, res) => {
  // CORS headers
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');

  // Handle preflight
  if (req.method === 'OPTIONS') {
    res.writeHead(200);
    res.end();
    return;
  }

  // Parse URL
  const url = new URL(req.url, `http://${req.headers.host}`);
  const path = url.pathname;
  const method = req.method;

  // Get body for POST/PUT
  let body = '';
  req.on('data', chunk => {
    body += chunk.toString();
  });

  await new Promise(resolve => req.on('end', resolve));

  // Create Lambda-like event
  const pathParts = path.split('/').filter(Boolean);
  const event = {
    body,
    requestContext: {
      http: {
        method,
        path
      }
    },
    pathParameters: pathParts.length > 1 ? { id: pathParts[1] } : {},
    httpMethod: method,
    path
  };

  try {
    let result;

    // Route to handlers
    if (path === '/tasks' && method === 'GET') {
      result = await tasks.listTasks(event);
    } else if (path === '/tasks' && method === 'POST') {
      result = await tasks.createTask(event);
    } else if (path.match(/^\/tasks\/[^/]+$/) && method === 'GET') {
      result = await tasks.getTask(event);
    } else if (path.match(/^\/tasks\/[^/]+$/) && method === 'PUT') {
      result = await tasks.updateTask(event);
    } else if (path.match(/^\/tasks\/[^/]+$/) && method === 'DELETE') {
      result = await tasks.deleteTask(event);
    } else {
      result = {
        statusCode: 404,
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ error: 'Not found' })
      };
    }

    // Send response
    res.writeHead(result.statusCode, result.headers);
    res.end(result.body);
  } catch (error) {
    console.error('Error:', error);
    res.writeHead(500, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ error: 'Internal server error' }));
  }
};

const server = http.createServer(router);

server.listen(PORT, '0.0.0.0', () => {
  console.log(`🚀 Backend API running on http://localhost:${PORT}`);
  console.log(`📊 DynamoDB endpoint: ${process.env.DYNAMODB_ENDPOINT || 'AWS'}`);
});
