import { useRef, memo } from 'react'
import { useFrame } from '@react-three/fiber'

const Horse = memo(function Horse({ position, speed, path, color = "#8B4513" }) {
  const ref = useRef()
  const legRefs = [useRef(), useRef(), useRef(), useRef()]
  const offset = Math.random() * Math.PI * 2
  
  useFrame((state) => {
    if (ref.current) {
      const t = state.clock.elapsedTime * speed + offset
      ref.current.position.x = position[0] + Math.cos(t) * path
      ref.current.position.z = position[2] + Math.sin(t) * path
      ref.current.rotation.y = t + Math.PI / 2
      
      // Galope realista
      const gallop = Math.abs(Math.sin(t * 12)) * 0.25
      ref.current.position.y = position[1] + gallop
      
      // Animación de patas - galope
      const legCycle = t * 12
      legRefs[0].current && (legRefs[0].current.rotation.x = Math.sin(legCycle) * 0.6)
      legRefs[1].current && (legRefs[1].current.rotation.x = Math.sin(legCycle + Math.PI) * 0.6)
      legRefs[2].current && (legRefs[2].current.rotation.x = Math.sin(legCycle + Math.PI * 0.5) * 0.6)
      legRefs[3].current && (legRefs[3].current.rotation.x = Math.sin(legCycle + Math.PI * 1.5) * 0.6)
    }
  })
  
  const darkerColor = `#${(parseInt(color.slice(1), 16) * 0.7).toString(16).padStart(6, '0')}`
  
  return (
    <group ref={ref}>
      {/* Cuerpo principal - más anatómico */}
      <mesh position={[0, 0.9, 0]} castShadow>
        <boxGeometry args={[0.5, 0.6, 1.6]} />
        <meshStandardMaterial color={color} roughness={0.7} metalness={0.1} />
      </mesh>
      
      {/* Pecho */}
      <mesh position={[0, 0.8, 0.7]} castShadow>
        <sphereGeometry args={[0.35, 12, 12]} />
        <meshStandardMaterial color={color} roughness={0.7} />
      </mesh>
      
      {/* Cuartos traseros */}
      <mesh position={[0, 0.9, -0.6]} castShadow>
        <sphereGeometry args={[0.4, 12, 12]} />
        <meshStandardMaterial color={color} roughness={0.7} />
      </mesh>
      
      {/* Cuello - curvo */}
      <mesh position={[0, 1.3, 0.7]} rotation={[0.6, 0, 0]} castShadow>
        <cylinderGeometry args={[0.18, 0.22, 0.9]} />
        <meshStandardMaterial color={color} roughness={0.7} />
      </mesh>
      
      {/* Cabeza - más detallada */}
      <mesh position={[0, 1.85, 1]} castShadow>
        <boxGeometry args={[0.25, 0.35, 0.6]} />
        <meshStandardMaterial color={color} roughness={0.7} />
      </mesh>
      
      {/* Nariz con fosas nasales */}
      <mesh position={[0, 1.7, 1.35]} castShadow>
        <boxGeometry args={[0.2, 0.2, 0.3]} />
        <meshStandardMaterial color={darkerColor} roughness={0.8} />
      </mesh>
      <mesh position={[-0.06, 1.72, 1.48]}>
        <sphereGeometry args={[0.025, 6, 6]} />
        <meshStandardMaterial color="#1a1a1a" />
      </mesh>
      <mesh position={[0.06, 1.72, 1.48]}>
        <sphereGeometry args={[0.025, 6, 6]} />
        <meshStandardMaterial color="#1a1a1a" />
      </mesh>
      
      {/* Mandíbula inferior */}
      <mesh position={[0, 1.6, 1.3]} castShadow>
        <boxGeometry args={[0.15, 0.12, 0.25]} />
        <meshStandardMaterial color={darkerColor} roughness={0.8} />
      </mesh>
      
      {/* Orejas puntiagudas */}
      <mesh position={[-0.08, 2.05, 0.95]} rotation={[0.3, 0, -0.4]}>
        <coneGeometry args={[0.06, 0.18, 4]} />
        <meshStandardMaterial color={color} />
      </mesh>
      <mesh position={[0.08, 2.05, 0.95]} rotation={[0.3, 0, 0.4]}>
        <coneGeometry args={[0.06, 0.18, 4]} />
        <meshStandardMaterial color={color} />
      </mesh>
      
      {/* Ojos con brillo */}
      <mesh position={[-0.13, 1.9, 1.15]}>
        <sphereGeometry args={[0.05, 8, 8]} />
        <meshStandardMaterial color="#1a1a1a" />
      </mesh>
      <mesh position={[-0.12, 1.92, 1.18]}>
        <sphereGeometry args={[0.015, 6, 6]} />
        <meshStandardMaterial color="#ffffff" emissive="#ffffff" emissiveIntensity={0.5} />
      </mesh>
      <mesh position={[0.13, 1.9, 1.15]}>
        <sphereGeometry args={[0.05, 8, 8]} />
        <meshStandardMaterial color="#1a1a1a" />
      </mesh>
      <mesh position={[0.12, 1.92, 1.18]}>
        <sphereGeometry args={[0.015, 6, 6]} />
        <meshStandardMaterial color="#ffffff" emissive="#ffffff" emissiveIntensity={0.5} />
      </mesh>
      
      {/* Crin - múltiples segmentos con volumen */}
      <mesh position={[0, 2, 0.9]} rotation={[0.5, 0, 0]}>
        <boxGeometry args={[0.14, 0.3, 0.1]} />
        <meshStandardMaterial color="#2d1810" roughness={1} />
      </mesh>
      <mesh position={[0, 1.6, 0.6]} rotation={[0.4, 0, 0]}>
        <boxGeometry args={[0.14, 0.5, 0.1]} />
        <meshStandardMaterial color="#2d1810" roughness={1} />
      </mesh>
      <mesh position={[0, 1.5, 0.5]} rotation={[0.3, 0, 0]}>
        <boxGeometry args={[0.13, 0.4, 0.09]} />
        <meshStandardMaterial color="#2d1810" roughness={1} />
      </mesh>
      <mesh position={[0, 1.4, 0.4]} rotation={[0.2, 0, 0]}>
        <boxGeometry args={[0.12, 0.35, 0.08]} />
        <meshStandardMaterial color="#2d1810" roughness={1} />
      </mesh>
      <mesh position={[0, 1.3, 0.3]} rotation={[0.15, 0, 0]}>
        <boxGeometry args={[0.11, 0.3, 0.08]} />
        <meshStandardMaterial color="#2d1810" roughness={1} />
      </mesh>
      
      {/* Cola larga y fluida con mechones */}
      <mesh position={[0, 0.9, -1]} rotation={[1, 0, 0]} castShadow>
        <cylinderGeometry args={[0.08, 0.02, 1.2]} />
        <meshStandardMaterial color="#2d1810" roughness={1} />
      </mesh>
      <mesh position={[0.03, 0.3, -1.5]} rotation={[1.1, 0.1, 0]} castShadow>
        <cylinderGeometry args={[0.04, 0.01, 0.4]} />
        <meshStandardMaterial color="#2d1810" roughness={1} />
      </mesh>
      <mesh position={[-0.03, 0.3, -1.5]} rotation={[1.1, -0.1, 0]} castShadow>
        <cylinderGeometry args={[0.04, 0.01, 0.4]} />
        <meshStandardMaterial color="#2d1810" roughness={1} />
      </mesh>
      
      {/* Patas delanteras con articulaciones */}
      <group ref={legRefs[0]} position={[-0.18, 0.6, 0.5]}>
        <mesh position={[0, -0.25, 0]} castShadow>
          <cylinderGeometry args={[0.07, 0.06, 0.5]} />
          <meshStandardMaterial color={color} roughness={0.8} />
        </mesh>
        <mesh position={[0, -0.55, 0.05]} castShadow>
          <cylinderGeometry args={[0.06, 0.05, 0.3]} />
          <meshStandardMaterial color={darkerColor} roughness={0.9} />
        </mesh>
        {/* Casco */}
        <mesh position={[0, -0.72, 0.05]}>
          <cylinderGeometry args={[0.06, 0.07, 0.08]} />
          <meshStandardMaterial color="#1a1a1a" roughness={0.3} metalness={0.5} />
        </mesh>
      </group>
      
      <group ref={legRefs[1]} position={[0.18, 0.6, 0.5]}>
        <mesh position={[0, -0.25, 0]} castShadow>
          <cylinderGeometry args={[0.07, 0.06, 0.5]} />
          <meshStandardMaterial color={color} roughness={0.8} />
        </mesh>
        <mesh position={[0, -0.55, 0.05]} castShadow>
          <cylinderGeometry args={[0.06, 0.05, 0.3]} />
          <meshStandardMaterial color={darkerColor} roughness={0.9} />
        </mesh>
        <mesh position={[0, -0.72, 0.05]}>
          <cylinderGeometry args={[0.06, 0.07, 0.08]} />
          <meshStandardMaterial color="#1a1a1a" roughness={0.3} metalness={0.5} />
        </mesh>
      </group>
      
      {/* Patas traseras */}
      <group ref={legRefs[2]} position={[-0.18, 0.6, -0.5]}>
        <mesh position={[0, -0.25, 0]} castShadow>
          <cylinderGeometry args={[0.08, 0.07, 0.5]} />
          <meshStandardMaterial color={color} roughness={0.8} />
        </mesh>
        <mesh position={[0, -0.55, 0.05]} castShadow>
          <cylinderGeometry args={[0.07, 0.06, 0.3]} />
          <meshStandardMaterial color={darkerColor} roughness={0.9} />
        </mesh>
        <mesh position={[0, -0.72, 0.05]}>
          <cylinderGeometry args={[0.06, 0.07, 0.08]} />
          <meshStandardMaterial color="#1a1a1a" roughness={0.3} metalness={0.5} />
        </mesh>
      </group>
      
      <group ref={legRefs[3]} position={[0.18, 0.6, -0.5]}>
        <mesh position={[0, -0.25, 0]} castShadow>
          <cylinderGeometry args={[0.08, 0.07, 0.5]} />
          <meshStandardMaterial color={color} roughness={0.8} />
        </mesh>
        <mesh position={[0, -0.55, 0.05]} castShadow>
          <cylinderGeometry args={[0.07, 0.06, 0.3]} />
          <meshStandardMaterial color={darkerColor} roughness={0.9} />
        </mesh>
        <mesh position={[0, -0.72, 0.05]}>
          <cylinderGeometry args={[0.06, 0.07, 0.08]} />
          <meshStandardMaterial color="#1a1a1a" roughness={0.3} metalness={0.5} />
        </mesh>
      </group>
    </group>
  )
})

