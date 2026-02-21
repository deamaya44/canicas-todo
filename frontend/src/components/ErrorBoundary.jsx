import React from 'react'

class ErrorBoundary extends React.Component {
  constructor(props) {
    super(props)
    this.state = { hasError: false, error: null }
  }

  static getDerivedStateFromError(error) {
    return { hasError: true, error }
  }

  componentDidCatch(error, errorInfo) {
    console.error('Three.js Error Boundary caught an error:', error, errorInfo)
  }

  render() {
    if (this.state.hasError) {
      return (
        <div style={{
          position: 'absolute',
          top: '50%',
          left: '50%',
          transform: 'translate(-50%, -50%)',
          textAlign: 'center',
          padding: '20px',
          background: 'rgba(255,255,255,0.9)',
          borderRadius: '8px',
          boxShadow: '0 4px 6px rgba(0,0,0,0.1)'
        }}>
          <h3 style={{ color: '#e74c3c', margin: '0 0 10px 0' }}>
            3D Scene Error
          </h3>
          <p style={{ margin: '0 0 15px 0', color: '#666' }}>
            The 3D scene encountered an error. Please refresh the page.
          </p>
          <button 
            onClick={() => window.location.reload()}
            style={{
              padding: '8px 16px',
              background: '#3498db',
              color: 'white',
              border: 'none',
              borderRadius: '4px',
              cursor: 'pointer'
            }}
          >
            Refresh
          </button>
          {process.env.NODE_ENV === 'development' && (
            <details style={{ marginTop: '15px', textAlign: 'left' }}>
              <summary>Error Details</summary>
              <pre style={{ 
                fontSize: '12px', 
                overflow: 'auto', 
                maxHeight: '200px',
                background: '#f5f5f5',
                padding: '10px',
                borderRadius: '4px'
              }}>
                {this.state.error?.toString()}
              </pre>
            </details>
          )}
        </div>
      )
    }

    return this.props.children
  }
}

export default ErrorBoundary
