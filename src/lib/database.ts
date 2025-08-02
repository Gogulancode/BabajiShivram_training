import Database from 'better-sqlite3';
import path from 'path';

// Initialize SQLite database
const dbPath = path.join(process.cwd(), 'erp_training.db');
export const db = new Database(dbPath);

// Enable foreign keys
db.pragma('foreign_keys = ON');

// Database initialization
export function initializeDatabase() {
  // Create tables if they don't exist
  createTables();
  insertSampleData();
}

function createTables() {
  // Users table
  db.exec(`
    CREATE TABLE IF NOT EXISTS users (
      id TEXT PRIMARY KEY,
      email TEXT UNIQUE NOT NULL,
      password_hash TEXT NOT NULL,
      first_name TEXT NOT NULL,
      last_name TEXT NOT NULL,
      department TEXT,
      role TEXT DEFAULT 'User' CHECK (role IN ('Admin', 'QA', 'User', 'Manager', 'Supervisor')),
      avatar TEXT,
      is_active BOOLEAN DEFAULT 1,
      join_date DATETIME DEFAULT CURRENT_TIMESTAMP,
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
      updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
    )
  `);

  // Modules table
  db.exec(`
    CREATE TABLE IF NOT EXISTS modules (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT NOT NULL,
      description TEXT NOT NULL,
      icon TEXT NOT NULL,
      color TEXT DEFAULT 'blue',
      estimated_time TEXT NOT NULL,
      difficulty TEXT NOT NULL CHECK (difficulty IN ('Beginner', 'Intermediate', 'Advanced')),
      prerequisites TEXT DEFAULT '[]', -- JSON array
      learning_objectives TEXT DEFAULT '[]', -- JSON array
      is_active BOOLEAN DEFAULT 1,
      order_index INTEGER NOT NULL,
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
      updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
    )
  `);

  // Sections table
  db.exec(`
    CREATE TABLE IF NOT EXISTS sections (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT NOT NULL,
      description TEXT NOT NULL,
      module_id INTEGER NOT NULL,
      order_index INTEGER NOT NULL,
      is_active BOOLEAN DEFAULT 1,
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
      updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (module_id) REFERENCES modules(id) ON DELETE CASCADE
    )
  `);

  // Lessons table
  db.exec(`
    CREATE TABLE IF NOT EXISTS lessons (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT NOT NULL,
      description TEXT NOT NULL,
      type TEXT NOT NULL CHECK (type IN ('video', 'document', 'interactive', 'quiz')),
      duration TEXT NOT NULL,
      section_id INTEGER NOT NULL,
      order_index INTEGER NOT NULL,
      is_active BOOLEAN DEFAULT 1,
      video_url TEXT,
      document_content TEXT,
      scribe_link TEXT,
      interactive_steps TEXT DEFAULT '[]', -- JSON array
      has_assessment BOOLEAN DEFAULT 0,
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
      updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (section_id) REFERENCES sections(id) ON DELETE CASCADE
    )
  `);

  // Assessments table
  db.exec(`
    CREATE TABLE IF NOT EXISTS assessments (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT NOT NULL,
      description TEXT NOT NULL,
      module_id INTEGER NOT NULL,
      section_id INTEGER,
      lesson_id INTEGER,
      passing_score INTEGER NOT NULL CHECK (passing_score >= 0 AND passing_score <= 100),
      time_limit INTEGER NOT NULL, -- in minutes
      max_attempts INTEGER NOT NULL DEFAULT 3,
      is_active BOOLEAN DEFAULT 1,
      is_required BOOLEAN DEFAULT 0,
      trigger_type TEXT NOT NULL CHECK (trigger_type IN ('section_completion', 'module_completion', 'lesson_completion')),
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
      updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (module_id) REFERENCES modules(id) ON DELETE CASCADE,
      FOREIGN KEY (section_id) REFERENCES sections(id) ON DELETE SET NULL,
      FOREIGN KEY (lesson_id) REFERENCES lessons(id) ON DELETE SET NULL
    )
  `);

  // Questions table
  db.exec(`
    CREATE TABLE IF NOT EXISTS questions (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      assessment_id INTEGER NOT NULL,
      type TEXT NOT NULL CHECK (type IN ('multiple-choice', 'single-choice', 'true-false', 'short-answer', 'essay')),
      question_text TEXT NOT NULL,
      options TEXT DEFAULT '[]', -- JSON array
      correct_answers TEXT DEFAULT '[]', -- JSON array
      explanation TEXT,
      points INTEGER NOT NULL DEFAULT 1,
      order_index INTEGER NOT NULL,
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
      updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (assessment_id) REFERENCES assessments(id) ON DELETE CASCADE
    )
  `);

  // Assessment attempts table
  db.exec(`
    CREATE TABLE IF NOT EXISTS assessment_attempts (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id TEXT NOT NULL,
      assessment_id INTEGER NOT NULL,
      started_at DATETIME DEFAULT CURRENT_TIMESTAMP,
      completed_at DATETIME,
      score INTEGER DEFAULT 0,
      total_points INTEGER NOT NULL,
      passed BOOLEAN DEFAULT 0,
      attempt_number INTEGER NOT NULL,
      time_spent INTEGER DEFAULT 0, -- in seconds
      status TEXT DEFAULT 'in_progress' CHECK (status IN ('in_progress', 'completed', 'abandoned', 'time_expired')),
      FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
      FOREIGN KEY (assessment_id) REFERENCES assessments(id) ON DELETE CASCADE
    )
  `);

  // User answers table
  db.exec(`
    CREATE TABLE IF NOT EXISTS user_answers (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      attempt_id INTEGER NOT NULL,
      question_id INTEGER NOT NULL,
      selected_answers TEXT DEFAULT '[]', -- JSON array
      text_answer TEXT,
      is_correct BOOLEAN DEFAULT 0,
      points_earned INTEGER DEFAULT 0,
      answered_at DATETIME DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (attempt_id) REFERENCES assessment_attempts(id) ON DELETE CASCADE,
      FOREIGN KEY (question_id) REFERENCES questions(id) ON DELETE CASCADE
    )
  `);

  // User module progress table
  db.exec(`
    CREATE TABLE IF NOT EXISTS user_module_progress (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id TEXT NOT NULL,
      module_id INTEGER NOT NULL,
      completion_percentage INTEGER DEFAULT 0 CHECK (completion_percentage >= 0 AND completion_percentage <= 100),
      is_completed BOOLEAN DEFAULT 0,
      completed_at DATETIME,
      started_at DATETIME DEFAULT CURRENT_TIMESTAMP,
      updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
      FOREIGN KEY (module_id) REFERENCES modules(id) ON DELETE CASCADE,
      UNIQUE(user_id, module_id)
    )
  `);

  // User lesson progress table
  db.exec(`
    CREATE TABLE IF NOT EXISTS user_lesson_progress (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id TEXT NOT NULL,
      lesson_id INTEGER NOT NULL,
      is_completed BOOLEAN DEFAULT 0,
      completed_at DATETIME,
      started_at DATETIME DEFAULT CURRENT_TIMESTAMP,
      time_spent INTEGER DEFAULT 0, -- in seconds
      FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
      FOREIGN KEY (lesson_id) REFERENCES lessons(id) ON DELETE CASCADE,
      UNIQUE(user_id, lesson_id)
    )
  `);

  // Uploaded contents table
  db.exec(`
    CREATE TABLE IF NOT EXISTS uploaded_contents (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT NOT NULL,
      description TEXT NOT NULL,
      type TEXT NOT NULL CHECK (type IN ('document', 'video', 'image', 'interactive')),
      file_path TEXT,
      file_name TEXT,
      file_size INTEGER DEFAULT 0,
      content_type TEXT,
      module_id INTEGER NOT NULL,
      section_id INTEGER,
      lesson_id INTEGER,
      uploaded_by TEXT NOT NULL,
      tags TEXT DEFAULT '[]', -- JSON array
      access_roles TEXT DEFAULT '[]', -- JSON array
      scribe_link TEXT,
      video_url TEXT,
      is_active BOOLEAN DEFAULT 1,
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
      updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (module_id) REFERENCES modules(id) ON DELETE CASCADE,
      FOREIGN KEY (section_id) REFERENCES sections(id) ON DELETE SET NULL,
      FOREIGN KEY (lesson_id) REFERENCES lessons(id) ON DELETE SET NULL,
      FOREIGN KEY (uploaded_by) REFERENCES users(id) ON DELETE CASCADE
    )
  `);

  // Create indexes for better performance
  db.exec(`
    CREATE INDEX IF NOT EXISTS idx_modules_order ON modules(order_index);
    CREATE INDEX IF NOT EXISTS idx_sections_module ON sections(module_id, order_index);
    CREATE INDEX IF NOT EXISTS idx_lessons_section ON lessons(section_id, order_index);
    CREATE INDEX IF NOT EXISTS idx_questions_assessment ON questions(assessment_id, order_index);
    CREATE INDEX IF NOT EXISTS idx_attempts_user ON assessment_attempts(user_id, assessment_id);
    CREATE INDEX IF NOT EXISTS idx_answers_attempt ON user_answers(attempt_id, question_id);
    CREATE INDEX IF NOT EXISTS idx_module_progress_user ON user_module_progress(user_id, module_id);
    CREATE INDEX IF NOT EXISTS idx_lesson_progress_user ON user_lesson_progress(user_id, lesson_id);
    CREATE INDEX IF NOT EXISTS idx_contents_module ON uploaded_contents(module_id, section_id);
  `);
}

