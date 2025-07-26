// Type definitions for the Training Portal
export interface User {
  id: string;
  name: string;
  role: 'Admin' | 'QA' | 'User';
  email: string;
  avatar?: string;
}

export interface Module {
  id: string;
  title: string;
  description: string;
  icon: string;
  category: string;
  completionRate: number;
  isCompleted: boolean;
  estimatedTime: string;
  sections?: Section[];
}

export interface Section {
  id: string;
  title: string;
  description: string;
  lessons: Lesson[];
}

export interface Lesson {
  id: string;
  title: string;
  type: 'video' | 'document' | 'interactive' | 'quiz';
  duration: string;
  isCompleted: boolean;
  isLocked: boolean;
  content?: string;
  videoUrl?: string;
  documentContent?: string;
  scribeLink?: string;
  assessment?: Assessment; // Embedded assessment data
  hasAssessment: boolean;
}

export interface Assessment {
  id: string;
  title: string;
  description: string;
  moduleId: string;
  sectionId?: string;
  lessonId?: string;
  questions: Question[];
  passingScore: number;
  timeLimit?: number; // in minutes
  attempts: QuizAttempt[];
  maxAttempts: number;
  isActive: boolean;
  isRequired: boolean; // Whether completing this assessment is required for module completion
}

export interface Question {
  id: string;
  type: 'multiple-choice' | 'true-false' | 'short-answer' | 'essay';
  question: string;
  options?: string[]; // for multiple choice
  correctAnswer: string | string[];
  explanation?: string;
  points: number;
}

export interface QuizAttempt {
  id: string;
  userId: string;
  startedAt: string;
  completedAt?: string;
  answers: { [questionId: string]: string };
  score: number;
  passed: boolean;
}

export interface UploadedContent {
  id: string;
  title: string;
  type: 'pdf' | 'doc' | 'image' | 'scribe';
  module: string;
  uploadedBy: string;
  uploadedAt: string;
  tags: string[];
  description: string;
}

export interface SearchResult {
  id: string;
  title: string;
  type: string;
  module: string;
  tags: string[];
  relevance: number;
}

export interface ProgressData {
  totalModules: number;
  completedModules: number;
  overallProgress: number;
  recentActivity: string[];
}