import { Canvas } from '@react-three/fiber'
import { OrbitControls, PerspectiveCamera, ContactShadows } from '@react-three/drei'
import { Physics, useSphere as usePhysicsSphere, useTrimesh } from '@react-three/cannon'
import { useRef, useMemo, useState } from 'react'
import * as THREE from 'three'
import GlassBottle from './GlassBottle'
import TaskCube from './TaskCube'
import WildBackground from './WildBackground'
import Sky from './Sky'
import './Scene3D.css'

function BowlPhysics() {
  // Crear geometría de hemisferio para física
  const geometry = useMemo(() => {
    const geo = new THREE.SphereGeometry(2.2, 16, 16, 0, Math.PI * 2, 0, Math.PI * 0.5)
    geo.scale(1, 1, 1)
    return geo
  }, [])
  
  const vertices = useMemo(() => {
    const pos = geometry.attributes.position.array
    return Array.from(pos)
  }, [geometry])
  
  const indices = useMemo(() => {
    return geometry.index ? Array.from(geometry.index.array) : []
  }, [geometry])
  
  const [ref] = useTrimesh(() => ({
    args: [vertices, indices],
    position: [0, -2, 0],
    rotation: [Math.PI, 0, 0],
    type: 'Static'
  }), useRef())
  
  return null
}



function Scene3D({ tasks, selectedTask, onSelectTask }) {
  const [hoveredTask, setHoveredTask] = useState(null)
  const [tooltipPos, setTooltipPos] = useState({ x: 0, y: 0 })

  const handleHover = (task, event) => {
    if (task) {
      setHoveredTask(task)
      setTooltipPos({ x: event.clientX, y: event.clientY })
    } else {
      setHoveredTask(null)
    }
  }

  const handleClick = (task) => {
    onSelectTask?.(task)
  }

  return (
    <div className="scene-container">
      <Canvas shadows dpr={[1, 1.5]} performance={{ min: 0.5 }} frameloop="demand">
        <PerspectiveCamera
          makeDefault
          position={[5, 3, 7]}
          fov={50}
        />
        
        <OrbitControls
          enableZoom={true}
          minDistance={3}
          maxDistance={15}
          target={[0, -0.5, 0]}
          minPolarAngle={0}
          maxPolarAngle={Math.PI / 2.05}
        />
        
        <ambientLight intensity={0.5} />
        <directionalLight 
          position={[15, 20, 10]} 
          intensity={2} 
          castShadow
          shadow-mapSize-width={1024}
          shadow-mapSize-height={1024}
          shadow-camera-far={50}
          shadow-camera-left={-20}
          shadow-camera-right={20}
          shadow-camera-top={20}
          shadow-camera-bottom={-20}
        />
        <hemisphereLight args={['#ff9966', '#8B4513', 0.6]} />
        
        <Sky />
        <WildBackground />
        <GlassBottle />
        
        <Physics gravity={[0, -20, 0]} iterations={6} tolerance={0.01} broadphase="SAP">
          <BowlPhysics />
          
          {tasks.map((task) => (
            <TaskCube
              key={task.id}
              task={task}
              isSelected={selectedTask?.id === task.id}
              onHover={handleHover}
              onClick={handleClick}
            />
          ))}
        </Physics>
        
        <ContactShadows position={[0, -4, 0]} opacity={0.5} scale={6} blur={2.5} />
      </Canvas>

      {/* Tooltip */}
      {hoveredTask && (
        <div 
          className="task-tooltip"
          style={{
            left: tooltipPos.x + 10,
            top: tooltipPos.y + 10
          }}
        >
          {hoveredTask.title}
        </div>
      )}
    </div>
  )
}

export default Scene3D