function insertSampleData() {
  // Check if data already exists
  const userCount = db.prepare('SELECT COUNT(*) as count FROM users').get() as { count: number };
  if (userCount.count > 0) return; // Data already exists

  // Insert sample users
  const insertUser = db.prepare(`
    INSERT INTO users (id, email, password_hash, first_name, last_name, department, role)
    VALUES (?, ?, ?, ?, ?, ?, ?)
  `);

  // Note: In production, use proper password hashing (bcrypt)
  // Password: Admin@123
  insertUser.run('admin-1', 'admin@erptraining.com', '$2b$12$9ATcQf1l7ABNXgTYq3wU5uMIpgz9R8mTheDkT3TGcugZHVMR5z3yq', 'System', 'Administrator', 'IT', 'Admin');
  insertUser.run('qa-1', 'qa@erptraining.com', 'hashed_password_qa', 'Quality', 'Assurance', 'Training', 'QA');
  insertUser.run('user-1', 'john.doe@erptraining.com', 'hashed_password_user', 'John', 'Doe', 'Operations', 'User');

  // Insert sample modules
  const insertModule = db.prepare(`
    INSERT INTO modules (title, description, icon, estimated_time, difficulty, learning_objectives, order_index)
    VALUES (?, ?, ?, ?, ?, ?, ?)
  `);

  const modules = [
    {
      title: 'CB – Imports',
      description: 'Comprehensive training on customs bonded imports and related procedures.',
      icon: 'Download',
      estimatedTime: '2-3 hours',
      difficulty: 'Intermediate',
      objectives: JSON.stringify(['Master import procedures', 'Understand customs bonded operations', 'Learn compliance requirements']),
      order: 1
    },
    {
      title: 'Freight Forwarding',
      description: 'Learn freight forwarding operations, documentation, and logistics management.',
      icon: 'Truck',
      estimatedTime: '2-3 hours',
      difficulty: 'Intermediate',
      objectives: JSON.stringify(['Master freight forwarding processes', 'Understand logistics coordination', 'Learn documentation requirements']),
      order: 2
    },
    {
      title: 'NBCPL',
      description: 'Training on NBCPL (New Bombay Container Port Limited) operations and procedures.',
      icon: 'Container',
      estimatedTime: '1-2 hours',
      difficulty: 'Beginner',
      objectives: JSON.stringify(['Learn NBCPL operations', 'Understand port procedures', 'Master container handling']),
      order: 3
    },
    {
      title: 'Company Services',
      description: 'Overview of company services, policies, and internal procedures.',
      icon: 'Building',
      estimatedTime: '1-2 hours',
      difficulty: 'Beginner',
      objectives: JSON.stringify(['Understand company services', 'Learn internal policies', 'Master service procedures']),
      order: 4
    },
    {
      title: 'CB – Exports',
      description: 'Comprehensive training on customs bonded exports and related procedures.',
      icon: 'Upload',
      estimatedTime: '2-3 hours',
      difficulty: 'Intermediate',
      objectives: JSON.stringify(['Master export procedures', 'Understand customs bonded operations', 'Learn export compliance']),
      order: 5
    },
    {
      title: 'Contracts',
      description: 'Learn contract management, negotiation, and legal compliance.',
      icon: 'FileText',
      estimatedTime: '2-3 hours',
      difficulty: 'Advanced',
      objectives: JSON.stringify(['Master contract management', 'Understand legal requirements', 'Learn negotiation strategies']),
      order: 6
    },
    {
      title: 'SEZ',
      description: 'Special Economic Zone operations, benefits, and compliance requirements.',
      icon: 'Globe',
      estimatedTime: '1-2 hours',
      difficulty: 'Intermediate',
      objectives: JSON.stringify(['Understand SEZ operations', 'Learn compliance requirements', 'Master zone benefits']),
      order: 8
    },
    {
      title: 'Ops Accounting',
      description: 'Operations accounting procedures, financial management, and reporting.',
      icon: 'Calculator',
      estimatedTime: '2-3 hours',
      difficulty: 'Advanced',
      objectives: JSON.stringify(['Master accounting procedures', 'Learn financial management', 'Understand reporting requirements']),
      order: 9
    },
    {
      title: 'Container Movement',
      description: 'Container logistics, movement tracking, and operational efficiency.',
      icon: 'Move',
      estimatedTime: '1-2 hours',
      difficulty: 'Intermediate',
      objectives: JSON.stringify(['Learn container logistics', 'Master movement tracking', 'Understand operational efficiency']),
      order: 10
    },
    {
      title: 'CRM',
      description: 'Customer Relationship Management systems, processes, and best practices.',
      icon: 'Users',
      estimatedTime: '1-2 hours',
      difficulty: 'Beginner',
      objectives: JSON.stringify(['Master CRM systems', 'Learn customer management', 'Understand relationship building']),
      order: 11
    },
    {
      title: 'Babaji Transport',
      description: 'Transport operations, fleet management, and logistics coordination.',
      icon: 'Truck',
      estimatedTime: '1-2 hours',
      difficulty: 'Intermediate',
      objectives: JSON.stringify(['Learn transport operations', 'Master fleet management', 'Understand logistics coordination']),
      order: 12
    },
    {
      title: 'Additional Job',
      description: 'Additional job responsibilities, cross-functional training, and skill development.',
      icon: 'Plus',
      estimatedTime: '1-2 hours',
      difficulty: 'Beginner',
      objectives: JSON.stringify(['Learn additional responsibilities', 'Understand cross-functional roles', 'Develop new skills']),
      order: 13
    },
    {
      title: 'MIS',
      description: 'Management Information Systems, data analysis, and reporting tools.',
      icon: 'BarChart3',
      estimatedTime: '2-3 hours',
      difficulty: 'Advanced',
      objectives: JSON.stringify(['Master MIS systems', 'Learn data analysis', 'Understand reporting tools']),
      order: 15
    },
    {
      title: 'Essential Certificate',
      description: 'Essential certification requirements, documentation, and compliance procedures.',
      icon: 'Award',
      estimatedTime: '1-2 hours',
      difficulty: 'Intermediate',
      objectives: JSON.stringify(['Understand certification requirements', 'Learn documentation procedures', 'Master compliance processes']),
      order: 35
    },
    {
      title: 'Equipment Hire',
      description: 'Equipment hire processes, rental management, and maintenance procedures.',
      icon: 'Settings',
      estimatedTime: '1-2 hours',
      difficulty: 'Beginner',
      objectives: JSON.stringify(['Learn equipment hire processes', 'Understand rental management', 'Master maintenance procedures']),
      order: 45
    },
    {
      title: 'Public Notice',
      description: 'Public notice requirements, communication protocols, and regulatory compliance.',
      icon: 'Bell',
      estimatedTime: '1-2 hours',
      difficulty: 'Beginner',
      objectives: JSON.stringify(['Understand public notice requirements', 'Learn communication protocols', 'Master regulatory compliance']),
      order: 50
    },
    {
      title: 'Project',
      description: 'Project management methodologies, planning, and execution strategies.',
      icon: 'FolderOpen',
      estimatedTime: '2-3 hours',
      difficulty: 'Advanced',
      objectives: JSON.stringify(['Master project management', 'Learn planning methodologies', 'Understand execution strategies']),
      order: 55
    }
  ];

  modules.forEach(module => {
    insertModule.run(
      module.title,
      module.description,
      module.icon,
      module.estimatedTime,
      module.difficulty,
      module.objectives,
      module.order
    );
  });

  // Insert sample sections
  const insertSection = db.prepare(`
    INSERT INTO sections (title, description, module_id, order_index)
    VALUES (?, ?, ?, ?)
  `);

  const sections = [
    // CB – Imports (Module 1)
    { title: 'Import Fundamentals', description: 'Basic concepts and terminology for imports', moduleId: 1, order: 1 },
    { title: 'Customs Bonded Procedures', description: 'Customs bonded warehouse operations and procedures', moduleId: 1, order: 2 },
    { title: 'Documentation & Compliance', description: 'Required documents and regulatory compliance for imports', moduleId: 1, order: 3 },
    
    // Freight Forwarding (Module 2)
    { title: 'Freight Forwarding Basics', description: 'Introduction to freight forwarding operations', moduleId: 2, order: 1 },
    { title: 'Documentation Management', description: 'Managing freight forwarding documentation', moduleId: 2, order: 2 },
    { title: 'Logistics Coordination', description: 'Coordinating multi-modal logistics operations', moduleId: 2, order: 3 },
    
    // NBCPL (Module 3)
    { title: 'Port Operations', description: 'NBCPL port operations and procedures', moduleId: 3, order: 1 },
    { title: 'Container Handling', description: 'Container operations at NBCPL', moduleId: 3, order: 2 },
    
    // Company Services (Module 4)
    { title: 'Service Overview', description: 'Overview of company services and offerings', moduleId: 4, order: 1 },
    { title: 'Internal Procedures', description: 'Internal company procedures and policies', moduleId: 4, order: 2 },
    
    // CB – Exports (Module 5)
    { title: 'Export Fundamentals', description: 'Basic concepts and terminology for exports', moduleId: 5, order: 1 },
    { title: 'Export Documentation', description: 'Required documents for export operations', moduleId: 5, order: 2 },
    { title: 'Customs Bonded Export Procedures', description: 'Customs bonded warehouse export procedures', moduleId: 5, order: 3 },
    
    // Contracts (Module 6)
    { title: 'Contract Management', description: 'Contract lifecycle management', moduleId: 6, order: 1 },
    { title: 'Legal Compliance', description: 'Legal requirements and compliance', moduleId: 6, order: 2 },
    { title: 'Negotiation Strategies', description: 'Contract negotiation best practices', moduleId: 6, order: 3 },
    
    // SEZ (Module 7)
    { title: 'SEZ Operations', description: 'Special Economic Zone operations', moduleId: 7, order: 1 },
    { title: 'Compliance Requirements', description: 'SEZ compliance and regulatory requirements', moduleId: 7, order: 2 },
    
    // Ops Accounting (Module 8)
    { title: 'Accounting Procedures', description: 'Operations accounting procedures', moduleId: 8, order: 1 },
    { title: 'Financial Reporting', description: 'Financial reporting and analysis', moduleId: 8, order: 2 },
    
    // Container Movement (Module 9)
    { title: 'Container Logistics', description: 'Container movement and logistics', moduleId: 9, order: 1 },
    { title: 'Tracking Systems', description: 'Container tracking and monitoring systems', moduleId: 9, order: 2 },
    
    // CRM (Module 10)
    { title: 'CRM Systems', description: 'Customer relationship management systems', moduleId: 10, order: 1 },
    { title: 'Customer Management', description: 'Customer data and relationship management', moduleId: 10, order: 2 },
    
    // Babaji Transport (Module 11)
    { title: 'Transport Operations', description: 'Transport and fleet operations', moduleId: 11, order: 1 },
    { title: 'Fleet Management', description: 'Fleet management and maintenance', moduleId: 11, order: 2 },
    
    // Additional Job (Module 12)
    { title: 'Cross-functional Training', description: 'Additional job responsibilities and training', moduleId: 12, order: 1 },
    { title: 'Skill Development', description: 'Professional skill development', moduleId: 12, order: 2 },
    
    // MIS (Module 13)
    { title: 'MIS Systems', description: 'Management Information Systems overview', moduleId: 13, order: 1 },
    { title: 'Data Analysis', description: 'Data analysis and reporting tools', moduleId: 13, order: 2 },
    
    // Essential Certificate (Module 14)
    { title: 'Certification Requirements', description: 'Essential certification requirements', moduleId: 14, order: 1 },
    { title: 'Documentation Procedures', description: 'Certification documentation procedures', moduleId: 14, order: 2 },
    
    // Equipment Hire (Module 15)
    { title: 'Equipment Rental', description: 'Equipment hire and rental processes', moduleId: 15, order: 1 },
    { title: 'Maintenance Procedures', description: 'Equipment maintenance and management', moduleId: 15, order: 2 },
    
    // Public Notice (Module 16)
    { title: 'Notice Requirements', description: 'Public notice requirements and procedures', moduleId: 16, order: 1 },
    { title: 'Communication Protocols', description: 'Public communication protocols', moduleId: 16, order: 2 },
    
    // Project (Module 17)
    { title: 'Project Planning', description: 'Project planning and methodology', moduleId: 17, order: 1 },
    { title: 'Project Execution', description: 'Project execution and management', moduleId: 17, order: 2 }
  ];

  sections.forEach(section => {
    insertSection.run(section.title, section.description, section.moduleId, section.order);
  });

  // Insert sample lessons
  const insertLesson = db.prepare(`
    INSERT INTO lessons (title, description, type, duration, section_id, order_index, video_url, document_content)
    VALUES (?, ?, ?, ?, ?, ?, ?, ?)
  `);

  const lessons = [
    // CB - Imports lessons
    {
      title: 'Introduction to Import Management',
      description: 'Overview of import processes and key stakeholders',
      type: 'video',
      duration: '15 min',
      sectionId: 1,
      order: 1,
      videoUrl: 'https://www.youtube.com/embed/example',
      documentContent: null
    },
    {
      title: 'Import Terminology and Basics',
      description: 'Key terms and definitions in import management',
      type: 'document',
      duration: '10 min',
      sectionId: 1,
      order: 2,
      videoUrl: null,
      documentContent: '<h3>Import Terminology</h3><p>Key terms and definitions used in import management...</p>'
    },
    {
      title: 'Customs Bonded Warehouse Operations',
      description: 'Understanding customs bonded warehouse procedures',
      type: 'document',
      duration: '20 min',
      sectionId: 2,
      order: 1,
      videoUrl: null,
      documentContent: '<h3>Customs Bonded Operations</h3><p>Overview of customs bonded warehouse operations and procedures...</p>'
    },
    {
      title: 'Import Documentation Requirements',
      description: 'Essential documents for import operations',
      type: 'document',
      duration: '25 min',
      sectionId: 3,
      order: 1,
      videoUrl: null,
      documentContent: '<h3>Required Documents</h3><p>Essential import documents and their purposes...</p>'
    },
    
    // Freight Forwarding lessons
    {
      title: 'Introduction to Freight Forwarding',
      description: 'Overview of freight forwarding operations',
      type: 'video',
      duration: '15 min',
      sectionId: 4,
      order: 1,
      videoUrl: 'https://www.youtube.com/embed/example',
      documentContent: null
    },
    {
      title: 'Freight Documentation Process',
      description: 'Managing freight forwarding documentation',
      type: 'document',
      duration: '20 min',
      sectionId: 5,
      order: 1,
      videoUrl: null,
      documentContent: '<h3>Freight Documentation</h3><p>Overview of freight forwarding documentation requirements...</p>'
    }
  ];

  lessons.forEach(lesson => {
    insertLesson.run(
      lesson.title,
      lesson.description,
      lesson.type,
      lesson.duration,
      lesson.sectionId,
      lesson.order,
      lesson.videoUrl,
      lesson.documentContent
    );
  });

  // Insert sample assessment
  const insertAssessment = db.prepare(`
    INSERT INTO assessments (title, description, module_id, section_id, passing_score, time_limit, max_attempts, is_required, trigger_type)
    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
  `);

  insertAssessment.run(
    'CB - Imports Fundamentals Quiz',
    'Test your understanding of basic customs bonded import concepts and procedures',
    1, // CB - Imports module
    1, // Import Fundamentals section
    70,
    30,
    3,
    1,
    'section_completion'
  );

  // Insert sample questions
  const insertQuestion = db.prepare(`
    INSERT INTO questions (assessment_id, type, question_text, options, correct_answers, explanation, points, order_index)
    VALUES (?, ?, ?, ?, ?, ?, ?, ?)
  `);

  const questions = [
    {
      assessmentId: 1,
      type: 'multiple-choice',
      questionText: 'What is the primary purpose of a Bill of Lading in import operations?',
      options: JSON.stringify([
        'To calculate customs duties',
        'To serve as a receipt and contract for transportation',
        'To determine product quality',
        'To set the selling price'
      ]),
      correctAnswers: JSON.stringify(['To serve as a receipt and contract for transportation']),
      explanation: 'A Bill of Lading serves as a receipt for goods shipped, a contract between the shipper and carrier, and a document of title.',
      points: 5,
      order: 1
    },
    {
      assessmentId: 1,
      type: 'true-false',
      questionText: 'All imported goods must go through customs inspection regardless of their value.',
      options: JSON.stringify(['True', 'False']),
      correctAnswers: JSON.stringify(['False']),
      explanation: 'Not all goods require physical inspection. Many are cleared through automated systems based on risk assessment.',
      points: 3,
      order: 2
    },
    {
      assessmentId: 1,
      type: 'short-answer',
      questionText: 'What does "CIF" stand for in international trade terms?',
      options: JSON.stringify([]),
      correctAnswers: JSON.stringify(['Cost, Insurance, and Freight']),
      explanation: 'CIF means the seller pays for cost, insurance, and freight to deliver goods to the destination port.',
      points: 4,
      order: 3
    }
  ];

  questions.forEach(question => {
    insertQuestion.run(
      question.assessmentId,
      question.type,
      question.questionText,
      question.options,
      question.correctAnswers,
      question.explanation,
      question.points,
      question.order
    );
  });

  console.log('✅ Sample data inserted successfully!');
}

