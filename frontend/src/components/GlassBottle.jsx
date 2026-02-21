import { useRef, memo } from 'react'
import { useFrame } from '@react-three/fiber'

const GlassBottle = memo(function GlassBottle() {
  const bowlRef = useRef()
  
  useFrame((state) => {
    if (bowlRef.current) {
      bowlRef.current.rotation.y = Math.sin(state.clock.elapsedTime * 0.2) * 0.05
    }
  })

  return (
    <group ref={bowlRef}>
      <mesh position={[0, -2, 0]} rotation={[Math.PI, 0, 0]} receiveShadow>
        <sphereGeometry args={[2.2, 24, 24, 0, Math.PI * 2, 0, Math.PI * 0.5]} />
        <meshPhysicalMaterial
          color="#d0e8f2"
          transparent={true}
          opacity={0.25}
          roughness={0.05}
          metalness={0.0}
          transmission={0.9}
          thickness={0.2}
          envMapIntensity={1}
          clearcoat={1}
          clearcoatRoughness={0.05}
          ior={1.5}
          side={2}
        />
      </mesh>
      
      <pointLight position={[0, -1, 0]} intensity={0.3} color="#88ccee" distance={5} />
    </group>
  )
})

export default GlassBottle
