import React from 'react';
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
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
import { currentUser } from './data/mockData';

// Protected Route Component for Admin-only pages
const ProtectedRoute: React.FC<{ children: React.ReactNode; adminOnly?: boolean }> = ({ 
  children, 
  adminOnly = false 
}) => {
  if (adminOnly && currentUser.role !== 'Admin') {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="text-center">
          <div className="text-6xl mb-4">🔒</div>
          <h2 className="text-xl font-semibold text-gray-900 mb-2">Access Denied</h2>
          <p className="text-gray-600">This page is only accessible to administrators.</p>
        </div>
      </div>
    );
  }
  return <>{children}</>;
};

function App() {
  return (
    <Router>
      <Routes>
        <Route path="/" element={<Layout />}>
          <Route index element={<Dashboard />} />
          <Route path="modules" element={<Modules />} />
          <Route path="upload" element={<UploadContent />} />
          <Route path="search" element={<Search />} />
          <Route path="progress" element={<Progress />} />
          <Route path="modules/import-management" element={<ImportManagement />} />
          <Route path="assessments" element={<Assessments />} />
          <Route path="assessments/:id/take" element={<TakeAssessment />} />
          <Route path="settings" element={
            <ProtectedRoute adminOnly={true}>
              <Settings />
            </ProtectedRoute>
          } />
        </Route>
      </Routes>
    </Router>
  );
}

export default App;