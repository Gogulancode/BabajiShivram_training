import React, { useState } from 'react';
import { Upload, FileText, Image, Link, X, Plus, Video } from 'lucide-react';

interface Section {
  id: string;
  title: string;
  moduleId: string;
}

interface Module {
  id: string;
  title: string;
  sections: Section[];
}

const UploadContent: React.FC = () => {
  const [formData, setFormData] = useState({
    title: '',
    module: '',
    section: '',
    description: '',
    scribeLink: '',
    videoUrl: '',
    tags: [] as string[],
    accessRoles: [] as string[],
    lessonIndex: 1
  });
  
  const [screenshots, setScreenshots] = useState<File[]>([]);
  const [document, setDocument] = useState<File | null>(null);
  const [newTag, setNewTag] = useState('');

  // Mock data - in real app this would come from API
  const modules: Module[] = [
    {
      id: '1',
      title: 'Import Management',
      sections: [
        { id: '1-1', title: 'Import Fundamentals', moduleId: '1' },
        { id: '1-2', title: 'Documentation & Compliance', moduleId: '1' },
        { id: '1-3', title: 'Customs Procedures', moduleId: '1' }
      ]
    },
    {
      id: '2',
      title: 'Export Operations',
      sections: [
        { id: '2-1', title: 'Export Basics', moduleId: '2' },
        { id: '2-2', title: 'International Regulations', moduleId: '2' }
      ]
    },
    {
      id: '3',
      title: 'Freight Management',
      sections: [
        { id: '3-1', title: 'Freight Booking', moduleId: '3' },
        { id: '3-2', title: 'Cost Optimization', moduleId: '3' }
      ]
    },
    {
      id: '4',
      title: 'Inventory Control',
      sections: [
        { id: '4-1', title: 'Stock Management', moduleId: '4' },
        { id: '4-2', title: 'Warehouse Operations', moduleId: '4' }
      ]
    },
    {
      id: '5',
      title: 'Financial Reports',
      sections: [
        { id: '5-1', title: 'Report Generation', moduleId: '5' },
        { id: '5-2', title: 'Data Analysis', moduleId: '5' }
      ]
    },
    {
      id: '6',
      title: 'Customer Management',
      sections: [
        { id: '6-1', title: 'Customer Data', moduleId: '6' },
        { id: '6-2', title: 'Relationship Management', moduleId: '6' }
      ]
    }
  ];

  const roles = ['Admin', 'QA', 'User', 'Manager', 'Supervisor'];

  const selectedModule = modules.find(m => m.id === formData.module);
  const availableSections = selectedModule ? selectedModule.sections : [];

  const handleInputChange = (e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement | HTMLTextAreaElement>) => {
    const { name, value } = e.target;
    setFormData(prev => ({ 
      ...prev, 
      [name]: value,
      // Reset section when module changes
      ...(name === 'module' && { section: '' })
    }));
  };

  const handleRoleToggle = (role: string) => {
    setFormData(prev => ({
      ...prev,
      accessRoles: prev.accessRoles.includes(role)
        ? prev.accessRoles.filter(r => r !== role)
        : [...prev.accessRoles, role]
    }));
  };

  const handleScreenshotUpload = (e: React.ChangeEvent<HTMLInputElement>) => {
    const files = Array.from(e.target.files || []);
    setScreenshots(prev => [...prev, ...files]);
  };

  const removeScreenshot = (index: number) => {
    setScreenshots(prev => prev.filter((_, i) => i !== index));
  };

  const handleDocumentUpload = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0] || null;
    setDocument(file);
  };

  const addTag = () => {
    if (newTag.trim() && !formData.tags.includes(newTag.trim())) {
      setFormData(prev => ({
        ...prev,
        tags: [...prev.tags, newTag.trim()]
      }));
      setNewTag('');
    }
  };

  const removeTag = (tag: string) => {
    setFormData(prev => ({
      ...prev,
      tags: prev.tags.filter(t => t !== tag)
    }));
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    // Handle form submission here
    console.log('Form submitted:', { formData, screenshots, document });
    alert('Content uploaded successfully!');
  };

  return (
    <div className="max-w-4xl mx-auto">
      <div className="mb-8">
        <h1 className="text-2xl font-bold text-gray-900">Upload Training Content</h1>
        <p className="text-gray-600 mt-2">Add new training materials for ERP modules</p>
      </div>

      <form onSubmit={handleSubmit} className="space-y-8">
        {/* Basic Information */}
        <div className="bg-white rounded-lg p-6 shadow-sm border border-gray-200">
          <h2 className="text-lg font-semibold text-gray-900 mb-4">Basic Information</h2>
          
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div>
              <label htmlFor="title" className="block text-sm font-medium text-gray-700 mb-2">
                Title *
              </label>
              <input
                type="text"
                id="title"
                name="title"
                required
                value={formData.title}
                onChange={handleInputChange}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
                placeholder="Enter content title"
              />
            </div>

            <div>
              <label htmlFor="module" className="block text-sm font-medium text-gray-700 mb-2">
                ERP Module *
              </label>
              <select
                id="module"
                name="module"
                required
                value={formData.module}
                onChange={handleInputChange}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
              >
                <option value="">Select a module</option>
                {modules.map(module => (
                  <option key={module.id} value={module.id}>{module.title}</option>
                ))}
              </select>
            </div>

            <div>
              <label htmlFor="section" className="block text-sm font-medium text-gray-700 mb-2">
                Section *
              </label>
              <select
                id="section"
                name="section"
                required
                value={formData.section}
                onChange={handleInputChange}
                disabled={!formData.module}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 disabled:bg-gray-100 disabled:cursor-not-allowed"
              >
                <option value="">Select a section</option>
                {availableSections.map(section => (
                  <option key={section.id} value={section.id}>{section.title}</option>
                ))}
              </select>
              {!formData.module && (
                <p className="text-xs text-gray-500 mt-1">Please select a module first</p>
              )}
            </div>
          </div>
          

          <div className="grid grid-cols-1 md:grid-cols-2 gap-6 mt-6">
            <div>
              <label htmlFor="lessonIndex" className="block text-sm font-medium text-gray-700 mb-2">
                Lesson Index
              </label>
              <input
                type="number"
                id="lessonIndex"
                name="lessonIndex"
                min="1"
                value={formData.lessonIndex}
                onChange={handleInputChange}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
                placeholder="Enter lesson order (1, 2, 3...)"
              />
              <p className="text-xs text-gray-500 mt-1">Order in which this lesson appears in the section</p>
            </div>
            
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">Content Type</label>
              <select
                value={formData.contentType || 'document'}
                onChange={(e) => {
                  setFormData(prev => ({ ...prev, contentType: e.target.value }));
                }}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
              >
                <option value="document">Document/Text</option>
                <option value="video">Video</option>
                <option value="interactive">Interactive Guide (Scribe)</option>
              </select>
              <p className="text-xs text-gray-500 mt-1">
                Interactive Guide: Step-by-step tutorials created with Scribe that capture screenshots and provide guided walkthroughs
              </p>
            </div>
          </div>


          <div className="mt-6">
            <label htmlFor="description" className="block text-sm font-medium text-gray-700 mb-2">
              Description *
            </label>
            <textarea
              id="description"
              name="description"
              required
              rows={4}
              value={formData.description}
              onChange={handleInputChange}
              className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
              placeholder="Describe the training content and its purpose"
            />
          </div>
        </div>

        {/* File Uploads */}
        <div className="bg-white rounded-lg p-6 shadow-sm border border-gray-200">
          <h2 className="text-lg font-semibold text-gray-900 mb-4">Upload Files</h2>
          
          {/* Dynamic Upload Section Based on Content Type */}
          {formData.contentType === 'document' && (
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Document (PDF or Word)
              </label>
              <div className="border-2 border-dashed border-gray-300 rounded-lg p-6 text-center hover:border-gray-400 transition-colors">
                <input
                  type="file"
                  accept=".pdf,.doc,.docx"
                  onChange={handleDocumentUpload}
                  className="hidden"
                  id="document"
                />
                <label htmlFor="document" className="cursor-pointer">
                  <FileText className="h-12 w-12 text-gray-400 mx-auto mb-4" />
                  <p className="text-sm text-gray-600">Click to upload document</p>
                  <p className="text-xs text-gray-500 mt-1">PDF, DOC, DOCX up to 50MB</p>
                </label>
              </div>
              
              {document && (
                <div className="mt-4 flex items-center justify-between p-3 bg-gray-50 rounded-lg">
                  <div className="flex items-center">
                    <FileText className="h-5 w-5 text-gray-400 mr-3" />
                    <span className="text-sm text-gray-700">{document.name}</span>
                  </div>
                  <button
                    type="button"
                    onClick={() => setDocument(null)}
                    className="text-red-500 hover:text-red-700"
                  >
                    <X className="h-4 w-4" />
                  </button>
                </div>
              )}
            </div>
          )}

          {formData.contentType === 'video' && (
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Video Files or Screenshots
              </label>
              <div className="border-2 border-dashed border-gray-300 rounded-lg p-6 text-center hover:border-gray-400 transition-colors">
                <input
                  type="file"
                  multiple
                  accept="video/*,image/*"
                  onChange={handleScreenshotUpload}
                  className="hidden"
                  id="video-files"
                />
                <label htmlFor="video-files" className="cursor-pointer">
                  <Video className="h-12 w-12 text-gray-400 mx-auto mb-4" />
                  <p className="text-sm text-gray-600">Click to upload video files or screenshots</p>
                  <p className="text-xs text-gray-500 mt-1">MP4, MOV, AVI, PNG, JPG up to 100MB each</p>
                </label>
              </div>
              
              {screenshots.length > 0 && (
                <div className="mt-4 grid grid-cols-2 md:grid-cols-4 gap-4">
                  {screenshots.map((file, index) => (
                    <div key={index} className="relative">
                      <div className="aspect-square bg-gray-100 rounded-lg flex items-center justify-center">
                        {file.type.startsWith('video/') ? (
                          <Video className="h-8 w-8 text-gray-400" />
                        ) : (
                          <Image className="h-8 w-8 text-gray-400" />
                        )}
                      </div>
                      <p className="text-xs text-gray-600 mt-1 truncate">{file.name}</p>
                      <button
                        type="button"
                        onClick={() => removeScreenshot(index)}
                        className="absolute -top-2 -right-2 bg-red-500 text-white rounded-full p-1 hover:bg-red-600"
                      >
                        <X className="h-3 w-3" />
                      </button>
                    </div>
                  ))}
                </div>
              )}
            </div>
          )}

          {formData.contentType === 'interactive' && (
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Screenshots for Interactive Guide
              </label>
              <div className="border-2 border-dashed border-gray-300 rounded-lg p-6 text-center hover:border-gray-400 transition-colors">
                <input
                  type="file"
                  multiple
                  accept="image/*"
                  onChange={handleScreenshotUpload}
                  className="hidden"
                  id="interactive-screenshots"
                />
                <label htmlFor="interactive-screenshots" className="cursor-pointer">
                  <Image className="h-12 w-12 text-gray-400 mx-auto mb-4" />
                  <p className="text-sm text-gray-600">Click to upload screenshots for the interactive guide</p>
                  <p className="text-xs text-gray-500 mt-1">PNG, JPG, GIF up to 10MB each</p>
                </label>
              </div>
              
              {screenshots.length > 0 && (
                <div className="mt-4 grid grid-cols-2 md:grid-cols-4 gap-4">
                  {screenshots.map((file, index) => (
                    <div key={index} className="relative">
                      <div className="aspect-square bg-gray-100 rounded-lg flex items-center justify-center">
                        <Image className="h-8 w-8 text-gray-400" />
                      </div>
                      <p className="text-xs text-gray-600 mt-1 truncate">{file.name}</p>
                      <button
                        type="button"
                        onClick={() => removeScreenshot(index)}
                        className="absolute -top-2 -right-2 bg-red-500 text-white rounded-full p-1 hover:bg-red-600"
                      >
                        <X className="h-3 w-3" />
                      </button>
                    </div>
                  ))}
                </div>
              )}
            </div>
          )}
        </div>

        {/* Additional Information */}
        <div className="bg-white rounded-lg p-6 shadow-sm border border-gray-200">
          <h2 className="text-lg font-semibold text-gray-900 mb-4">Additional Information</h2>
          
          <div className="space-y-6">
            {/* Scribe Link */}
            {(formData.contentType === 'interactive' || !formData.contentType) && (
            <div>
              <label htmlFor="scribeLink" className="block text-sm font-medium text-gray-700 mb-2">
                Scribe Link (for Interactive Guides)
              </label>
              <div className="relative">
                <Link className="absolute left-3 top-1/2 transform -translate-y-1/2 h-5 w-5 text-gray-400" />
                <input
                  type="url"
                  id="scribeLink"
                  name="scribeLink"
                  value={formData.scribeLink}
                  onChange={handleInputChange}
                  className="w-full pl-10 pr-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
                  placeholder="https://scribe.com/..."
                />
              </div>
              <p className="text-xs text-gray-500 mt-1">Link to your Scribe interactive guide</p>
            </div>
            )}

            {/* Video URL */}
            {(formData.contentType === 'video' || !formData.contentType) && (
            <div>
              <label htmlFor="videoUrl" className="block text-sm font-medium text-gray-700 mb-2">
                Video URL (for Video Content)
              </label>
              <div className="relative">
                <Video className="absolute left-3 top-1/2 transform -translate-y-1/2 h-5 w-5 text-gray-400" />
                <input
                  type="url"
                  id="videoUrl"
                  name="videoUrl"
                  value={formData.videoUrl}
                  onChange={handleInputChange}
                  className="w-full pl-10 pr-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
                  placeholder="https://youtube.com/embed/... or https://vimeo.com/..."
                />
              </div>
              <p className="text-xs text-gray-500 mt-1">YouTube embed URL, Vimeo URL, or direct video link</p>
            </div>
            )}

            {/* Tags */}
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">Tags</label>
              <div className="flex flex-wrap gap-2 mb-3">
                {formData.tags.map(tag => (
                  <span
                    key={tag}
                    className="inline-flex items-center px-3 py-1 bg-blue-100 text-blue-800 text-sm rounded-full"
                  >
                    {tag}
                    <button
                      type="button"
                      onClick={() => removeTag(tag)}
                      className="ml-2 text-blue-600 hover:text-blue-800"
                    >
                      <X className="h-3 w-3" />
                    </button>
                  </span>
                ))}
              </div>
              <div className="flex gap-2">
                <input
                  type="text"
                  value={newTag}
                  onChange={(e) => setNewTag(e.target.value)}
                  onKeyPress={(e) => e.key === 'Enter' && (e.preventDefault(), addTag())}
                  className="flex-1 px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
                  placeholder="Add a tag"
                />
                <button
                  type="button"
                  onClick={addTag}
                  className="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-500"
                >
                  <Plus className="h-4 w-4" />
                </button>
              </div>
            </div>

            {/* Access Roles */}
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">Access Roles</label>
              <div className="grid grid-cols-2 md:grid-cols-3 gap-3">
                {roles.map(role => (
                  <label key={role} className="flex items-center">
                    <input
                      type="checkbox"
                      checked={formData.accessRoles.includes(role)}
                      onChange={() => handleRoleToggle(role)}
                      className="rounded border-gray-300 text-blue-600 focus:ring-blue-500"
                    />
                    <span className="ml-2 text-sm text-gray-700">{role}</span>
                  </label>
                ))}
              </div>
            </div>
          </div>
        </div>

        {/* Submit Button */}
        <div className="flex justify-end">
          <button
            type="submit"
            className="px-6 py-3 bg-blue-600 text-white font-medium rounded-lg hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-500 transition-colors"
          >
            <Upload className="h-4 w-4 mr-2 inline" />
            Upload Content
          </button>
        </div>
      </form>
    </div>
  );
};

export default UploadContent;