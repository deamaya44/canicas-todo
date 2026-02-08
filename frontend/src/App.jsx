import { useState, useEffect } from 'react'
import { onAuthStateChanged } from 'firebase/auth'
import { auth } from './firebase'
import Auth from './components/Auth'
import Scene3D from './components/Scene3D'
import TaskInput from './components/TaskInput'
import TaskTable from './components/TaskTable'
import { getTasks, createTask, updateTask, deleteTask } from './api/tasks'
import './App.css'

function App() {
  const [user, setUser] = useState(null)
  const [loading, setLoading] = useState(true)
  const [tasks, setTasks] = useState([])
  const [selectedTask, setSelectedTask] = useState(null)

  useEffect(() => {
    const unsubscribe = onAuthStateChanged(auth, (currentUser) => {
      setUser(currentUser)
      setLoading(false)
      if (currentUser) {
        loadTasks()
      }
    })

    return () => unsubscribe()
  }, [])

  const loadTasks = async () => {
    try {
      const data = await getTasks()
      console.log('📊 Tareas cargadas:', data)
      setTasks(data.tasks || [])
    } catch (error) {
      console.error('Error loading tasks:', error)
    }
  }

  if (loading) {
    return <div>Cargando...</div>
  }

  if (!user) {
    return <Auth />
  }

  const handleCreateTask = async (taskData) => {
    try {
      const result = await createTask(taskData)
      setTasks([...tasks, result.task])
    } catch (error) {
      console.error('Error creating task:', error)
    }
  }

  const handleDeleteTask = async (id) => {
    try {
      console.log('🗑️ Eliminando tarea:', id)
      await deleteTask(id)
      setTasks(tasks.filter(t => t.id !== id))
      if (selectedTask?.id === id) {
        setSelectedTask(null)
      }
      console.log('✅ Tarea eliminada')
    } catch (error) {
      console.error('❌ Error deleting task:', error)
    }
  }

  return (
    <div className="app">
      <Auth />
      
      <Scene3D
        tasks={tasks}
        selectedTask={selectedTask}
        onSelectTask={setSelectedTask}
      />
      
      <TaskInput onCreateTask={handleCreateTask} />
      
      <TaskTable
        tasks={tasks}
        selectedTask={selectedTask}
        onSelectTask={setSelectedTask}
        onDeleteTask={handleDeleteTask}
      />
    </div>
  )
}

export default App