const WildBackground = memo(function WildBackground() {
  return (
    <group>
      <mesh position={[0, -4.5, 0]} receiveShadow castShadow>
        <boxGeometry args={[8, 0.3, 6]} />
        <meshStandardMaterial color="#8B4513" roughness={0.9} metalness={0.1} />
      </mesh>
      <mesh position={[-3.5, -6, -2.5]} castShadow>
        <cylinderGeometry args={[0.15, 0.15, 3]} />
        <meshStandardMaterial color="#654321" />
      </mesh>
      <mesh position={[3.5, -6, -2.5]} castShadow>
        <cylinderGeometry args={[0.15, 0.15, 3]} />
        <meshStandardMaterial color="#654321" />
      </mesh>
      <mesh position={[-3.5, -6, 2.5]} castShadow>
        <cylinderGeometry args={[0.15, 0.15, 3]} />
        <meshStandardMaterial color="#654321" />
      </mesh>
      <mesh position={[3.5, -6, 2.5]} castShadow>
        <cylinderGeometry args={[0.15, 0.15, 3]} />
        <meshStandardMaterial color="#654321" />
      </mesh>
      
      <mesh position={[0, -7.5, 0]} rotation={[-Math.PI / 2, 0, 0]} receiveShadow>
        <planeGeometry args={[80, 80]} />
        <meshStandardMaterial color="#d4a574" roughness={1} />
      </mesh>
      
      <mesh position={[0, -3, -35]} castShadow>
        <coneGeometry args={[8, 10, 4]} />
        <meshStandardMaterial color="#8B7355" roughness={0.9} />
      </mesh>
      <mesh position={[-12, -4, -32]} castShadow>
        <coneGeometry args={[6, 8, 4]} />
        <meshStandardMaterial color="#9B8365" roughness={0.9} />
      </mesh>
      <mesh position={[15, -4, -33]} castShadow>
        <coneGeometry args={[7, 9, 4]} />
        <meshStandardMaterial color="#8B7355" roughness={0.9} />
      </mesh>
      
      <mesh position={[-10, -7, -8]} castShadow>
        <dodecahedronGeometry args={[1.2, 0]} />
        <meshStandardMaterial color="#a0826d" roughness={1} />
      </mesh>
      <mesh position={[12, -7, -10]} castShadow>
        <dodecahedronGeometry args={[1.5, 0]} />
        <meshStandardMaterial color="#b09070" roughness={1} />
      </mesh>
      <mesh position={[-8, -7, 12]} castShadow>
        <dodecahedronGeometry args={[1, 0]} />
        <meshStandardMaterial color="#a0826d" roughness={1} />
      </mesh>
      <mesh position={[10, -7, 14]} castShadow>
        <dodecahedronGeometry args={[1.3, 0]} />
        <meshStandardMaterial color="#b09070" roughness={1} />
      </mesh>
      
      {[-12, -8, 10, 14].map((z, i) => (
        <group key={`cactus-left-${i}`} position={[-15, -7.5, z]}>
          <mesh castShadow>
            <cylinderGeometry args={[0.3, 0.3, 3]} />
            <meshStandardMaterial color="#4a7c4a" roughness={0.9} />
          </mesh>
          <mesh position={[-0.4, 0.8, 0]} rotation={[0, 0, Math.PI / 3]} castShadow>
            <cylinderGeometry args={[0.2, 0.2, 1]} />
            <meshStandardMaterial color="#4a7c4a" roughness={0.9} />
          </mesh>
        </group>
      ))}
      
      {[-12, -8, 10, 14].map((z, i) => (
        <group key={`cactus-right-${i}`} position={[15, -7.5, z]}>
          <mesh castShadow>
            <cylinderGeometry args={[0.3, 0.3, 3]} />
            <meshStandardMaterial color="#4a7c4a" roughness={0.9} />
          </mesh>
          <mesh position={[0.4, 0.8, 0]} rotation={[0, 0, -Math.PI / 3]} castShadow>
            <cylinderGeometry args={[0.2, 0.2, 1]} />
            <meshStandardMaterial color="#4a7c4a" roughness={0.9} />
          </mesh>
        </group>
      ))}
      
      <Horse position={[-10, -7.5, -10]} speed={0.25} path={4} color="#8B4513" />
      <Horse position={[12, -7.5, -12]} speed={0.22} path={3.5} color="#654321" />
      <Horse position={[-8, -7.5, 10]} speed={0.28} path={3} color="#A0522D" />
      <Horse position={[10, -7.5, 12]} speed={0.24} path={4} color="#D2691E" />
      <Horse position={[0, -7.5, -15]} speed={0.2} path={5} color="#8B4513" />
      
      {/* Mar infinito 360 grados - anillo alrededor de la isla */}
      <mesh position={[0, -7.2, 0]} rotation={[-Math.PI / 2, 0, 0]}>
        <ringGeometry args={[45, 200, 32]} />
        <meshStandardMaterial 
          color="#1e90ff" 
          roughness={0.2} 
          metalness={0.6}
          emissive="#0066cc"
          emissiveIntensity={0.15}
          side={2}
        />
      </mesh>
      
      {/* Olas en círculo */}
      {[0, 60, 120, 180, 240, 300].map((angle, i) => {
        const rad = (angle * Math.PI) / 180
        const distance = 50
        return (
          <mesh 
            key={`wave-${i}`}
            position={[Math.cos(rad) * distance, -7.1, Math.sin(rad) * distance]} 
            rotation={[-Math.PI / 2, 0, rad]}
          >
            <planeGeometry args={[20, 3]} />
            <meshStandardMaterial 
              color="#4da6ff" 
              transparent
              opacity={0.6}
            />
          </mesh>
        )
      })}
    </group>
  )
})

export default WildBackground
