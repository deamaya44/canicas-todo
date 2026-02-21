const { v4: uuidv4 } = require('uuid');
// Use mock dynamodb for development if real DynamoDB is not available
const dynamodb = process.env.NODE_ENV === 'development' && !process.env.DYNAMODB_ENDPOINT 
  ? require('../utils/mock-dynamodb') 
  : require('../utils/dynamodb');
const response = require('../utils/response');

// GET /tasks - List all tasks
exports.listTasks = async (event) => {
  try {
    // Extract userId from authorizer context (AWS) or use dev mode
    const userId = event.requestContext?.authorizer?.lambda?.userId 
                || event.requestContext?.authorizer?.userId
                || process.env.DEV_USER_ID
                || 'dev-user';
    
    if (!userId && process.env.NODE_ENV !== 'development') {
      return response.error('Unauthorized', 401);
    }

    const tasks = await dynamodb.getAllByUser(userId);
    return response.success({ tasks });
  } catch (error) {
    console.error('Error listing tasks:', error);
    return response.error('Failed to list tasks', 500);
  }
};

// POST /tasks - Create new task
exports.createTask = async (event) => {
  try {
    // Extract userId from authorizer context (AWS) or use dev mode
    const userId = event.requestContext?.authorizer?.lambda?.userId 
                || event.requestContext?.authorizer?.userId
                || process.env.DEV_USER_ID
                || 'dev-user';
    
    if (!userId && process.env.NODE_ENV !== 'development') {
      return response.error('Unauthorized', 401);
    }

    const body = JSON.parse(event.body || '{}');
    
    if (!body.title) {
      return response.error('Title is required', 400);
    }

    // Get existing tasks to avoid color repetition
    const existingTasks = await dynamodb.getAllByUser(userId);
    const usedColors = new Set(existingTasks.map(t => t.color));
    
    // Color palette
    const colors = [
      '#ff6b6b', '#ee5a6f', '#f06595', '#cc5de8', '#845ef7',
      '#5c7cfa', '#339af0', '#22b8cf', '#20c997', '#51cf66',
      '#94d82d', '#fcc419', '#ff922b', '#fd7e14', '#fa5252',
      '#e64980', '#be4bdb', '#7950f2', '#4c6ef5', '#228be6',
      '#15aabf', '#12b886', '#40c057', '#82c91e', '#fab005',
      '#fd7e14', '#f76707', '#d9480f'
    ];
    
    // Find first unused color
    let selectedColor = colors.find(c => !usedColors.has(c));
    if (!selectedColor) {
      selectedColor = '#' + Math.floor(Math.random()*16777215).toString(16);
    }

    const task = {
      id: uuidv4(),
      userId,
      title: body.title,
      description: body.description || '',
      color: body.color || selectedColor,
      completed: false,
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString()
    };

    await dynamodb.create(task);
    return response.success({ task }, 201);
  } catch (error) {
    console.error('Error creating task:', error);
    return response.error('Failed to create task', 500);
  }
};

// GET /tasks/{id} - Get specific task
exports.getTask = async (event) => {
  try {
    const id = event.pathParameters?.id;
    
    if (!id) {
      return response.error('Task ID is required', 400);
    }

    const task = await dynamodb.get(id);
    
    if (!task) {
      return response.error('Task not found', 404);
    }

    return response.success({ task });
  } catch (error) {
    console.error('Error getting task:', error);
    return response.error('Failed to get task', 500);
  }
};

// PUT /tasks/{id} - Update task
exports.updateTask = async (event) => {
  try {
    const id = event.pathParameters?.id;
    const body = JSON.parse(event.body || '{}');
    
    if (!id) {
      return response.error('Task ID is required', 400);
    }

    const task = await dynamodb.get(id);
    if (!task) {
      return response.error('Task not found', 404);
    }

    const updates = {
      ...body,
      updatedAt: new Date().toISOString()
    };

    const updatedTask = await dynamodb.update(id, updates);
    return response.success({ task: updatedTask });
  } catch (error) {
    console.error('Error updating task:', error);
    return response.error('Failed to update task', 500);
  }
};

// DELETE /tasks/{id} - Delete task
exports.deleteTask = async (event) => {
  try {
    const id = event.pathParameters?.id;
    
    if (!id) {
      return response.error('Task ID is required', 400);
    }

    const task = await dynamodb.get(id);
    if (!task) {
      return response.error('Task not found', 404);
    }

    await dynamodb.delete(id);
    return response.success({ message: 'Task deleted successfully', id });
  } catch (error) {
    console.error('Error deleting task:', error);
    return response.error('Failed to delete task', 500);
  }
};
