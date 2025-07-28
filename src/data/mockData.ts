export const modules: Module[] = [
  {
    id: '1',
    title: 'Import Management',
    description: 'Learn the fundamentals of import management, documentation, and compliance procedures.',
    icon: 'Package',
    color: 'blue',
    estimatedTime: '2-3 hours',
    difficulty: 'Beginner',
    prerequisites: [],
    learningObjectives: [
      'Understand import documentation requirements',
      'Learn compliance procedures',
      'Master import cost calculations'
    ],
    isLocked: false,
    progress: 33,
    sections: [
      {
        id: '1-1',
        title: 'Import Fundamentals',
        description: 'Basic concepts and terminology',
        lessons: [
          {
            id: '1-1-1',
            title: 'Introduction to Import Management',
            type: 'video',
            isCompleted: true,
            isLocked: false,
            content: 'Introduction to import management processes...',
            duration: '15 min',
            hasAssessment: false
          },
          {
            id: '1-1-2',
            title: 'Import Terminology',
            type: 'document',
            isCompleted: true,
            isLocked: false,
            documentContent: '<h3>Import Terminology</h3><p>Key terms and definitions...</p>',
            duration: '10 min',
            hasAssessment: false
          },
          {
            id: '1-1-3',
            title: 'Import Fundamentals Quiz',
            type: 'quiz',
            isCompleted: false,
            isLocked: false,
            content: 'Basic import procedures quiz',
            duration: '20 min',
            hasAssessment: true,
            assessment: {
              id: 'quiz-1-1-3',
              title: 'Import Fundamentals Quiz',
              description: 'Test your understanding of basic import concepts',
              moduleId: '1',
              sectionId: '1-1',
              lessonId: '1-1-3',
              questions: [
                {
                  id: 'q1',
                  type: 'multiple-choice',
                  question: 'What is the primary purpose of a Bill of Lading?',
                  options: ['Calculate duties', 'Receipt and contract', 'Quality check', 'Set price'],
                  correctAnswer: 'Receipt and contract',
                  points: 10
                }
              ],
              passingScore: 70,
              timeLimit: 15,
              attempts: [],
              maxAttempts: 3,
              isActive: true,
              isRequired: true
            }
          }
        ]
      },
      {
        id: '1-2',
        title: 'Documentation & Compliance',
        description: 'Required documents and regulatory compliance',
        lessons: [
          {
            id: '1-2-1',
            title: 'Import Documentation',
            type: 'document',
            isCompleted: false,
            isLocked: false,
            documentContent: '<h3>Required Documents</h3><p>Essential import documents...</p>',
            duration: '25 min',
            hasAssessment: false
          },
          {
            id: '1-2-2',
            title: 'Compliance Procedures',
            type: 'video',
            isCompleted: false,
            isLocked: true,
            content: 'Compliance procedures and regulations',
            duration: '30 min',
            hasAssessment: false
          }
        ]
      }
    ]
  },
  {
    id: '2',
    title: 'Export Management',
    description: 'Master export procedures, documentation, and international shipping requirements.',
    icon: 'Truck',
    color: 'green',
    estimatedTime: '2-3 hours',
    difficulty: 'Intermediate',
    prerequisites: ['1'],
    learningObjectives: [
      'Understand export documentation',
      'Learn shipping procedures',
      'Master export regulations'
    ],
    isLocked: true,
    progress: 0,
    sections: [
      {
        id: '2-1',
        title: 'Export Basics',
        description: 'Fundamental export concepts',
        lessons: [
          {
            id: '2-1-1',
            title: 'Export Fundamentals',
            type: 'video',
            isCompleted: false,
            isLocked: false,
            content: 'Export basics content...',
            duration: '20 min',
            hasAssessment: false
          }
        ]
      }
    ]
  },
  {
    id: '3',
    title: 'Freight Management',
    description: 'Learn freight booking, tracking, and cost optimization strategies.',
    icon: 'Ship',
    color: 'purple',
    estimatedTime: '1-2 hours',
    difficulty: 'Intermediate',
    prerequisites: ['1', '2'],
    learningObjectives: [
      'Master freight booking procedures',
      'Understand shipping modes',
      'Learn cost optimization'
    ],
    isLocked: true,
    progress: 0,
    sections: [
      {
        id: '3-1',
        title: 'Freight Booking',
        description: 'Booking and managing freight shipments',
        lessons: [
          {
            id: '3-1-1',
            title: 'Freight Booking Procedures',
            type: 'video',
            isCompleted: false,
            isLocked: false,
            content: 'Freight booking procedures...',
            duration: '25 min',
            hasAssessment: false
          }
        ]
      }
    ]
  },
  {
    id: '4',
    title: 'Inventory Management',
    description: 'Optimize inventory levels, tracking, and warehouse management.',
    icon: 'Archive',
    color: 'orange',
    estimatedTime: '1-2 hours',
    difficulty: 'Beginner',
    prerequisites: [],
    learningObjectives: [
      'Learn inventory optimization',
      'Master stock tracking',
      'Understand warehouse management'
    ],
    isLocked: true,
    progress: 0,
    sections: [
      {
        id: '4-1',
        title: 'Stock Management',
        description: 'Managing inventory and stock levels',
        lessons: [
          {
            id: '4-1-1',
            title: 'Inventory Basics',
            type: 'video',
            isCompleted: false,
            isLocked: false,
            content: 'Stock management principles...',
            duration: '20 min',
            hasAssessment: false
          }
        ]
      }
    ]
  },
  {
    id: '5',
    title: 'Reporting & Analytics',
    description: 'Generate insights through comprehensive reporting and data analysis.',
    icon: 'BarChart3',
    color: 'red',
    estimatedTime: '1-2 hours',
    difficulty: 'Advanced',
    prerequisites: ['1', '2', '3', '4'],
    learningObjectives: [
      'Master report generation',
      'Learn data analysis',
      'Understand KPI tracking'
    ],
    isLocked: true,
    progress: 0,
    sections: [
      {
        id: '5-1',
        title: 'Report Generation',
        description: 'Creating and customizing reports',
        lessons: [
          {
            id: '5-1-1',
            title: 'Basic Reporting',
            type: 'video',
            isCompleted: false,
            isLocked: false,
            content: 'Report generation procedures...',
            duration: '30 min',
            hasAssessment: false
          }
        ]
      }
    ]
  },
  {
    id: '6',
    title: 'Customer Management',
    description: 'Build and maintain strong customer relationships and communication.',
    icon: 'Users',
    color: 'indigo',
    estimatedTime: '1 hour',
    difficulty: 'Beginner',
    prerequisites: [],
    learningObjectives: [
      'Learn customer communication',
      'Master relationship building',
      'Understand service excellence'
    ],
    isLocked: true,
    progress: 0,
    sections: [
      {
        id: '6-1',
        title: 'Customer Relations',
        description: 'Building strong customer relationships',
        lessons: [
          {
            id: '6-1-1',
            title: 'Customer Communication',
            type: 'video',
            isCompleted: false,
            isLocked: false,
            content: 'Customer data management...',
            duration: '25 min',
            hasAssessment: false
          }
        ]
      }
    ]
  }
];

