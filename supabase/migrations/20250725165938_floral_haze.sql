/*
  # Insert Sample Data for ERP Training Platform

  1. Sample Data
    - Default admin user
    - Sample modules with sections and lessons
    - Sample assessments with questions
    - Sample uploaded content

  2. Notes
    - This creates a complete learning environment
    - Includes realistic training content
    - Sets up proper relationships between all entities
*/

-- Insert sample modules
INSERT INTO modules (id, title, description, icon, category, color, estimated_time, difficulty, prerequisites, learning_objectives, order_index) VALUES
(
  '11111111-1111-1111-1111-111111111111',
  'Import Management',
  'Learn the fundamentals of import management, documentation, and compliance procedures.',
  'Package',
  'Trade Operations',
  'blue',
  '2-3 hours',
  'Beginner',
  '[]'::jsonb,
  '["Understand import documentation requirements", "Learn compliance procedures", "Master import cost calculations"]'::jsonb,
  1
),
(
  '22222222-2222-2222-2222-222222222222',
  'Export Operations',
  'Master export procedures, documentation, and international shipping requirements.',
  'Truck',
  'Trade Operations',
  'green',
  '2-3 hours',
  'Intermediate',
  '["11111111-1111-1111-1111-111111111111"]'::jsonb,
  '["Understand export documentation", "Learn shipping procedures", "Master export regulations"]'::jsonb,
  2
),
(
  '33333333-3333-3333-3333-333333333333',
  'Freight Management',
  'Learn freight booking, tracking, and cost optimization strategies.',
  'Ship',
  'Logistics',
  'purple',
  '1-2 hours',
  'Intermediate',
  '["11111111-1111-1111-1111-111111111111", "22222222-2222-2222-2222-222222222222"]'::jsonb,
  '["Master freight booking procedures", "Understand shipping modes", "Learn cost optimization"]'::jsonb,
  3
),
(
  '44444444-4444-4444-4444-444444444444',
  'Inventory Control',
  'Optimize inventory levels, tracking, and warehouse management.',
  'Archive',
  'Operations',
  'orange',
  '1-2 hours',
  'Beginner',
  '[]'::jsonb,
  '["Learn inventory optimization", "Master stock tracking", "Understand warehouse management"]'::jsonb,
  4
),
(
  '55555555-5555-5555-5555-555555555555',
  'Financial Reports',
  'Generate insights through comprehensive reporting and data analysis.',
  'BarChart3',
  'Finance',
  'red',
  '1-2 hours',
  'Advanced',
  '["11111111-1111-1111-1111-111111111111", "22222222-2222-2222-2222-222222222222", "33333333-3333-3333-3333-333333333333", "44444444-4444-4444-4444-444444444444"]'::jsonb,
  '["Master report generation", "Learn data analysis", "Understand KPI tracking"]'::jsonb,
  5
),
(
  '66666666-6666-6666-6666-666666666666',
  'Customer Management',
  'Build and maintain strong customer relationships and communication.',
  'Users',
  'Customer Service',
  'indigo',
  '1 hour',
  'Beginner',
  '[]'::jsonb,
  '["Learn customer communication", "Master relationship building", "Understand service excellence"]'::jsonb,
  6
);

-- Insert sample sections
INSERT INTO sections (id, module_id, title, description, order_index) VALUES
-- Import Management sections
('11111111-1111-1111-1111-111111111101', '11111111-1111-1111-1111-111111111111', 'Import Fundamentals', 'Basic concepts and terminology', 1),
('11111111-1111-1111-1111-111111111102', '11111111-1111-1111-1111-111111111111', 'Documentation & Compliance', 'Required documents and regulatory compliance', 2),
('11111111-1111-1111-1111-111111111103', '11111111-1111-1111-1111-111111111111', 'Customs Procedures', 'Understanding customs processes and requirements', 3),

-- Export Operations sections
('22222222-2222-2222-2222-222222222201', '22222222-2222-2222-2222-222222222222', 'Export Basics', 'Fundamental export concepts', 1),
('22222222-2222-2222-2222-222222222202', '22222222-2222-2222-2222-222222222222', 'International Regulations', 'Global trade regulations and compliance', 2),

-- Freight Management sections
('33333333-3333-3333-3333-333333333301', '33333333-3333-3333-3333-333333333333', 'Freight Booking', 'Booking and managing freight shipments', 1),
('33333333-3333-3333-3333-333333333302', '33333333-3333-3333-3333-333333333333', 'Cost Optimization', 'Strategies for reducing freight costs', 2),

