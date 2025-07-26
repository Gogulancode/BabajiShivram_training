/*
  # Create Assessments and Questions System

  1. New Tables
    - `assessments`
      - `id` (uuid, primary key)
      - `title` (text)
      - `description` (text)
      - `module_id` (uuid, foreign key)
      - `section_id` (uuid, foreign key, optional)
      - `lesson_id` (uuid, foreign key, optional)
      - `passing_score` (integer)
      - `time_limit` (integer, minutes)
      - `max_attempts` (integer)
      - `is_active` (boolean)
      - `is_required` (boolean)
      - `trigger_type` (text)
      - `created_at` (timestamp)
      - `updated_at` (timestamp)
    
    - `questions`
      - `id` (uuid, primary key)
      - `assessment_id` (uuid, foreign key)
      - `type` (text)
      - `question_text` (text)
      - `options` (jsonb array)
      - `correct_answers` (jsonb array)
      - `explanation` (text, optional)
      - `points` (integer)
      - `order_index` (integer)
      - `created_at` (timestamp)
      - `updated_at` (timestamp)
    
    - `assessment_attempts`
      - `id` (uuid, primary key)
      - `user_id` (uuid, foreign key)
      - `assessment_id` (uuid, foreign key)
      - `started_at` (timestamp)
      - `completed_at` (timestamp, optional)
      - `score` (integer)
      - `total_points` (integer)
      - `passed` (boolean)
      - `attempt_number` (integer)
      - `time_spent` (integer, seconds)
      - `status` (text)
    
    - `user_answers`
      - `id` (uuid, primary key)
      - `attempt_id` (uuid, foreign key)
      - `question_id` (uuid, foreign key)
      - `selected_answers` (jsonb array)
      - `text_answer` (text, optional)
      - `is_correct` (boolean)
      - `points_earned` (integer)
      - `answered_at` (timestamp)

  2. Security
    - Enable RLS on all tables
    - Add policies for different user roles
*/

-- Create assessments table
CREATE TABLE IF NOT EXISTS assessments (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  title text NOT NULL,
  description text NOT NULL DEFAULT '',
  module_id uuid REFERENCES modules(id) ON DELETE CASCADE,
  section_id uuid REFERENCES sections(id) ON DELETE SET NULL,
  lesson_id uuid REFERENCES lessons(id) ON DELETE SET NULL,
  passing_score integer NOT NULL DEFAULT 70 CHECK (passing_score >= 0 AND passing_score <= 100),
  time_limit integer NOT NULL DEFAULT 30 CHECK (time_limit > 0),
  max_attempts integer NOT NULL DEFAULT 3 CHECK (max_attempts > 0),
  is_active boolean DEFAULT true,
  is_required boolean DEFAULT false,
  trigger_type text NOT NULL DEFAULT 'section_completion' CHECK (trigger_type IN ('section_completion', 'module_completion', 'lesson_completion')),
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create questions table
CREATE TABLE IF NOT EXISTS questions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  assessment_id uuid REFERENCES assessments(id) ON DELETE CASCADE,
  type text NOT NULL DEFAULT 'multiple_choice' CHECK (type IN ('multiple_choice', 'single_choice', 'true_false', 'short_answer', 'essay')),
  question_text text NOT NULL,
  options jsonb DEFAULT '[]'::jsonb,
  correct_answers jsonb DEFAULT '[]'::jsonb,
  explanation text,
  points integer NOT NULL DEFAULT 5 CHECK (points > 0),
  order_index integer DEFAULT 0,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create assessment attempts table
CREATE TABLE IF NOT EXISTS assessment_attempts (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES users(id) ON DELETE CASCADE,
  assessment_id uuid REFERENCES assessments(id) ON DELETE CASCADE,
  started_at timestamptz DEFAULT now(),
  completed_at timestamptz,
  score integer DEFAULT 0,
  total_points integer DEFAULT 0,
  passed boolean DEFAULT false,
  attempt_number integer NOT NULL DEFAULT 1,
  time_spent integer DEFAULT 0,
  status text NOT NULL DEFAULT 'in_progress' CHECK (status IN ('in_progress', 'completed', 'abandoned', 'time_expired')),
  UNIQUE(user_id, assessment_id, attempt_number)
);

-- Create user answers table
CREATE TABLE IF NOT EXISTS user_answers (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  attempt_id uuid REFERENCES assessment_attempts(id) ON DELETE CASCADE,
  question_id uuid REFERENCES questions(id) ON DELETE CASCADE,
  selected_answers jsonb DEFAULT '[]'::jsonb,
  text_answer text,
  is_correct boolean DEFAULT false,
  points_earned integer DEFAULT 0,
  answered_at timestamptz DEFAULT now(),
  UNIQUE(attempt_id, question_id)
);

-- Enable RLS
ALTER TABLE assessments ENABLE ROW LEVEL SECURITY;
ALTER TABLE questions ENABLE ROW LEVEL SECURITY;
ALTER TABLE assessment_attempts ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_answers ENABLE ROW LEVEL SECURITY;

-- Create policies for assessments
CREATE POLICY "Anyone can read active assessments"
  ON assessments
  FOR SELECT
  TO authenticated
  USING (is_active = true);

CREATE POLICY "Admins and QA can manage assessments"
  ON assessments
  FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM user_roles ur
      JOIN users u ON ur.user_id = u.id
      WHERE u.auth_user_id = auth.uid()
      AND ur.role IN ('Admin', 'QA')
    )
  );

