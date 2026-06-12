CREATE TABLE IF NOT EXISTS users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email VARCHAR(255) UNIQUE NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  role VARCHAR(20) CHECK (role IN ('student','teacher','admin')),
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS results (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  student_id UUID REFERENCES users(id),
  course_name VARCHAR(255) NOT NULL,
  grade DECIMAL(3,2) CHECK (grade >= 0 AND grade <= 4.0),
  semester VARCHAR(50),
  gpa DECIMAL(3,2),
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS course_assignments (
  teacher_id UUID REFERENCES users(id),
  course_id UUID,
  student_id UUID REFERENCES users(id),
  PRIMARY KEY (teacher_id, course_id, student_id)
);

CREATE TABLE IF NOT EXISTS grade_submissions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  student_id UUID REFERENCES users(id),
  course_id UUID,
  teacher_id UUID REFERENCES users(id),
  grade DECIMAL(3,2),
  status VARCHAR(20) DEFAULT 'pending',
  approved_by UUID,
  approved_at TIMESTAMP,
  created_at TIMESTAMP DEFAULT NOW()
);

GRANT SELECT, INSERT, UPDATE, DELETE
  ON ALL TABLES IN SCHEMA public
  TO auth_service_user;

GRANT USAGE, SELECT
  ON ALL SEQUENCES IN SCHEMA public
  TO auth_service_user;