-- Inventory Control sections
('44444444-4444-4444-4444-444444444401', '44444444-4444-4444-4444-444444444444', 'Stock Management', 'Managing inventory and stock levels', 1),
('44444444-4444-4444-4444-444444444402', '44444444-4444-4444-4444-444444444444', 'Warehouse Operations', 'Efficient warehouse management practices', 2),

-- Financial Reports sections
('55555555-5555-5555-5555-555555555501', '55555555-5555-5555-5555-555555555555', 'Report Generation', 'Creating and customizing reports', 1),
('55555555-5555-5555-5555-555555555502', '55555555-5555-5555-5555-555555555555', 'Data Analysis', 'Analyzing financial data and trends', 2),

-- Customer Management sections
('66666666-6666-6666-6666-666666666601', '66666666-6666-6666-6666-666666666666', 'Customer Relations', 'Building strong customer relationships', 1),
('66666666-6666-6666-6666-666666666602', '66666666-6666-6666-6666-666666666666', 'Communication Skills', 'Effective customer communication techniques', 2);

-- Insert sample lessons
INSERT INTO lessons (id, section_id, title, description, type, duration, order_index, video_url, document_content, has_assessment) VALUES
-- Import Fundamentals lessons
('11111111-1111-1111-1111-111111110001', '11111111-1111-1111-1111-111111111101', 'Introduction to Import Management', 'Overview of import processes and key stakeholders', 'video', '15 min', 1, 'https://www.youtube.com/embed/example1', NULL, false),
('11111111-1111-1111-1111-111111110002', '11111111-1111-1111-1111-111111111101', 'Import Terminology', 'Key terms and definitions in import management', 'document', '10 min', 2, NULL, '<h3>Import Terminology</h3><p>Understanding key terms in import management is crucial for success. This lesson covers essential vocabulary including Bill of Lading, Commercial Invoice, Certificate of Origin, and more.</p><h4>Key Terms:</h4><ul><li><strong>Bill of Lading:</strong> A legal document between shipper and carrier</li><li><strong>Commercial Invoice:</strong> Document showing transaction details</li><li><strong>Certificate of Origin:</strong> Document proving where goods were manufactured</li></ul>', false),
('11111111-1111-1111-1111-111111110003', '11111111-1111-1111-1111-111111111101', 'Import Fundamentals Quiz', 'Test your understanding of basic import concepts', 'quiz', '20 min', 3, NULL, NULL, true),

-- Documentation & Compliance lessons
('11111111-1111-1111-1111-111111110004', '11111111-1111-1111-1111-111111111102', 'Import Documentation Requirements', 'Essential documents for import operations', 'document', '25 min', 1, NULL, '<h3>Required Import Documents</h3><p>Successful import operations require proper documentation. This lesson covers all essential documents needed for importing goods.</p><h4>Essential Documents:</h4><ol><li>Commercial Invoice</li><li>Bill of Lading</li><li>Packing List</li><li>Certificate of Origin</li><li>Import License (if required)</li><li>Insurance Certificate</li></ol><p>Each document serves a specific purpose in the import process and must be accurate and complete.</p>', false),
('11111111-1111-1111-1111-111111110005', '11111111-1111-1111-1111-111111111102', 'Compliance Procedures', 'Understanding regulatory compliance requirements', 'video', '30 min', 2, 'https://www.youtube.com/embed/example2', NULL, false),

-- Export Basics lessons
('22222222-2222-2222-2222-222222220001', '22222222-2222-2222-2222-222222222201', 'Export Fundamentals', 'Basic export procedures and requirements', 'video', '20 min', 1, 'https://www.youtube.com/embed/example3', NULL, false),
('22222222-2222-2222-2222-222222220002', '22222222-2222-2222-2222-222222222201', 'Export Documentation', 'Required documents for export operations', 'document', '15 min', 2, NULL, '<h3>Export Documentation</h3><p>Export operations require specific documentation to ensure smooth international trade.</p>', false);

