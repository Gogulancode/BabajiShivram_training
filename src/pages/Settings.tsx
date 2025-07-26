import React, { useState } from 'react';
import { Settings as SettingsIcon, Plus, Edit, Trash2, Save, X, ChevronDown, ChevronRight, BookOpen, FileText, Users, Shield } from 'lucide-react';

interface Module {
  id: string;
  title: string;
  description: string;
  icon: string;
  category: string;
  isActive: boolean;
  sections: Section[];
}

interface Section {
  id: string;
  title: string;
  description: string;
  moduleId: string;
  order: number;
  isActive: boolean;
  lessons: Lesson[];
}

interface Lesson {
  id: string;
  title: string;
  description: string;
  type: 'video' | 'document' | 'interactive' | 'quiz';
  duration: string;
  sectionId: string;
  order: number;
  isActive: boolean;
  content: {
    videoUrl?: string;
    documentContent?: string;
    interactiveSteps?: string[];
    quizQuestions?: any[];
  };
}

const Settings: React.FC = () => {
  const [activeTab, setActiveTab] = useState<'modules' | 'sections' | 'lessons'>('modules');
  const [expandedModules, setExpandedModules] = useState<string[]>([]);
  const [expandedSections, setExpandedSections] = useState<string[]>([]);
  const [editingItem, setEditingItem] = useState<string | null>(null);
  const [showAddForm, setShowAddForm] = useState<string | null>(null);

  // Mock data - in real app this would come from API
  const [modules, setModules] = useState<Module[]>([
    {
      id: '1',
      title: 'Import Management',
      description: 'Learn to handle import processes, documentation, and compliance',
      icon: 'ArrowDownToLine',
      category: 'Trade',
      isActive: true,
      sections: [
        {
          id: '1-1',
          title: 'Import Fundamentals',
          description: 'Basic concepts and overview of import processes',
          moduleId: '1',
          order: 1,
          isActive: true,
          lessons: [
            {
              id: '1-1-1',
              title: 'Introduction to Import Management',
              description: 'Overview of import processes and key stakeholders',
              type: 'video',
              duration: '15 min',
              sectionId: '1-1',
              order: 1,
              isActive: true,
              content: { videoUrl: 'https://www.youtube.com/embed/example' }
            },
            {
              id: '1-1-2',
              title: 'Import Terminology',
              description: 'Key terms and definitions in import management',
              type: 'document',
              duration: '10 min',
              sectionId: '1-1',
              order: 2,
              isActive: true,
              content: { documentContent: '<h3>Import Terminology</h3><p>Key terms...</p>' }
            }
          ]
        },
        {
          id: '1-2',
          title: 'Documentation & Compliance',
          description: 'Required documents and compliance procedures',
          moduleId: '1',
          order: 2,
          isActive: true,
          lessons: [
            {
              id: '1-2-1',
              title: 'Import Documentation Requirements',
              description: 'Essential documents for import operations',
              type: 'document',
              duration: '20 min',
              sectionId: '1-2',
              order: 1,
              isActive: true,
              content: { documentContent: '<h3>Documentation</h3><p>Required docs...</p>' }
            }
          ]
        }
      ]
    },
    {
      id: '2',
      title: 'Export Operations',
      description: 'Master export procedures and international regulations',
      icon: 'ArrowUpFromLine',
      category: 'Trade',
      isActive: true,
      sections: []
    }
  ]);

  const [newModule, setNewModule] = useState({
    title: '',
    description: '',
    icon: 'BookOpen',
    category: '',
    isActive: true
  });

  const [newSection, setNewSection] = useState({
    title: '',
    description: '',
    moduleId: '',
    order: 1,
    isActive: true
  });

  const [newLesson, setNewLesson] = useState({
    title: '',
    description: '',
    type: 'video' as 'video' | 'document' | 'interactive' | 'quiz',
    duration: '',
    sectionId: '',
    order: 1,
    isActive: true,
    videoUrl: '',
    documentContent: ''
  });

  const toggleModuleExpansion = (moduleId: string) => {
    setExpandedModules(prev => 
      prev.includes(moduleId) 
        ? prev.filter(id => id !== moduleId)
        : [...prev, moduleId]
    );
  };

  const toggleSectionExpansion = (sectionId: string) => {
    setExpandedSections(prev => 
      prev.includes(sectionId) 
        ? prev.filter(id => id !== sectionId)
        : [...prev, sectionId]
    );
  };

  const handleAddModule = () => {
    if (newModule.title && newModule.description) {
      const module: Module = {
        id: Date.now().toString(),
        ...newModule,
        sections: []
      };
      setModules(prev => [...prev, module]);
      setNewModule({ title: '', description: '', icon: 'BookOpen', category: '', isActive: true });
      setShowAddForm(null);
    }
  };

  const handleAddSection = () => {
    if (newSection.title && newSection.description && newSection.moduleId) {
      const section: Section = {
        id: Date.now().toString(),
        ...newSection,
        lessons: []
      };
      setModules(prev => prev.map(module => 
        module.id === newSection.moduleId 
          ? { ...module, sections: [...module.sections, section] }
          : module
      ));
      setNewSection({ title: '', description: '', moduleId: '', order: 1, isActive: true });
      setShowAddForm(null);
    }
  };

  const handleAddLesson = () => {
    if (newLesson.title && newLesson.description && newLesson.sectionId) {
      const lesson: Lesson = {
        id: Date.now().toString(),
        title: newLesson.title,
        description: newLesson.description,
        type: newLesson.type,
        duration: newLesson.duration,
        sectionId: newLesson.sectionId,
        order: newLesson.order,
        isActive: newLesson.isActive,
        content: {
          videoUrl: newLesson.videoUrl || undefined,
          documentContent: newLesson.documentContent || undefined
        }
      };

      setModules(prev => prev.map(module => ({
        ...module,
        sections: module.sections.map(section => 
          section.id === newLesson.sectionId
            ? { ...section, lessons: [...section.lessons, lesson] }
            : section
        )
      })));

      setNewLesson({
        title: '',
        description: '',
        type: 'video',
        duration: '',
        sectionId: '',
        order: 1,
        isActive: true,
        videoUrl: '',
        documentContent: ''
      });
      setShowAddForm(null);
    }
  };

  const handleDeleteModule = (moduleId: string) => {
    if (confirm('Are you sure you want to delete this module? This will also delete all sections and lessons within it.')) {
      setModules(prev => prev.filter(module => module.id !== moduleId));
    }
  };

  const handleDeleteSection = (moduleId: string, sectionId: string) => {
    if (confirm('Are you sure you want to delete this section? This will also delete all lessons within it.')) {
      setModules(prev => prev.map(module => 
        module.id === moduleId
          ? { ...module, sections: module.sections.filter(section => section.id !== sectionId) }
          : module
      ));
    }
  };

  const handleDeleteLesson = (moduleId: string, sectionId: string, lessonId: string) => {
    if (confirm('Are you sure you want to delete this lesson?')) {
      setModules(prev => prev.map(module => 
        module.id === moduleId
          ? {
              ...module,
              sections: module.sections.map(section => 
                section.id === sectionId
                  ? { ...section, lessons: section.lessons.filter(lesson => lesson.id !== lessonId) }
                  : section
              )
            }
          : module
      ));
    }
  };

  const getLessonTypeIcon = (type: string) => {
    switch (type) {
      case 'video': return '🎥';
      case 'document': return '📄';
      case 'interactive': return '🎯';
      case 'quiz': return '❓';
      default: return '📄';
    }
  };

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div className="flex items-center space-x-3">
          <div className="p-3 bg-gray-100 rounded-lg">
            <SettingsIcon className="h-8 w-8 text-gray-600" />
          </div>
          <div>
            <h1 className="text-2xl font-bold text-gray-900">Settings</h1>
            <p className="text-gray-600">Manage modules, sections, and lessons</p>
          </div>
        </div>
        <div className="flex items-center space-x-2">
          <Shield className="h-5 w-5 text-red-500" />
          <span className="text-sm font-medium text-red-600">Admin Only</span>
        </div>
      </div>

      {/* Navigation Tabs */}
      <div className="border-b border-gray-200">
        <nav className="flex space-x-8">
          {[
            { id: 'modules', label: 'Module Master', icon: BookOpen },
            { id: 'sections', label: 'Section Master', icon: FileText }
          ].map(tab => {
            const Icon = tab.icon;
            return (
              <button
                key={tab.id}
                onClick={() => setActiveTab(tab.id as any)}
                className={`
                  flex items-center px-1 py-4 border-b-2 font-medium text-sm transition-colors
                  ${activeTab === tab.id
                    ? 'border-blue-500 text-blue-600'
                    : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
                  }
                `}
              >
                <Icon className={`mr-2 h-4 w-4 ${activeTab === tab.id ? 'text-blue-600' : 'text-gray-500'}`} />
                {tab.label}
              </button>
            );
          })}
        </nav>
      </div>

      {/* Content */}
      <div className="space-y-6">
        {activeTab === 'modules' && (
          <div className="space-y-6">
            {/* Add Module Button */}
            <div className="flex justify-between items-center">
              <h2 className="text-lg font-semibold text-gray-900">Module Management</h2>
              <button
                onClick={() => setShowAddForm('module')}
                className="flex items-center px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors"
              >
                <Plus className="h-4 w-4 mr-2" />
                Add Module
              </button>
            </div>

            {/* Add Module Form */}
            {showAddForm === 'module' && (
              <div className="bg-white border border-gray-200 rounded-lg p-6">
                <h3 className="text-lg font-medium text-gray-900 mb-4">Add New Module</h3>
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-2">Title</label>
                    <input
                      type="text"
                      value={newModule.title}
                      onChange={(e) => setNewModule(prev => ({ ...prev, title: e.target.value }))}
                      className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
                      placeholder="Module title"
                    />
                  </div>
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-2">Category</label>
                    <input
                      type="text"
                      value={newModule.category}
                      onChange={(e) => setNewModule(prev => ({ ...prev, category: e.target.value }))}
                      className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
                      placeholder="Module category"
                    />
                  </div>
                  <div className="md:col-span-2">
                    <label className="block text-sm font-medium text-gray-700 mb-2">Description</label>
                    <textarea
                      value={newModule.description}
                      onChange={(e) => setNewModule(prev => ({ ...prev, description: e.target.value }))}
                      rows={3}
                      className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
                      placeholder="Module description"
                    />
                  </div>
                </div>
                <div className="flex justify-end space-x-3 mt-4">
                  <button
                    onClick={() => setShowAddForm(null)}
                    className="px-4 py-2 text-gray-600 hover:text-gray-800 transition-colors"
                  >
                    Cancel
                  </button>
                  <button
                    onClick={handleAddModule}
                    className="flex items-center px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors"
                  >
                    <Save className="h-4 w-4 mr-2" />
                    Save Module
                  </button>
                </div>
              </div>
            )}

            {/* Modules List */}
            <div className="space-y-4">
              {modules.map(module => (
                <div key={module.id} className="bg-white border border-gray-200 rounded-lg">
                  <div className="p-6">
                    <div className="flex items-center justify-between">
                      <div className="flex items-center space-x-4">
                        <button
                          onClick={() => toggleModuleExpansion(module.id)}
                          className="p-1 hover:bg-gray-100 rounded transition-colors"
                        >
                          {expandedModules.includes(module.id) ? (
                            <ChevronDown className="h-4 w-4 text-gray-500" />
                          ) : (
                            <ChevronRight className="h-4 w-4 text-gray-500" />
                          )}
                        </button>
                        <div>
                          <h3 className="font-semibold text-gray-900">{module.title}</h3>
                          <p className="text-sm text-gray-600">{module.description}</p>
                          <div className="flex items-center space-x-4 mt-2">
                            <span className="text-xs bg-blue-100 text-blue-800 px-2 py-1 rounded-full">
                              {module.category}
                            </span>
                            <span className="text-xs text-gray-500">
                              {module.sections.length} sections
                            </span>
                            <span className={`text-xs px-2 py-1 rounded-full ${
                              module.isActive ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800'
                            }`}>
                              {module.isActive ? 'Active' : 'Inactive'}
                            </span>
                          </div>
                        </div>
                      </div>
                      <div className="flex items-center space-x-2">
                        <button className="p-2 text-gray-500 hover:text-blue-600 hover:bg-blue-50 rounded transition-colors">
                          <Edit className="h-4 w-4" />
                        </button>
                        <button 
                          onClick={() => handleDeleteModule(module.id)}
                          className="p-2 text-gray-500 hover:text-red-600 hover:bg-red-50 rounded transition-colors"
                        >
                          <Trash2 className="h-4 w-4" />
                        </button>
                      </div>
                    </div>

                    {/* Sections */}
                    {expandedModules.includes(module.id) && (
                      <div className="mt-6 pl-8 space-y-3">
                        <div className="flex items-center justify-between">
                          <h4 className="font-medium text-gray-700">Sections ({module.sections.length})</h4>
                          <button
                            onClick={() => {
                              setNewSection(prev => ({ ...prev, moduleId: module.id }));
                              setShowAddForm('section');
                            }}
                            className="text-sm text-blue-600 hover:text-blue-700"
                          >
                            + Add Section
                          </button>
                        </div>
                        {module.sections.map(section => (
                          <div key={section.id} className="bg-gray-50 border border-gray-200 rounded-lg p-4">
                            <div className="flex items-center justify-between">
                              <div className="flex items-center space-x-3">
                                <button
                                  onClick={() => toggleSectionExpansion(section.id)}
                                  className="p-1 hover:bg-gray-200 rounded transition-colors"
                                >
                                  {expandedSections.includes(section.id) ? (
                                    <ChevronDown className="h-3 w-3 text-gray-500" />
                                  ) : (
                                    <ChevronRight className="h-3 w-3 text-gray-500" />
                                  )}
                                </button>
                                <div>
                                  <h5 className="font-medium text-gray-900">{section.title}</h5>
                                  <p className="text-sm text-gray-600">{section.description}</p>
                                  <span className="text-xs text-gray-500">
                                    Order: {section.order} • {section.lessons.length} lessons
                                  </span>
                                </div>
                              </div>
                              <div className="flex items-center space-x-2">
                                <button className="p-1 text-gray-500 hover:text-blue-600 hover:bg-blue-50 rounded transition-colors">
                                  <Edit className="h-3 w-3" />
                                </button>
                                <button 
                                  onClick={() => handleDeleteSection(module.id, section.id)}
                                  className="p-1 text-gray-500 hover:text-red-600 hover:bg-red-50 rounded transition-colors"
                                >
                                  <Trash2 className="h-3 w-3" />
                                </button>
                              </div>
                            </div>

                            {/* Lessons */}
                            {expandedSections.includes(section.id) && (
                              <div className="mt-4 pl-6 space-y-2">
                                <div className="flex items-center justify-between">
                                  <h6 className="text-sm font-medium text-gray-600">Lessons ({section.lessons.length})</h6>
                                  <button
                                    onClick={() => {
                                      setNewLesson(prev => ({ ...prev, sectionId: section.id }));
                                      setShowAddForm('lesson');
                                    }}
                                    className="text-xs text-blue-600 hover:text-blue-700"
                                  >
                                    + Add Lesson
                                  </button>
                                </div>
                                {section.lessons.map(lesson => (
                                  <div key={lesson.id} className="bg-white border border-gray-200 rounded p-3">
                                    <div className="flex items-center justify-between">
                                      <div className="flex items-center space-x-3">
                                        <span className="text-lg">{getLessonTypeIcon(lesson.type)}</span>
                                        <div>
                                          <h6 className="text-sm font-medium text-gray-900">{lesson.title}</h6>
                                          <p className="text-xs text-gray-600">{lesson.description}</p>
                                          <div className="flex items-center space-x-2 mt-1">
                                            <span className="text-xs bg-purple-100 text-purple-800 px-2 py-1 rounded">
                                              {lesson.type}
                                            </span>
                                            <span className="text-xs text-gray-500">Order: {lesson.order}</span>
                                            <span className="text-xs text-gray-500">{lesson.duration}</span>
                                          </div>
                                        </div>
                                      </div>
                                      <div className="flex items-center space-x-1">
                                        <button className="p-1 text-gray-500 hover:text-blue-600 hover:bg-blue-50 rounded transition-colors">
                                          <Edit className="h-3 w-3" />
                                        </button>
                                        <button 
                                          onClick={() => handleDeleteLesson(module.id, section.id, lesson.id)}
                                          className="p-1 text-gray-500 hover:text-red-600 hover:bg-red-50 rounded transition-colors"
                                        >
                                          <Trash2 className="h-3 w-3" />
                                        </button>
                                      </div>
                                    </div>
                                  </div>
                                ))}
                              </div>
                            )}
                          </div>
                        ))}
                      </div>
                    )}
                  </div>
                </div>
              ))}
            </div>
          </div>
        )}

        {activeTab === 'sections' && (
          <div className="space-y-6">
            {/* Add Section Button */}
            <div className="flex justify-between items-center">
              <h2 className="text-lg font-semibold text-gray-900">Section Management</h2>
              <button
                onClick={() => setShowAddForm('section')}
                className="flex items-center px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors"
              >
                <Plus className="h-4 w-4 mr-2" />
                Add Section
              </button>
            </div>

            {/* Sections List */}
            <div className="space-y-4">
              {modules.map(module => (
                <div key={module.id} className="bg-white border border-gray-200 rounded-lg">
                  <div className="p-4 bg-gray-50 border-b border-gray-200">
                    <h3 className="font-semibold text-gray-900">{module.title}</h3>
                    <p className="text-sm text-gray-600">{module.sections.length} sections</p>
                  </div>
                  <div className="p-4 space-y-3">
                    {module.sections.length > 0 ? (
                      module.sections.map(section => (
                        <div key={section.id} className="flex items-center justify-between p-3 bg-gray-50 rounded-lg">
                          <div>
                            <h4 className="font-medium text-gray-900">{section.title}</h4>
                            <p className="text-sm text-gray-600">{section.description}</p>
                            <div className="flex items-center space-x-4 mt-1">
                              <span className="text-xs text-gray-500">Order: {section.order}</span>
                              <span className={`text-xs px-2 py-1 rounded-full ${
                                section.isActive ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800'
                              }`}>
                                {section.isActive ? 'Active' : 'Inactive'}
                              </span>
                            </div>
                          </div>
                          <div className="flex items-center space-x-2">
                            <button className="p-2 text-gray-500 hover:text-blue-600 hover:bg-blue-50 rounded transition-colors">
                              <Edit className="h-4 w-4" />
                            </button>
                            <button 
                              onClick={() => handleDeleteSection(module.id, section.id)}
                              className="p-2 text-gray-500 hover:text-red-600 hover:bg-red-50 rounded transition-colors"
                            >
                              <Trash2 className="h-4 w-4" />
                            </button>
                          </div>
                        </div>
                      ))
                    ) : (
                      <p className="text-gray-500 text-center py-4">No sections created yet</p>
                    )}
                  </div>
                </div>
              ))}
            </div>
          </div>
        )}

        {/* Add Section Form */}
        {showAddForm === 'section' && (
          <div className="bg-white border border-gray-200 rounded-lg p-6">
            <h3 className="text-lg font-medium text-gray-900 mb-4">Add New Section</h3>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">Module</label>
                <select
                  value={newSection.moduleId}
                  onChange={(e) => setNewSection(prev => ({ ...prev, moduleId: e.target.value }))}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
                >
                  <option value="">Select a module</option>
                  {modules.map(module => (
                    <option key={module.id} value={module.id}>{module.title}</option>
                  ))}
                </select>
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">Title</label>
                <input
                  type="text"
                  value={newSection.title}
                  onChange={(e) => setNewSection(prev => ({ ...prev, title: e.target.value }))}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
                  placeholder="Section title"
                />
              </div>
              <div className="md:col-span-2">
                <label className="block text-sm font-medium text-gray-700 mb-2">Description</label>
                <textarea
                  value={newSection.description}
                  onChange={(e) => setNewSection(prev => ({ ...prev, description: e.target.value }))}
                  rows={3}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
                  placeholder="Section description"
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">Order</label>
                <input
                  type="number"
                  value={newSection.order}
                  onChange={(e) => setNewSection(prev => ({ ...prev, order: parseInt(e.target.value) }))}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
                  min="1"
                />
              </div>
            </div>
            <div className="flex justify-end space-x-3 mt-4">
              <button
                onClick={() => setShowAddForm(null)}
                className="px-4 py-2 text-gray-600 hover:text-gray-800 transition-colors"
              >
                Cancel
              </button>
              <button
                onClick={handleAddSection}
                className="flex items-center px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors"
              >
                <Save className="h-4 w-4 mr-2" />
                Save Section
              </button>
            </div>
          </div>
        )}

      </div>
    </div>
  );
};

export default Settings;