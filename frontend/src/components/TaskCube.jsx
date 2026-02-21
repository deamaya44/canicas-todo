import { useRef, useEffect, useState } from 'react'
import { useSphere } from '@react-three/cannon'
import { useFrame } from '@react-three/fiber'

let marbleCount = 0

function TaskCube({ task, isSelected, onHover, onClick }) {
  const radius = 0.3
  const [hovered, setHovered] = useState(false)
  
  const [startY] = useState(() => {
    marbleCount++
    return 1.5 + (marbleCount * 0.5)
  })
  
  const [startPos] = useState(() => {
    const angle = Math.random() * Math.PI * 2
    const r = Math.random() * 0.3
    const y = 1.5 + (marbleCount * 0.5)
    return [
      Math.cos(angle) * r,
      y,
      Math.sin(angle) * r
    ]
  })
  
  const [ref, api] = useSphere(() => ({
    mass: 2,
    position: startPos,
    args: [radius],
    material: {
      friction: 0.4,
      restitution: 0.3
    },
    linearDamping: 0.3,
    angularDamping: 0.3
  }))

  useEffect(() => {
    document.body.style.cursor = hovered ? 'pointer' : 'auto'
  }, [hovered])

  return (
    <mesh 
      ref={ref} 
      castShadow
      onPointerOver={(e) => {
        e.stopPropagation()
        setHovered(true)
        onHover?.(task, e)
      }}
      onPointerOut={(e) => {
        e.stopPropagation()
        setHovered(false)
        onHover?.(null, e)
      }}
      onClick={(e) => {
        e.stopPropagation()
        onClick?.(task)
      }}
    >
      <sphereGeometry args={[radius, 16, 16]} />
      <meshStandardMaterial
        color={task.color || '#ff6b6b'}
        emissive={task.color || '#ff6b6b'}
        emissiveIntensity={isSelected || hovered ? 0.9 : 0.4}
        roughness={0.2}
        metalness={0.7}
      />
    </mesh>
  )
}

export default TaskCube
