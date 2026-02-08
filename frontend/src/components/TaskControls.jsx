import './TaskControls.css'

function TaskControls({
  viewMode,
  selectedTask,
  onViewTasks,
  onBackToOverview,
  onDeleteTask,
  onCompleteTask
}) {
  return (
    <div className="task-controls">
      {selectedTask && (
        <div className="selected-task-info">
          <h3>{selectedTask.title}</h3>
          {selectedTask.description && <p>{selectedTask.description}</p>}
          
          <div className="task-actions">
            {!selectedTask.completed && (
              <button
                className="control-btn success"
                onClick={() => onCompleteTask(selectedTask.id)}
              >
                ✓ Completar
              </button>
            )}
            <button
              className="control-btn danger"
              onClick={() => onDeleteTask(selectedTask.id)}
            >
              💥 Eliminar
            </button>
          </div>
        </div>
      )}
    </div>
  )
}

export default TaskControls