-- Insert sample assessments
INSERT INTO assessments (id, title, description, module_id, section_id, passing_score, time_limit, max_attempts, is_required, trigger_type) VALUES
(
  'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
  'Import Management Fundamentals Quiz',
  'Test your understanding of basic import concepts and procedures',
  '11111111-1111-1111-1111-111111111111',
  '11111111-1111-1111-1111-111111111101',
  70,
  30,
  3,
  true,
  'section_completion'
),
(
  'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
  'Documentation & Compliance Assessment',
  'Evaluate your knowledge of import documentation and compliance requirements',
  '11111111-1111-1111-1111-111111111111',
  '11111111-1111-1111-1111-111111111102',
  80,
  45,
  3,
  true,
  'section_completion'
),
(
  'cccccccc-cccc-cccc-cccc-cccccccccccc',
  'Export Operations Final Exam',
  'Comprehensive exam covering all export procedures and international regulations',
  '22222222-2222-2222-2222-222222222222',
  NULL,
  80,
  60,
  2,
  false,
  'module_completion'
);

-- Insert sample questions
INSERT INTO questions (id, assessment_id, type, question_text, options, correct_answers, explanation, points, order_index) VALUES
-- Import Fundamentals Quiz questions
(
  'q1111111-1111-1111-1111-111111111111',
  'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
  'multiple_choice',
  'What is the primary purpose of a Bill of Lading in import operations?',
  '["To calculate customs duties", "To serve as a receipt and contract for transportation", "To determine product quality", "To set the selling price"]'::jsonb,
  '["To serve as a receipt and contract for transportation"]'::jsonb,
  'A Bill of Lading serves as a receipt for goods shipped, a contract between the shipper and carrier, and a document of title.',
  5,
  1
),
(
  'q1111111-1111-1111-1111-111111111112',
  'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
  'true_false',
  'All imported goods must go through customs inspection regardless of their value.',
  '[]'::jsonb,
  '["false"]'::jsonb,
  'Not all goods require physical inspection. Many are cleared through automated systems based on risk assessment.',
  3,
  2
),
(
  'q1111111-1111-1111-1111-111111111113',
  'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
  'single_choice',
  'Which document is required to prove the origin of imported goods?',
  '["Commercial Invoice", "Certificate of Origin", "Packing List", "Insurance Certificate"]'::jsonb,
  '["Certificate of Origin"]'::jsonb,
  'A Certificate of Origin proves where goods were manufactured and may affect duty rates under trade agreements.',
  5,
  3
),
(
  'q1111111-1111-1111-1111-111111111114',
  'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
  'short_answer',
  'What does "CIF" stand for in international trade terms?',
  '[]'::jsonb,
  '["Cost, Insurance, and Freight"]'::jsonb,
  'CIF means the seller pays for cost, insurance, and freight to deliver goods to the destination port.',
  4,
  4
),
(
  'q1111111-1111-1111-1111-111111111115',
  'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
  'multiple_choice',
  'What is the purpose of an Import License?',
  '["To track shipment location", "To authorize the import of restricted goods", "To calculate shipping costs", "To determine product quality"]'::jsonb,
  '["To authorize the import of restricted goods"]'::jsonb,
  'Import licenses are required for certain restricted or controlled goods to ensure compliance with regulations.',
  5,
  5
),

-- Documentation & Compliance Assessment questions
(
  'q2222222-2222-2222-2222-222222222221',
  'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
  'multiple_choice',
  'Which documents are typically required for customs clearance? (Select all that apply)',
  '["Commercial Invoice", "Bill of Lading", "Packing List", "Certificate of Origin", "Personal Letter"]'::jsonb,
  '["Commercial Invoice", "Bill of Lading", "Packing List", "Certificate of Origin"]'::jsonb,
  'These four documents are standard requirements for customs clearance in most countries.',
  10,
  1
),
(
  'q2222222-2222-2222-2222-222222222222',
  'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
  'essay',
  'Explain the importance of accurate documentation in import operations and describe the consequences of documentation errors.',
  '[]'::jsonb,
  '["Accurate documentation ensures smooth customs clearance, prevents delays, reduces costs, and maintains compliance with regulations. Errors can lead to shipment delays, additional fees, penalties, and potential legal issues."]'::jsonb,
  15,
  2
);

-- Insert sample uploaded content
INSERT INTO uploaded_contents (id, title, description, type, module_id, section_id, uploaded_by_id, tags, access_roles, scribe_link) VALUES
(
  'c1111111-1111-1111-1111-111111111111',
  'Import Documentation Guide',
  'Comprehensive guide for import documentation requirements',
  'document',
  '11111111-1111-1111-1111-111111111111',
  '11111111-1111-1111-1111-111111111102',
  (SELECT id FROM users LIMIT 1),
  '["documentation", "import", "guide", "compliance"]'::jsonb,
  '["User", "QA", "Admin"]'::jsonb,
  'https://scribe.com/example-import-guide'
),
(
  'c2222222-2222-2222-2222-222222222222',
  'Export Procedures Video Tutorial',
  'Step-by-step video tutorial for export procedures',
  'video',
  '22222222-2222-2222-2222-222222222222',
  '22222222-2222-2222-2222-222222222201',
  (SELECT id FROM users LIMIT 1),
  '["export", "tutorial", "video", "procedures"]'::jsonb,
  '["User", "QA", "Admin"]'::jsonb,
  NULL
);

