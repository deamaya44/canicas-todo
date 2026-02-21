const tasks = require('./src/handlers/tasks');

exports.handler = async (event) => {
  console.log('Event:', JSON.stringify(event, null, 2));

  const method = event.requestContext?.http?.method || event.httpMethod;
  const path = event.requestContext?.http?.path || event.path;
  const pathParameters = event.pathParameters || {};

  // Handle CORS preflight
  if (method === 'OPTIONS') {
    return {
      statusCode: 200,
      headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Headers': 'Content-Type,Authorization',
        'Access-Control-Allow-Methods': 'GET,POST,PUT,DELETE,OPTIONS'
      },
      body: ''
    };
  }

  try {
    // Route handling
    if (path === '/tasks' && method === 'GET') {
      return await tasks.listTasks(event);
    }
    
    if (path === '/tasks' && method === 'POST') {
      return await tasks.createTask(event);
    }
    
    if (path.match(/^\/tasks\/[^/]+$/) && method === 'GET') {
      return await tasks.getTask(event);
    }
    
    if (path.match(/^\/tasks\/[^/]+$/) && method === 'PUT') {
      return await tasks.updateTask(event);
    }
    
    if (path.match(/^\/tasks\/[^/]+$/) && method === 'DELETE') {
      return await tasks.deleteTask(event);
    }

    // Route not found
    return {
      statusCode: 404,
      headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*'
      },
      body: JSON.stringify({ error: 'Route not found' })
    };
  } catch (error) {
    console.error('Error:', error);
    return {
      statusCode: 500,
      headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*'
      },
      body: JSON.stringify({ error: 'Internal server error' })
    };
  }
};
