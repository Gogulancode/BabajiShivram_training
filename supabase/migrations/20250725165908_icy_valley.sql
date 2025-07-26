/*
  # Create Progress Tracking System

  1. New Tables
    - `user_module_progress`
      - `id` (uuid, primary key)
      - `user_id` (uuid, foreign key)
      - `module_id` (uuid, foreign key)
      - `completion_percentage` (integer)
      - `is_completed` (boolean)
      - `completed_at` (timestamp, optional)
      - `started_at` (timestamp)
      - `updated_at` (timestamp)
    
    - `user_lesson_progress`
      - `id` (uuid, primary key)
      - `user_id` (uuid, foreign key)
      - `lesson_id` (uuid, foreign key)
      - `is_completed` (boolean)
      - `completed_at` (timestamp, optional)
      - `started_at` (timestamp)
      - `time_spent` (integer, seconds)
    
    - `uploaded_contents`
      - `id` (uuid, primary key)
      - `title` (text)
      - `description` (text)
      - `type` (text)
      - `file_path` (text)
      - `file_name` (text)
      - `file_size` (bigint)
      - `content_type` (text)
      - `module_id` (uuid, foreign key)
      - `section_id` (uuid, foreign key, optional)
      - `lesson_id` (uuid, foreign key, optional)
      - `uploaded_by_id` (uuid, foreign key)
      - `tags` (jsonb array)
      - `access_roles` (jsonb array)
      - `scribe_link` (text, optional)
      - `video_url` (text, optional)
      - `is_active` (boolean)
      - `created_at` (timestamp)
      - `updated_at` (timestamp)

  2. Security
    - Enable RLS on all tables
    - Add policies for progress tracking
*/

-- Create user module progress table
CREATE TABLE IF NOT EXISTS user_module_progress (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES users(id) ON DELETE CASCADE,
  module_id uuid REFERENCES modules(id) ON DELETE CASCADE,
  completion_percentage integer DEFAULT 0 CHECK (completion_percentage >= 0 AND completion_percentage <= 100),
  is_completed boolean DEFAULT false,
  completed_at timestamptz,
  started_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  UNIQUE(user_id, module_id)
);

-- Create user lesson progress table
CREATE TABLE IF NOT EXISTS user_lesson_progress (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES users(id) ON DELETE CASCADE,
  lesson_id uuid REFERENCES lessons(id) ON DELETE CASCADE,
  is_completed boolean DEFAULT false,
  completed_at timestamptz,
  started_at timestamptz DEFAULT now(),
  time_spent integer DEFAULT 0,
  UNIQUE(user_id, lesson_id)
);