// Utility functions for database operations
export const dbUtils = {
  // User operations
  createUser: (userData: any) => {
    const stmt = db.prepare(`
      INSERT INTO users (id, email, password_hash, first_name, last_name, department, role)
      VALUES (?, ?, ?, ?, ?, ?, ?)
    `);
    return stmt.run(userData.id, userData.email, userData.passwordHash, userData.firstName, userData.lastName, userData.department, userData.role);
  },

  getUserByEmail: (email: string) => {
    const stmt = db.prepare('SELECT * FROM users WHERE email = ? AND is_active = 1');
    return stmt.get(email);
  },

  // Module operations
  getAllModules: () => {
    const stmt = db.prepare(`
      SELECT m.*, 
             COUNT(s.id) as section_count,
             COUNT(l.id) as lesson_count
      FROM modules m
      LEFT JOIN sections s ON m.id = s.module_id AND s.is_active = 1
      LEFT JOIN lessons l ON s.id = l.section_id AND l.is_active = 1
      WHERE m.is_active = 1
      GROUP BY m.id
      ORDER BY m.order_index
    `);
    return stmt.all();
  },

  getModuleWithSections: (moduleId: number) => {
    const moduleStmt = db.prepare('SELECT * FROM modules WHERE id = ? AND is_active = 1');
    const sectionsStmt = db.prepare(`
      SELECT s.*, COUNT(l.id) as lesson_count
      FROM sections s
      LEFT JOIN lessons l ON s.id = l.section_id AND l.is_active = 1
      WHERE s.module_id = ? AND s.is_active = 1
      GROUP BY s.id
      ORDER BY s.order_index
    `);
    
    const module = moduleStmt.get(moduleId) as any;
    if (module) {
      module.sections = sectionsStmt.all(moduleId);
    }
    return module;
  },

  // Assessment operations
  getAllAssessments: () => {
    const stmt = db.prepare(`
      SELECT a.*, m.title as module_name, s.title as section_name,
             COUNT(q.id) as question_count,
             SUM(q.points) as total_points
      FROM assessments a
      JOIN modules m ON a.module_id = m.id
      LEFT JOIN sections s ON a.section_id = s.id
      LEFT JOIN questions q ON a.id = q.assessment_id
      WHERE a.is_active = 1
      GROUP BY a.id
      ORDER BY a.created_at DESC
    `);
    return stmt.all();
  },

  createAssessment: (assessmentData: any) => {
    const stmt = db.prepare(`
      INSERT INTO assessments (title, description, module_id, section_id, passing_score, time_limit, max_attempts, is_required, trigger_type)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
    `);
    return stmt.run(
      assessmentData.title,
      assessmentData.description,
      assessmentData.moduleId,
      assessmentData.sectionId,
      assessmentData.passingScore,
      assessmentData.timeLimit,
      assessmentData.maxAttempts,
      assessmentData.isRequired,
      assessmentData.triggerType
    );
  },

  // Question operations
  getQuestionsByAssessment: (assessmentId: number) => {
    const stmt = db.prepare(`
      SELECT * FROM questions 
      WHERE assessment_id = ? 
      ORDER BY order_index
    `);
    return stmt.all(assessmentId);
  },

  createQuestion: (questionData: any) => {
    const stmt = db.prepare(`
      INSERT INTO questions (assessment_id, type, question_text, options, correct_answers, explanation, points, order_index)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?)
    `);
    return stmt.run(
      questionData.assessmentId,
      questionData.type,
      questionData.questionText,
      JSON.stringify(questionData.options || []),
      JSON.stringify(questionData.correctAnswers || []),
      questionData.explanation,
      questionData.points,
      questionData.orderIndex
    );
  },

  deleteQuestion: (questionId: number) => {
    const stmt = db.prepare('DELETE FROM questions WHERE id = ?');
    return stmt.run(questionId);
  },

  // Progress tracking
  getUserModuleProgress: (userId: string, moduleId: number) => {
    const stmt = db.prepare(`
      SELECT * FROM user_module_progress 
      WHERE user_id = ? AND module_id = ?
    `);
    return stmt.get(userId, moduleId);
  },

  updateModuleProgress: (userId: string, moduleId: number, percentage: number) => {
    const stmt = db.prepare(`
      INSERT OR REPLACE INTO user_module_progress (user_id, module_id, completion_percentage, is_completed, updated_at)
      VALUES (?, ?, ?, ?, CURRENT_TIMESTAMP)
    `);
    return stmt.run(userId, moduleId, percentage, percentage >= 100 ? 1 : 0);
  }
};