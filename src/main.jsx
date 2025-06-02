import { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'
import './index.css'
import axios from 'axios'
import App from './App.jsx'

axios.defaults.withCredentials = true;
axios.defaults.baseURL = 'https://api.tascaid.com';

createRoot(document.getElementById('root')).render(
  <StrictMode>
    <App />
  </StrictMode>
);
