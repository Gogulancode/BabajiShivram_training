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
      category TEXT NOT NULL,
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
    INSERT INTO modules (title, description, icon, category, estimated_time, difficulty, learning_objectives, order_index)
    VALUES (?, ?, ?, ?, ?, ?, ?, ?)
  `);

  const modules = [
    {
      title: 'Import Management',
      description: 'Learn the fundamentals of import management, documentation, and compliance procedures.',
      icon: 'Package',
      category: 'Trade Operations',
      estimatedTime: '2-3 hours',
      difficulty: 'Beginner',
      objectives: JSON.stringify(['Understand import documentation requirements', 'Learn compliance procedures', 'Master import cost calculations']),
      order: 1
    },
    {
      title: 'Export Operations',
      description: 'Master export procedures, documentation, and international shipping requirements.',
      icon: 'Truck',
      category: 'Trade Operations',
      estimatedTime: '2-3 hours',
      difficulty: 'Intermediate',
      objectives: JSON.stringify(['Understand export documentation', 'Learn shipping procedures', 'Master export regulations']),
      order: 2
    },
    {
      title: 'Freight Management',
      description: 'Learn freight booking, tracking, and cost optimization strategies.',
      icon: 'Ship',
      category: 'Logistics',
      estimatedTime: '1-2 hours',
      difficulty: 'Intermediate',
      objectives: JSON.stringify(['Master freight booking procedures', 'Understand shipping modes', 'Learn cost optimization']),
      order: 3
    },
    {
      title: 'Inventory Control',
      description: 'Optimize inventory levels, tracking, and warehouse management.',
      icon: 'Archive',
      category: 'Operations',
      estimatedTime: '1-2 hours',
      difficulty: 'Beginner',
      objectives: JSON.stringify(['Learn inventory optimization', 'Master stock tracking', 'Understand warehouse management']),
      order: 4
    },
    {
      title: 'Financial Reports',
      description: 'Generate insights through comprehensive reporting and data analysis.',
      icon: 'BarChart3',
      category: 'Finance',
      estimatedTime: '1-2 hours',
      difficulty: 'Advanced',
      objectives: JSON.stringify(['Master report generation', 'Learn data analysis', 'Understand KPI tracking']),
      order: 5
    },
    {
      title: 'Customer Management',
      description: 'Build and maintain strong customer relationships and communication.',
      icon: 'Users',
      category: 'CRM',
      estimatedTime: '1 hour',
      difficulty: 'Beginner',
      objectives: JSON.stringify(['Learn customer communication', 'Master relationship building', 'Understand service excellence']),
      order: 6
    }
  ];

  modules.forEach(module => {
    insertModule.run(
      module.title,
      module.description,
      module.icon,
      module.category,
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
    { title: 'Import Fundamentals', description: 'Basic concepts and terminology', moduleId: 1, order: 1 },
    { title: 'Documentation & Compliance', description: 'Required documents and regulatory compliance', moduleId: 1, order: 2 },
    { title: 'Customs Procedures', description: 'Customs clearance and procedures', moduleId: 1, order: 3 },
    { title: 'Export Basics', description: 'Fundamental export concepts', moduleId: 2, order: 1 },
    { title: 'International Regulations', description: 'Export regulations and compliance', moduleId: 2, order: 2 },
    { title: 'Freight Booking', description: 'Booking and managing freight shipments', moduleId: 3, order: 1 },
    { title: 'Cost Optimization', description: 'Strategies for freight cost optimization', moduleId: 3, order: 2 },
    { title: 'Stock Management', description: 'Managing inventory and stock levels', moduleId: 4, order: 1 },
    { title: 'Warehouse Operations', description: 'Warehouse management best practices', moduleId: 4, order: 2 },
    { title: 'Report Generation', description: 'Creating and customizing reports', moduleId: 5, order: 1 },
    { title: 'Data Analysis', description: 'Analyzing data and generating insights', moduleId: 5, order: 2 },
    { title: 'Customer Data', description: 'Managing customer information', moduleId: 6, order: 1 },
    { title: 'Relationship Management', description: 'Building strong customer relationships', moduleId: 6, order: 2 }
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
      title: 'Import Terminology',
      description: 'Key terms and definitions in import management',
      type: 'document',
      duration: '10 min',
      sectionId: 1,
      order: 2,
      videoUrl: null,
      documentContent: '<h3>Import Terminology</h3><p>Key terms and definitions used in import management...</p>'
    },
    {
      title: 'Import Documentation Requirements',
      description: 'Essential documents for import operations',
      type: 'document',
      duration: '25 min',
      sectionId: 2,
      order: 1,
      videoUrl: null,
      documentContent: '<h3>Required Documents</h3><p>Essential import documents and their purposes...</p>'
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
    'Import Management Fundamentals Quiz',
    'Test your understanding of basic import concepts and procedures',
    1, // Import Management module
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
    
    const module = moduleStmt.get(moduleId);
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