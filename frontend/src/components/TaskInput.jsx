import { useState } from 'react'
import './TaskInput.css'

function TaskInput({ onCreateTask }) {
  const [title, setTitle] = useState('')

  const handleSubmit = (e) => {
    e.preventDefault()
    if (!title.trim()) return

    onCreateTask({
      title: title.trim(),
      description: ''
    })

    setTitle('')
  }

  return (
    <div className="task-input-container">
      <h2>Nueva Tarea</h2>
      <form className="task-form" onSubmit={handleSubmit}>
        <div className="form-group">
          <label>Título</label>
          <input
            type="text"
            placeholder="Escribe el título..."
            value={title}
            onChange={(e) => setTitle(e.target.value)}
            maxLength={50}
            required
          />
        </div>
        
        <button type="submit" className="submit-btn" disabled={!title.trim()}>
          Crear Tarea
        </button>
      </form>
    </div>
  )
}

export default TaskInput
