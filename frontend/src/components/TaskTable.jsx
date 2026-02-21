import { useState } from 'react'
import './TaskTable.css'

function TaskTable({ tasks, selectedTask, onSelectTask, onDeleteTask }) {
  const [isOpen, setIsOpen] = useState(false)

  return (
    <>
      {/* Toggle button - solo visible en mobile */}
      <button 
        className="task-toggle-btn"
        onClick={() => setIsOpen(!isOpen)}
      >
        {isOpen ? '▼' : '▲'} Tareas ({tasks.length})
      </button>

      <div className={`task-table-container ${isOpen ? 'open' : ''}`}>
        <h2>Tareas</h2>
        <div className="task-table">
          {tasks.map((task) => (
            <div
              key={task.id}
              className={`task-row ${selectedTask?.id === task.id ? 'selected' : ''}`}
              onClick={() => onSelectTask(task)}
            >
              <div className="task-color" style={{ backgroundColor: task.color }} />
              <div className="task-title">{task.title}</div>
              <div className="task-actions">
                <button
                  className="action-btn delete"
                  onClick={(e) => {
                    e.stopPropagation()
                    onDeleteTask(task.id)
                  }}
                  title="Eliminar"
                >
                  ✕
                </button>
              </div>
            </div>
          ))}
        </div>
      </div>
    </>
  )
}

export default TaskTable
