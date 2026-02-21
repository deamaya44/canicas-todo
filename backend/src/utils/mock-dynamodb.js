const { v4: uuidv4 } = require('uuid');

// Mock data for development when DynamoDB is not available
const mockTasks = [
  {
    id: '1',
    title: 'Task 1',
    description: 'First task',
    position: { x: -2, y: 0, z: 0 },
    color: '#3498db',
    completed: false,
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString()
  },
  {
    id: '2', 
    title: 'Task 2',
    description: 'Second task',
    position: { x: 0, y: 1, z: 0 },
    color: '#e74c3c',
    completed: false,
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString()
  },
  {
    id: '3',
    title: 'Task 3', 
    description: 'Third task',
    position: { x: 2, y: 0, z: 0 },
    color: '#2ecc71',
    completed: false,
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString()
  }
];

// In-memory storage for development
let tasks = [...mockTasks];

const dynamodb = {
  async create(item) {
    tasks.push(item);
    return item;
  },

  async get(id) {
    return tasks.find(task => task.id === id);
  },

  async getAll() {
    return tasks;
  },

  async update(id, updates) {
    const index = tasks.findIndex(task => task.id === id);
    if (index === -1) {
      throw new Error('Task not found');
    }
    tasks[index] = { ...tasks[index], ...updates, updatedAt: new Date().toISOString() };
    return tasks[index];
  },

  async delete(id) {
    const index = tasks.findIndex(task => task.id === id);
    if (index === -1) {
      throw new Error('Task not found');
    }
    tasks.splice(index, 1);
    return { id };
  }
};

module.exports = dynamodb;
