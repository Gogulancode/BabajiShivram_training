import React from 'react';
import { CheckCircle, Clock, Award, TrendingUp, Calendar, Target } from 'lucide-react';
import { modules } from '../data/mockData';

const Progress: React.FC = () => {
  const completedModules = modules.filter(m => m.isCompleted);
  const inProgressModules = modules.filter(m => !m.isCompleted && m.completionRate > 0);
  const notStartedModules = modules.filter(m => m.completionRate === 0);
  
  const overallProgress = Math.round(
    modules.reduce((sum, module) => sum + module.completionRate, 0) / modules.length
  );

  const recentActivity = [
    { id: 1, action: 'Completed Export Operations module', date: '2 days ago', type: 'completion' },
    { id: 2, action: 'Started Import Management module', date: '5 days ago', type: 'start' },
    { id: 3, action: 'Updated progress in Freight Management', date: '1 week ago', type: 'progress' },
    { id: 4, action: 'Completed Financial Reports module', date: '2 weeks ago', type: 'completion' }
  ];

  const getActivityIcon = (type: string) => {
    switch (type) {
      case 'completion': return <CheckCircle className="h-4 w-4 text-green-500" />;
      case 'start': return <Clock className="h-4 w-4 text-blue-500" />;
      default: return <TrendingUp className="h-4 w-4 text-orange-500" />;
    }
  };

  return (
    <div className="space-y-8">
      <div>
        <h1 className="text-2xl font-bold text-gray-900 mb-2">My Training Progress</h1>
        <p className="text-gray-600">Track your learning journey and achievements</p>
      </div>

      {/* Progress Overview */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-6">
        <div className="bg-white rounded-lg p-6 shadow-sm border border-gray-200">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-gray-600">Overall Progress</p>
              <p className="text-2xl font-bold text-blue-600">{overallProgress}%</p>
            </div>
            <div className="p-3 bg-blue-100 rounded-full">
              <Target className="h-6 w-6 text-blue-600" />
            </div>
          </div>
          <div className="mt-4">
            <div className="w-full bg-gray-200 rounded-full h-2">
              <div
                className="bg-blue-600 h-2 rounded-full transition-all duration-300"
                style={{ width: `${overallProgress}%` }}
              />
            </div>
          </div>
        </div>

        <div className="bg-white rounded-lg p-6 shadow-sm border border-gray-200">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-gray-600">Completed</p>
              <p className="text-2xl font-bold text-green-600">{completedModules.length}</p>
            </div>
            <div className="p-3 bg-green-100 rounded-full">
              <CheckCircle className="h-6 w-6 text-green-600" />
            </div>
          </div>
        </div>

        <div className="bg-white rounded-lg p-6 shadow-sm border border-gray-200">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-gray-600">In Progress</p>
              <p className="text-2xl font-bold text-orange-600">{inProgressModules.length}</p>
            </div>
            <div className="p-3 bg-orange-100 rounded-full">
              <Clock className="h-6 w-6 text-orange-600" />
            </div>
          </div>
        </div>

        <div className="bg-white rounded-lg p-6 shadow-sm border border-gray-200">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-gray-600">Not Started</p>
              <p className="text-2xl font-bold text-gray-600">{notStartedModules.length}</p>
            </div>
            <div className="p-3 bg-gray-100 rounded-full">
              <Award className="h-6 w-6 text-gray-600" />
            </div>
          </div>
        </div>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
        {/* Module Progress */}
        <div className="bg-white rounded-lg p-6 shadow-sm border border-gray-200">
          <h2 className="text-lg font-semibold text-gray-900 mb-4">Module Progress</h2>
          
          <div className="space-y-4">
            {modules.map(module => (
              <div key={module.id} className="border-b border-gray-100 pb-4 last:border-b-0">
                <div className="flex items-center justify-between mb-2">
                  <h3 className="font-medium text-gray-900">{module.title}</h3>
                  <div className="flex items-center space-x-2">
                    {module.isCompleted && (
                      <CheckCircle className="h-5 w-5 text-green-500" />
                    )}
                    <span className="text-sm font-medium text-gray-600">
                      {module.completionRate}%
                    </span>
                  </div>
                </div>
                
                <div className="w-full bg-gray-200 rounded-full h-2 mb-2">
                  <div
                    className={`h-2 rounded-full transition-all duration-300 ${
                      module.isCompleted ? 'bg-green-500' : 'bg-blue-600'
                    }`}
                    style={{ width: `${module.completionRate}%` }}
                  />
                </div>
                
                <div className="flex justify-between text-xs text-gray-500">
                  <span>{module.category}</span>
                  <span>{module.estimatedTime}</span>
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* Recent Activity */}
        <div className="bg-white rounded-lg p-6 shadow-sm border border-gray-200">
          <h2 className="text-lg font-semibold text-gray-900 mb-4 flex items-center">
            <Calendar className="h-5 w-5 mr-2" />
            Recent Activity
          </h2>
          
          <div className="space-y-4">
            {recentActivity.map(activity => (
              <div key={activity.id} className="flex items-start space-x-3">
                <div className="flex-shrink-0 mt-1">
                  {getActivityIcon(activity.type)}
                </div>
                <div className="flex-1 min-w-0">
                  <p className="text-sm text-gray-900">{activity.action}</p>
                  <p className="text-xs text-gray-500">{activity.date}</p>
                </div>
              </div>
            ))}
          </div>
          
          <button className="w-full mt-4 px-4 py-2 text-sm font-medium text-blue-600 hover:text-blue-700 hover:bg-blue-50 rounded-lg transition-colors">
            View All Activity
          </button>
        </div>
      </div>

      {/* Achievements */}
      <div className="bg-white rounded-lg p-6 shadow-sm border border-gray-200">
        <h2 className="text-lg font-semibold text-gray-900 mb-4 flex items-center">
          <Award className="h-5 w-5 mr-2" />
          Achievements
        </h2>
        
        <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
          <div className="flex items-center p-4 bg-green-50 rounded-lg">
            <div className="p-2 bg-green-100 rounded-full mr-4">
              <CheckCircle className="h-6 w-6 text-green-600" />
            </div>
            <div>
              <h3 className="font-medium text-green-900">First Module Complete</h3>
              <p className="text-sm text-green-700">Completed your first training module</p>
            </div>
          </div>
          
          <div className="flex items-center p-4 bg-blue-50 rounded-lg">
            <div className="p-2 bg-blue-100 rounded-full mr-4">
              <TrendingUp className="h-6 w-6 text-blue-600" />
            </div>
            <div>
              <h3 className="font-medium text-blue-900">Quick Learner</h3>
              <p className="text-sm text-blue-700">Completed a module in under 1 hour</p>
            </div>
          </div>
          
          <div className="flex items-center p-4 bg-purple-50 rounded-lg">
            <div className="p-2 bg-purple-100 rounded-full mr-4">
              <Award className="h-6 w-6 text-purple-600" />
            </div>
            <div>
              <h3 className="font-medium text-purple-900">Dedicated Learner</h3>
              <p className="text-sm text-purple-700">50% overall progress achieved</p>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default Progress;