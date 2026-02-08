import { useRef, memo } from 'react'
import { useFrame } from '@react-three/fiber'

const Sky = memo(function Sky() {
  const sunRef = useRef()
  
  useFrame((state) => {
    if (sunRef.current) {
      // Pulso sutil del sol
      const pulse = Math.sin(state.clock.elapsedTime * 0.5) * 0.1 + 1
      sunRef.current.scale.set(pulse, pulse, pulse)
    }
  })
  
  return (
    <group>
      {/* Cielo azul brillante - esfera completa 360 */}
      <mesh>
        <sphereGeometry args={[100, 32, 32]} />
        <meshBasicMaterial color="#4da6ff" side={2} fog={false} />
      </mesh>
      
      {/* Sol visible desde cualquier ángulo */}
      <mesh ref={sunRef} position={[30, 25, -40]}>
        <sphereGeometry args={[4, 16, 16]} />
        <meshBasicMaterial 
          color="#ffff00" 
          fog={false}
        />
      </mesh>
      
      {/* Resplandor del sol */}
      <mesh position={[30, 25, -40]}>
        <sphereGeometry args={[6, 16, 16]} />
        <meshBasicMaterial 
          color="#ffaa00" 
          transparent 
          opacity={0.3}
          fog={false}
        />
      </mesh>
      
      {/* Nubes distribuidas 360 grados */}
      {[0, 60, 120, 180, 240, 300].map((angle, i) => {
        const rad = (angle * Math.PI) / 180
        const distance = 35
        const height = 15 + Math.sin(i) * 3
        return (
          <group key={`cloud-${i}`}>
            <mesh position={[Math.cos(rad) * distance, height, Math.sin(rad) * distance]}>
              <sphereGeometry args={[3, 8, 8]} />
              <meshBasicMaterial color="#ffffff" transparent opacity={0.7} fog={false} />
            </mesh>
            <mesh position={[Math.cos(rad) * distance + 2, height, Math.sin(rad) * distance]}>
              <sphereGeometry args={[2.5, 8, 8]} />
              <meshBasicMaterial color="#ffffff" transparent opacity={0.7} fog={false} />
            </mesh>
            <mesh position={[Math.cos(rad) * distance - 2, height, Math.sin(rad) * distance]}>
              <sphereGeometry args={[2, 8, 8]} />
              <meshBasicMaterial color="#ffffff" transparent opacity={0.7} fog={false} />
            </mesh>
          </group>
        )
      })}
    </group>
  )
})

export default Sky
