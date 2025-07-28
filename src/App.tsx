import React from 'react';
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';

import Layout from './components/Layout/Layout';
import Dashboard from './pages/Dashboard';
import Modules from './pages/Modules';
import UploadContent from './pages/UploadContent';
import Search from './pages/Search';
import Progress from './pages/Progress';
import ImportManagement from './pages/ImportManagement';
import Settings from './pages/Settings';
import Assessments from './pages/Assessments';
import TakeAssessment from './pages/TakeAssessment';
import Login from './pages/Login';
import Profile from './pages/Profile';

// Check if user is authenticated
const isAuthenticated = () => {
  return localStorage.getItem('token') !== null;
};

// Protected Route Component
const ProtectedRoute: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  if (!isAuthenticated()) {
    return <Navigate to="/login" replace />;
  }
  return <>{children}</>;
};

function App() {
  return (
    <Router>
      <Routes>
        <Route path="/login" element={<Login />} />
        <Route path="/" element={
          <ProtectedRoute>
            <Layout />
          </ProtectedRoute>
        }>
          <Route index element={<Dashboard />} />
          <Route path="modules" element={<Modules />} />
          <Route path="modules/:id" element={<ImportManagement />} />
          <Route path="upload" element={<UploadContent />} />
          <Route path="search" element={<Search />} />
          <Route path="progress" element={<Progress />} />
          <Route path="modules/import-management" element={<ImportManagement />} />
          <Route path="assessments" element={<Assessments />} />
          <Route path="assessments/:id/take" element={<TakeAssessment />} />
          <Route path="settings" element={<Settings />} />
          <Route path="profile" element={<Profile />} />
        </Route>
      </Routes>
    </Router>
  );
}

export default App;