-- Create uploaded contents table
CREATE TABLE IF NOT EXISTS uploaded_contents (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  title text NOT NULL,
  description text NOT NULL DEFAULT '',
  type text NOT NULL DEFAULT 'document' CHECK (type IN ('document', 'video', 'image', 'interactive')),
  file_path text NOT NULL DEFAULT '',
  file_name text NOT NULL DEFAULT '',
  file_size bigint DEFAULT 0,
  content_type text NOT NULL DEFAULT '',
  module_id uuid REFERENCES modules(id) ON DELETE CASCADE,
  section_id uuid REFERENCES sections(id) ON DELETE SET NULL,
  lesson_id uuid REFERENCES lessons(id) ON DELETE SET NULL,
  uploaded_by_id uuid REFERENCES users(id) ON DELETE CASCADE,
  tags jsonb DEFAULT '[]'::jsonb,
  access_roles jsonb DEFAULT '[]'::jsonb,
  scribe_link text,
  video_url text,
  is_active boolean DEFAULT true,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Enable RLS
ALTER TABLE user_module_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_lesson_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE uploaded_contents ENABLE ROW LEVEL SECURITY;

-- Create policies for user module progress
CREATE POLICY "Users can read own module progress"
  ON user_module_progress
  FOR SELECT
  TO authenticated
  USING (
    user_id = (SELECT id FROM users WHERE auth_user_id = auth.uid())
  );

CREATE POLICY "Users can manage own module progress"
  ON user_module_progress
  FOR ALL
  TO authenticated
  USING (
    user_id = (SELECT id FROM users WHERE auth_user_id = auth.uid())
  );

CREATE POLICY "Admins can read all module progress"
  ON user_module_progress
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

-- Create policies for user lesson progress
CREATE POLICY "Users can read own lesson progress"
  ON user_lesson_progress
  FOR SELECT
  TO authenticated
  USING (
    user_id = (SELECT id FROM users WHERE auth_user_id = auth.uid())
  );

CREATE POLICY "Users can manage own lesson progress"
  ON user_lesson_progress
  FOR ALL
  TO authenticated
  USING (
    user_id = (SELECT id FROM users WHERE auth_user_id = auth.uid())
  );

CREATE POLICY "Admins can read all lesson progress"
  ON user_lesson_progress
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

-- Create policies for uploaded contents
CREATE POLICY "Users can read accessible content"
  ON uploaded_contents
  FOR SELECT
  TO authenticated
  USING (
    is_active = true AND (
      access_roles = '[]'::jsonb OR
      EXISTS (
        SELECT 1 FROM user_roles ur
        JOIN users u ON ur.user_id = u.id
        WHERE u.auth_user_id = auth.uid()
        AND ur.role::text = ANY(SELECT jsonb_array_elements_text(access_roles))
      )
    )
  );

CREATE POLICY "Admins and QA can manage content"
  ON uploaded_contents
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

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_user_module_progress_user_id ON user_module_progress(user_id);
CREATE INDEX IF NOT EXISTS idx_user_module_progress_module_id ON user_module_progress(module_id);
CREATE INDEX IF NOT EXISTS idx_user_lesson_progress_user_id ON user_lesson_progress(user_id);
CREATE INDEX IF NOT EXISTS idx_user_lesson_progress_lesson_id ON user_lesson_progress(lesson_id);
CREATE INDEX IF NOT EXISTS idx_uploaded_contents_module_id ON uploaded_contents(module_id);
CREATE INDEX IF NOT EXISTS idx_uploaded_contents_uploaded_by ON uploaded_contents(uploaded_by_id);
CREATE INDEX IF NOT EXISTS idx_uploaded_contents_active ON uploaded_contents(is_active);

-- Create triggers for updated_at
CREATE TRIGGER update_user_module_progress_updated_at
  BEFORE UPDATE ON user_module_progress
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_uploaded_contents_updated_at
  BEFORE UPDATE ON uploaded_contents
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Create function to calculate module progress
CREATE OR REPLACE FUNCTION calculate_module_progress(p_user_id uuid, p_module_id uuid)
RETURNS integer AS $$
DECLARE
  total_lessons integer;
  completed_lessons integer;
  progress_percentage integer;
BEGIN
  -- Get total lessons in the module
  SELECT COUNT(*)
  INTO total_lessons
  FROM lessons l
  JOIN sections s ON l.section_id = s.id
  WHERE s.module_id = p_module_id AND l.is_active = true;
  
  -- Get completed lessons by user
  SELECT COUNT(*)
  INTO completed_lessons
  FROM user_lesson_progress ulp
  JOIN lessons l ON ulp.lesson_id = l.id
  JOIN sections s ON l.section_id = s.id
  WHERE s.module_id = p_module_id 
    AND ulp.user_id = p_user_id 
    AND ulp.is_completed = true;
  
  -- Calculate percentage
  IF total_lessons = 0 THEN
    progress_percentage := 0;
  ELSE
    progress_percentage := ROUND((completed_lessons::decimal / total_lessons::decimal) * 100);
  END IF;
  
  -- Update or insert progress record
  INSERT INTO user_module_progress (user_id, module_id, completion_percentage, is_completed)
  VALUES (p_user_id, p_module_id, progress_percentage, progress_percentage = 100)
  ON CONFLICT (user_id, module_id)
  DO UPDATE SET
    completion_percentage = EXCLUDED.completion_percentage,
    is_completed = EXCLUDED.is_completed,
    completed_at = CASE WHEN EXCLUDED.is_completed THEN now() ELSE NULL END,
    updated_at = now();
  
  RETURN progress_percentage;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create function to update module progress when lesson is completed
CREATE OR REPLACE FUNCTION update_module_progress_on_lesson_completion()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.is_completed = true AND (OLD.is_completed IS NULL OR OLD.is_completed = false) THEN
    -- Get the module_id for this lesson
    PERFORM calculate_module_progress(
      NEW.user_id,
      (SELECT s.module_id FROM sections s JOIN lessons l ON s.id = l.section_id WHERE l.id = NEW.lesson_id)
    );
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create trigger for automatic module progress calculation
CREATE TRIGGER update_module_progress_on_lesson_completion_trigger
  AFTER INSERT OR UPDATE ON user_lesson_progress
  FOR EACH ROW EXECUTE FUNCTION update_module_progress_on_lesson_completion();