-- Create policies for questions
CREATE POLICY "Anyone can read questions for active assessments"
  ON questions
  FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM assessments a
      WHERE a.id = assessment_id AND a.is_active = true
    )
  );

CREATE POLICY "Admins and QA can manage questions"
  ON questions
  FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM user_roles ur
      JOIN users u ON ur.user_id = u.id
      WHERE u.auth_user_id = auth.uid()
      AND ur.role IN ('Admin', 'QA')
    )
  );

-- Create policies for assessment attempts
CREATE POLICY "Users can read own attempts"
  ON assessment_attempts
  FOR SELECT
  TO authenticated
  USING (
    user_id = (SELECT id FROM users WHERE auth_user_id = auth.uid())
  );

CREATE POLICY "Users can create own attempts"
  ON assessment_attempts
  FOR INSERT
  TO authenticated
  WITH CHECK (
    user_id = (SELECT id FROM users WHERE auth_user_id = auth.uid())
  );

CREATE POLICY "Users can update own attempts"
  ON assessment_attempts
  FOR UPDATE
  TO authenticated
  USING (
    user_id = (SELECT id FROM users WHERE auth_user_id = auth.uid())
  );

CREATE POLICY "Admins can read all attempts"
  ON assessment_attempts
  FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM user_roles ur
      JOIN users u ON ur.user_id = u.id
      WHERE u.auth_user_id = auth.uid()
      AND ur.role = 'Admin'
    )
  );

-- Create policies for user answers
CREATE POLICY "Users can manage own answers"
  ON user_answers
  FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM assessment_attempts aa
      JOIN users u ON aa.user_id = u.id
      WHERE aa.id = attempt_id
      AND u.auth_user_id = auth.uid()
    )
  );

CREATE POLICY "Admins can read all answers"
  ON user_answers
  FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM user_roles ur
      JOIN users u ON ur.user_id = u.id
      WHERE u.auth_user_id = auth.uid()
      AND ur.role = 'Admin'
    )
  );

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_assessments_module_id ON assessments(module_id);
CREATE INDEX IF NOT EXISTS idx_assessments_section_id ON assessments(section_id);
CREATE INDEX IF NOT EXISTS idx_assessments_active ON assessments(is_active);
CREATE INDEX IF NOT EXISTS idx_questions_assessment_id ON questions(assessment_id);
CREATE INDEX IF NOT EXISTS idx_questions_order ON questions(assessment_id, order_index);
CREATE INDEX IF NOT EXISTS idx_attempts_user_assessment ON assessment_attempts(user_id, assessment_id);
CREATE INDEX IF NOT EXISTS idx_attempts_status ON assessment_attempts(status);
CREATE INDEX IF NOT EXISTS idx_answers_attempt_id ON user_answers(attempt_id);
CREATE INDEX IF NOT EXISTS idx_answers_question_id ON user_answers(question_id);

-- Create triggers for updated_at
CREATE TRIGGER update_assessments_updated_at
  BEFORE UPDATE ON assessments
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_questions_updated_at
  BEFORE UPDATE ON questions
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();