-- Create a view for module progress summary
CREATE OR REPLACE VIEW vw_module_progress_summary AS
SELECT 
  m.id as module_id,
  m.title as module_title,
  m.category,
  m.difficulty,
  COUNT(DISTINCT s.id) as total_sections,
  COUNT(DISTINCT l.id) as total_lessons,
  COUNT(DISTINCT a.id) as total_assessments,
  COUNT(DISTINCT ump.user_id) as users_enrolled,
  COUNT(DISTINCT CASE WHEN ump.is_completed THEN ump.user_id END) as users_completed,
  ROUND(
    CASE 
      WHEN COUNT(DISTINCT ump.user_id) = 0 THEN 0
      ELSE (COUNT(DISTINCT CASE WHEN ump.is_completed THEN ump.user_id END)::decimal / COUNT(DISTINCT ump.user_id)::decimal) * 100
    END, 2
  ) as completion_rate
FROM modules m
LEFT JOIN sections s ON m.id = s.module_id AND s.is_active = true
LEFT JOIN lessons l ON s.id = l.section_id AND l.is_active = true
LEFT JOIN assessments a ON m.id = a.module_id AND a.is_active = true
LEFT JOIN user_module_progress ump ON m.id = ump.module_id
WHERE m.is_active = true
GROUP BY m.id, m.title, m.category, m.difficulty, m.order_index
ORDER BY m.order_index;

-- Create a view for assessment performance
CREATE OR REPLACE VIEW vw_assessment_performance AS
SELECT 
  a.id as assessment_id,
  a.title as assessment_title,
  m.title as module_title,
  s.title as section_title,
  a.passing_score,
  COUNT(DISTINCT aa.user_id) as total_attempts_users,
  COUNT(aa.id) as total_attempts,
  COUNT(CASE WHEN aa.passed THEN 1 END) as passed_attempts,
  ROUND(
    CASE 
      WHEN COUNT(aa.id) = 0 THEN 0
      ELSE (COUNT(CASE WHEN aa.passed THEN 1 END)::decimal / COUNT(aa.id)::decimal) * 100
    END, 2
  ) as pass_rate,
  ROUND(AVG(aa.score), 2) as average_score,
  MAX(aa.score) as highest_score,
  MIN(aa.score) as lowest_score
FROM assessments a
JOIN modules m ON a.module_id = m.id
LEFT JOIN sections s ON a.section_id = s.id
LEFT JOIN assessment_attempts aa ON a.id = aa.assessment_id AND aa.status = 'completed'
WHERE a.is_active = true
GROUP BY a.id, a.title, m.title, s.title, a.passing_score
ORDER BY m.title, s.title, a.title;

-- Create a function to get user dashboard data
CREATE OR REPLACE FUNCTION get_user_dashboard(p_user_id uuid)
RETURNS TABLE (
  total_modules integer,
  completed_modules integer,
  in_progress_modules integer,
  overall_progress numeric,
  recent_activity jsonb
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    COUNT(DISTINCT m.id)::integer as total_modules,
    COUNT(DISTINCT CASE WHEN ump.is_completed THEN m.id END)::integer as completed_modules,
    COUNT(DISTINCT CASE WHEN ump.completion_percentage > 0 AND NOT ump.is_completed THEN m.id END)::integer as in_progress_modules,
    ROUND(AVG(COALESCE(ump.completion_percentage, 0)), 2) as overall_progress,
    jsonb_agg(
      jsonb_build_object(
        'type', 'module_progress',
        'module_title', m.title,
        'progress', COALESCE(ump.completion_percentage, 0),
        'updated_at', COALESCE(ump.updated_at, m.created_at)
      ) ORDER BY COALESCE(ump.updated_at, m.created_at) DESC
    ) FILTER (WHERE m.id IS NOT NULL) as recent_activity
  FROM modules m
  LEFT JOIN user_module_progress ump ON m.id = ump.module_id AND ump.user_id = p_user_id
  WHERE m.is_active = true;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;