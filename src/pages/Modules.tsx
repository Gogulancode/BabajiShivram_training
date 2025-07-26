import React, { useState } from 'react';
import { Link } from 'react-router-dom';
import {
  ArrowDownToLine,
  ArrowUpFromLine,
  Truck,
  Package,
  BarChart3,
  Users,
  Ship,
  Archive,
  Clock,
  CheckCircle,
  File
} from 'lucide-react';
import { modules } from '../data/mockData'; // ✅ IMPORTANT

const iconMap = {
  ArrowDownToLine,
  ArrowUpFromLine,
  Truck,
  Package,
  BarChart3,
  Users,
  Ship,
  Archive,
  File
};

const ModulesPage: React.FC = () => {
  const [filter, setFilter] = useState('all');
  const [sortBy, setSortBy] = useState('title');

  const filteredModules = modules.filter(module => {
    if (filter === 'completed') return module.progress >= 100;
    if (filter === 'in-progress') return module.progress > 0 && module.progress < 100;
    if (filter === 'not-started') return module.progress === 0;
    return true;
  });

  const sortedModules = [...filteredModules].sort((a, b) => {
    if (sortBy === 'title') return a.title.localeCompare(b.title);
    if (sortBy === 'progress') return b.progress - a.progress;
    if (sortBy === 'difficulty') return a.difficulty.localeCompare(b.difficulty);
    return 0;
  });

  return (
    <div className="space-y-6">
      {/* Filters */}
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between">
        <h1 className="text-2xl font-bold text-gray-900">Training Modules</h1>

        <div className="flex flex-col sm:flex-row gap-4 mt-4 sm:mt-0">
          <select
            value={filter}
            onChange={(e) => setFilter(e.target.value)}
            className="px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
          >
            <option value="all">All Modules</option>
            <option value="completed">Completed</option>
            <option value="in-progress">In Progress</option>
            <option value="not-started">Not Started</option>
          </select>

          <select
            value={sortBy}
            onChange={(e) => setSortBy(e.target.value)}
            className="px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
          >
            <option value="title">Sort by Title</option>
            <option value="progress">Sort by Progress</option>
            <option value="difficulty">Sort by Difficulty</option>
          </select>
        </div>
      </div>

      {/* Module Cards */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {sortedModules.map((module) => {
          const IconComponent = iconMap[module.icon as keyof typeof iconMap] || File;
          const moduleLink = `/modules/${module.id}`;

          return (
            <Link
              to={moduleLink}
              key={module.id}
              className="bg-white rounded-lg p-6 shadow-sm border border-gray-200 hover:shadow-md transition-all duration-200 cursor-pointer group"
            >
              <div className="flex items-start justify-between mb-4">
                <div className="p-3 bg-blue-100 rounded-lg group-hover:bg-blue-200 transition-colors">
                  <IconComponent className="h-6 w-6 text-blue-600" />
                </div>
                <div className="flex items-center space-x-2">
                  {module.progress >= 100 && (
                    <CheckCircle className="h-5 w-5 text-green-500" />
                  )}
                  <span
                    className={`px-2 py-1 text-xs font-medium rounded-full ${
                      module.progress >= 100
                        ? 'bg-green-100 text-green-800'
                        : module.progress > 0
                        ? 'bg-orange-100 text-orange-800'
                        : 'bg-gray-100 text-gray-800'
                    }`}
                  >
                    {module.progress >= 100
                      ? 'Completed'
                      : module.progress > 0
                      ? 'In Progress'
                      : 'Not Started'}
                  </span>
                </div>
              </div>

              <h3 className="font-semibold text-gray-900 mb-2 group-hover:text-blue-600 transition-colors">
                {module.title}
              </h3>
              <p className="text-sm text-gray-600 mb-4 line-clamp-2">{module.description}</p>

              <div className="space-y-3">
                <div className="flex items-center justify-between text-sm">
                  <span className="text-gray-500">Progress</span>
                  <span className="font-medium">{module.progress}%</span>
                </div>

                <div className="w-full bg-gray-200 rounded-full h-2">
                  <div
                    className="bg-blue-600 h-2 rounded-full transition-all duration-300"
                    style={{ width: `${module.progress}%` }}
                  />
                </div>

                <div className="flex items-center justify-between pt-2">
                  <div className="flex items-center text-xs text-gray-500">
                    <Clock className="h-3 w-3 mr-1" />
                    {module.estimatedTime}
                  </div>
                  <span className="text-xs text-gray-500 bg-gray-100 px-2 py-1 rounded-full">
                    {module.difficulty}
                  </span>
                </div>
              </div>

              <button className="w-full mt-4 px-4 py-2 bg-blue-600 text-white text-sm font-medium rounded-lg hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-500 transition-colors">
                {module.progress >= 100
                  ? 'Review'
                  : module.progress > 0
                  ? 'Continue'
                  : 'Start'}
              </button>
            </Link>
          );
        })}
      </div>

      {sortedModules.length === 0 && (
        <div className="text-center py-12">
          <div className="text-gray-400 mb-4">No modules found</div>
          <p className="text-sm text-gray-500">Try adjusting your filters to see more results.</p>
        </div>
      )}
    </div>
  );
};

export default ModulesPage;
