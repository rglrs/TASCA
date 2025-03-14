import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import Dashboard from './pages/Dashboard';
import NotFound from './pages/NotFound';
import ForgotPasswordConfirm from './component/ForgotPasswordConfirm';
import Pomodoro from './component/pomodoro';

const routes = [
  { path: '/', element: <Dashboard /> },
  { path: '*', element: <NotFound /> },
  { path: 'ForgotPasswordConfirm', element: <ForgotPasswordConfirm/>},
  { path: 'Pomodoro', element: <Pomodoro />},
];

function App() {
  return (
    <Router>
      <Routes>
        {routes.map((route, index) => (
          <Route key={index} path={route.path} element={route.element} />
        ))}
      </Routes>
    </Router>
  );
}

export default App;
