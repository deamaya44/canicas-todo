import { useState, useEffect } from 'react';
import { signInWithPopup, signOut, onAuthStateChanged } from 'firebase/auth';
import { auth, googleProvider } from '../firebase';
import './Auth.css';

function Auth() {
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const unsubscribe = onAuthStateChanged(auth, (currentUser) => {
      setUser(currentUser);
      setLoading(false);
    });

    return () => unsubscribe();
  }, []);

  const handleLogin = async () => {
    try {
      await signInWithPopup(auth, googleProvider);
    } catch (error) {
      console.error('Login error:', error);
      alert('Error al iniciar sesión');
    }
  };

  const handleLogout = async () => {
    try {
      await signOut(auth);
    } catch (error) {
      console.error('Logout error:', error);
    }
  };

  if (loading) {
    return <div className="auth-loading">Cargando...</div>;
  }

  if (!user) {
    return (
      <div className="auth-container">
        <div className="auth-card">
          <h1>🎯 Canicas Todo</h1>
          <p>Inicia sesión para gestionar tus tareas</p>
          <button onClick={handleLogin} className="google-btn">
            <img src="https://www.gstatic.com/firebasejs/ui/2.0.0/images/auth/google.svg" alt="Google" />
            Continuar con Google
          </button>
        </div>
      </div>
    );
  }

  return (
    <div className="auth-user">
      <img src={user.photoURL} alt={user.displayName} className="user-avatar" />
      <span className="user-name">{user.displayName}</span>
      <button onClick={handleLogout} className="logout-btn">
        Cerrar sesión
      </button>
    </div>
  );
}

export default Auth;
