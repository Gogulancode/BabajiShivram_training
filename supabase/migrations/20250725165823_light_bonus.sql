/*
  # Create Modules and Content System

  1. New Tables
    - `modules`
      - `id` (uuid, primary key)
      - `title` (text)
      - `description` (text)
      - `icon` (text)
      - `category` (text)
      - `color` (text)
      - `estimated_time` (text)
      - `difficulty` (text)
      - `prerequisites` (jsonb array)
      - `learning_objectives` (jsonb array)
      - `is_active` (boolean)
      - `order_index` (integer)
      - `created_at` (timestamp)
      - `updated_at` (timestamp)
    
    - `sections`
      - `id` (uuid, primary key)
      - `module_id` (uuid, foreign key)
      - `title` (text)
      - `description` (text)
      - `order_index` (integer)
      - `is_active` (boolean)
      - `created_at` (timestamp)
      - `updated_at` (timestamp)
    
    - `lessons`
      - `id` (uuid, primary key)
      - `section_id` (uuid, foreign key)
      - `title` (text)
      - `description` (text)
      - `type` (text)
      - `duration` (text)
      - `order_index` (integer)
      - `is_active` (boolean)
      - `video_url` (text, optional)
      - `document_content` (text, optional)
      - `scribe_link` (text, optional)
      - `interactive_steps` (jsonb array)
      - `has_assessment` (boolean)
      - `created_at` (timestamp)
      - `updated_at` (timestamp)

  2. Security
    - Enable RLS on all tables
    - Add policies for different user roles
*/

-- Create modules table
CREATE TABLE IF NOT EXISTS modules (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  title text NOT NULL,
  description text NOT NULL DEFAULT '',
  icon text NOT NULL DEFAULT 'BookOpen',
  category text NOT NULL DEFAULT '',
  color text NOT NULL DEFAULT 'blue',
  estimated_time text NOT NULL DEFAULT '',
  difficulty text NOT NULL DEFAULT 'Beginner' CHECK (difficulty IN ('Beginner', 'Intermediate', 'Advanced')),
  prerequisites jsonb DEFAULT '[]'::jsonb,
  learning_objectives jsonb DEFAULT '[]'::jsonb,
  is_active boolean DEFAULT true,
  order_index integer DEFAULT 0,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create sections table
CREATE TABLE IF NOT EXISTS sections (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  module_id uuid REFERENCES modules(id) ON DELETE CASCADE,
  title text NOT NULL,
  description text NOT NULL DEFAULT '',
  order_index integer DEFAULT 0,
  is_active boolean DEFAULT true,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create lessons table
CREATE TABLE IF NOT EXISTS lessons (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  section_id uuid REFERENCES sections(id) ON DELETE CASCADE,
  title text NOT NULL,
  description text NOT NULL DEFAULT '',
  type text NOT NULL DEFAULT 'document' CHECK (type IN ('video', 'document', 'interactive', 'quiz')),
  duration text NOT NULL DEFAULT '',
  order_index integer DEFAULT 0,
  is_active boolean DEFAULT true,
  video_url text,
  document_content text,
  scribe_link text,
  interactive_steps jsonb DEFAULT '[]'::jsonb,
  has_assessment boolean DEFAULT false,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Enable RLS
ALTER TABLE modules ENABLE ROW LEVEL SECURITY;
ALTER TABLE sections ENABLE ROW LEVEL SECURITY;
ALTER TABLE lessons ENABLE ROW LEVEL SECURITY;

-- Create policies for modules
CREATE POLICY "Anyone can read active modules"
  ON modules
  FOR SELECT
  TO authenticated
  USING (is_active = true);

CREATE POLICY "Admins and QA can manage modules"
  ON modules
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

-- Create policies for sections
CREATE POLICY "Anyone can read active sections"
  ON sections
  FOR SELECT
  TO authenticated
  USING (is_active = true);

CREATE POLICY "Admins and QA can manage sections"
  ON sections
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

-- Create policies for lessons
CREATE POLICY "Anyone can read active lessons"
  ON lessons
  FOR SELECT
  TO authenticated
  USING (is_active = true);

CREATE POLICY "Admins and QA can manage lessons"
  ON lessons
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
CREATE INDEX IF NOT EXISTS idx_modules_order ON modules(order_index);
CREATE INDEX IF NOT EXISTS idx_modules_active ON modules(is_active);
CREATE INDEX IF NOT EXISTS idx_sections_module_id ON sections(module_id);
CREATE INDEX IF NOT EXISTS idx_sections_order ON sections(module_id, order_index);
CREATE INDEX IF NOT EXISTS idx_lessons_section_id ON lessons(section_id);
CREATE INDEX IF NOT EXISTS idx_lessons_order ON lessons(section_id, order_index);

-- Create function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create triggers for updated_at
CREATE TRIGGER update_modules_updated_at
  BEFORE UPDATE ON modules
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_sections_updated_at
  BEFORE UPDATE ON sections
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_lessons_updated_at
  BEFORE UPDATE ON lessons
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();