// Current user data
export const currentUser: User = {
  id: 'user1',
  name: 'John Doe',
  email: 'john.doe@company.com',
  role: 'Admin',
  avatar: 'https://images.pexels.com/photos/220453/pexels-photo-220453.jpeg?auto=compress&cs=tinysrgb&w=150',
  department: 'Training & Development',
  joinDate: '2023-01-15',
  completedModules: 2,
  totalModules: 6,
  overallProgress: 33
};

// Recent uploads data
export const recentUploads = [
  {
    id: '1',
    title: 'Import Documentation Guide',
    description: 'Comprehensive guide for import documentation requirements',
    type: 'pdf' as const,
    module: 'Import Management',
    uploadedBy: 'Sarah Johnson',
    uploadedAt: '2 hours ago'
  },
  {
    id: '2',
    title: 'Export Procedures Video',
    description: 'Step-by-step video tutorial for export procedures',
    type: 'scribe' as const,
    module: 'Export Management',
    uploadedBy: 'Mike Chen',
    uploadedAt: '1 day ago'
  },
  {
    id: '3',
    title: 'Freight Booking Template',
    description: 'Template document for freight booking procedures',
    type: 'doc' as const,
    module: 'Freight Management',
    uploadedBy: 'Lisa Rodriguez',
    uploadedAt: '3 days ago'
  },
  {
    id: '4',
    title: 'Compliance Checklist',
    description: 'Visual checklist for compliance requirements',
    type: 'image' as const,
    module: 'Import Management',
    uploadedBy: 'David Kim',
    uploadedAt: '1 week ago'
  }
];

// Mock assessments data
export const assessments: Assessment[] = [
  {
    id: '1',
    title: 'Import Management Fundamentals Quiz',
    description: 'Test your understanding of basic import concepts and procedures',
    moduleId: '1',
    sectionId: '1-1',
    questions: [],
    passingScore: 70,
    timeLimit: 30,
    attempts: [],
    maxAttempts: 3,
    isActive: true,
    isRequired: true,
    lessonId: '1-1-3'
  },
  {
    id: '2',
    title: 'Documentation & Compliance Assessment',
    description: 'Evaluate your knowledge of import documentation and compliance requirements',
    moduleId: '1',
    sectionId: '1-2',
    questions: [],
    passingScore: 80,
    timeLimit: 45,
    attempts: [],
    maxAttempts: 3,
    isActive: true,
    isRequired: false
  }
];