import { auth } from '../firebase'

const API_URL = import.meta.env.VITE_API_URL || 'http://localhost:3001'

console.log('🔗 API URL:', API_URL);

const getAuthHeaders = async () => {
  const user = auth.currentUser
  if (!user) {
    throw new Error('No authenticated user')
  }
  
  const token = await user.getIdToken()
  return {
    'Content-Type': 'application/json',
    'Authorization': `Bearer ${token}`
  }
}

export const getTasks = async () => {
  console.log('📡 Fetching tasks from:', `${API_URL}/tasks`);
  const headers = await getAuthHeaders()
  const response = await fetch(`${API_URL}/tasks`, { headers })
  console.log('📥 Response status:', response.status);
  if (!response.ok) throw new Error('Failed to fetch tasks')
  const data = await response.json();
  console.log('📦 Data received:', data);
  return data;
}

export const createTask = async (task) => {
  const headers = await getAuthHeaders()
  const response = await fetch(`${API_URL}/tasks`, {
    method: 'POST',
    headers,
    body: JSON.stringify(task)
  })
  if (!response.ok) throw new Error('Failed to create task')
  return response.json()
}

export const updateTask = async (id, updates) => {
  const headers = await getAuthHeaders()
  const response = await fetch(`${API_URL}/tasks/${id}`, {
    method: 'PUT',
    headers,
    body: JSON.stringify(updates)
  })
  if (!response.ok) throw new Error('Failed to update task')
  return response.json()
}

export const deleteTask = async (id) => {
  const headers = await getAuthHeaders()
  const response = await fetch(`${API_URL}/tasks/${id}`, {
    method: 'DELETE',
    headers
  })
  if (!response.ok) throw new Error('Failed to delete task')
  return response.json()
}
