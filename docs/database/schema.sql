-- AI Productivity Master Database Schema
-- PostgreSQL Database Schema for Team and Task Management System

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Users table
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    name VARCHAR(255) NOT NULL,
    avatar VARCHAR(500),
    firebase_uid VARCHAR(255) UNIQUE,
    preferences JSONB DEFAULT '{}',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Teams table
CREATE TABLE teams (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    created_by UUID REFERENCES users(id),
    settings JSONB DEFAULT '{"visibility": "private", "allowGuestInvites": false}',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Team members junction table
CREATE TABLE team_members (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    team_id UUID REFERENCES teams(id) ON DELETE CASCADE,
    role VARCHAR(50) DEFAULT 'member' CHECK (role IN ('owner', 'admin', 'member')),
    permissions JSONB DEFAULT '{"canCreateTasks": true, "canAssignTasks": false, "canDeleteTasks": false}',
    joined_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, team_id)
);

-- Tasks table
CREATE TABLE tasks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title VARCHAR(255) NOT NULL,
    description TEXT,
    team_id UUID REFERENCES teams(id) ON DELETE CASCADE,
    assigned_to UUID REFERENCES users(id),
    created_by UUID REFERENCES users(id),
    priority VARCHAR(20) DEFAULT 'medium' CHECK (priority IN ('low', 'medium', 'high', 'urgent')),
    status VARCHAR(20) DEFAULT 'todo' CHECK (status IN ('todo', 'in_progress', 'review', 'done', 'cancelled')),
    due_date TIMESTAMP,
    estimated_hours INTEGER,
    actual_hours INTEGER,
    tags TEXT[] DEFAULT '{}',
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Comments table
CREATE TABLE comments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    task_id UUID REFERENCES tasks(id) ON DELETE CASCADE,
    user_id UUID REFERENCES users(id),
    content TEXT NOT NULL,
    is_edited BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Team invitations table
CREATE TABLE team_invitations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    team_id UUID REFERENCES teams(id) ON DELETE CASCADE,
    email VARCHAR(255) NOT NULL,
    invited_by UUID REFERENCES users(id),
    token VARCHAR(255) UNIQUE NOT NULL,
    role VARCHAR(50) DEFAULT 'member' CHECK (role IN ('admin', 'member')),
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'accepted', 'declined', 'expired')),
    expires_at TIMESTAMP NOT NULL,
    accepted_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Activity feed table
CREATE TABLE activities (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    team_id UUID REFERENCES teams(id) ON DELETE CASCADE,
    user_id UUID REFERENCES users(id),
    action VARCHAR(100) NOT NULL,
    entity_type VARCHAR(50) NOT NULL CHECK (entity_type IN ('task', 'team', 'user', 'comment')),
    entity_id UUID NOT NULL,
    details JSONB DEFAULT '{}',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Task dependencies table (for task relationships)
CREATE TABLE task_dependencies (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    task_id UUID REFERENCES tasks(id) ON DELETE CASCADE,
    depends_on_task_id UUID REFERENCES tasks(id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(task_id, depends_on_task_id),
    CHECK (task_id != depends_on_task_id)
);

-- File attachments table
CREATE TABLE attachments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    task_id UUID REFERENCES tasks(id) ON DELETE CASCADE,
    user_id UUID REFERENCES users(id),
    filename VARCHAR(255) NOT NULL,
    file_url VARCHAR(500) NOT NULL,
    file_size INTEGER,
    mime_type VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Task time tracking table
CREATE TABLE time_entries (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    task_id UUID REFERENCES tasks(id) ON DELETE CASCADE,
    user_id UUID REFERENCES users(id),
    description TEXT,
    hours_worked DECIMAL(5,2) NOT NULL,
    start_time TIMESTAMP,
    end_time TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Performance indexes
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_firebase_uid ON users(firebase_uid);
CREATE INDEX idx_teams_created_by ON teams(created_by);
CREATE INDEX idx_team_members_user_id ON team_members(user_id);
CREATE INDEX idx_team_members_team_id ON team_members(team_id);
CREATE INDEX idx_team_members_role ON team_members(role);
CREATE INDEX idx_tasks_team_id ON tasks(team_id);
CREATE INDEX idx_tasks_assigned_to ON tasks(assigned_to);
CREATE INDEX idx_tasks_created_by ON tasks(created_by);
CREATE INDEX idx_tasks_status ON tasks(status);
CREATE INDEX idx_tasks_priority ON tasks(priority);
CREATE INDEX idx_tasks_due_date ON tasks(due_date);
CREATE INDEX idx_tasks_created_at ON tasks(created_at);
CREATE INDEX idx_comments_task_id ON comments(task_id);
CREATE INDEX idx_comments_user_id ON comments(user_id);
CREATE INDEX idx_activities_team_id ON activities(team_id);
CREATE INDEX idx_activities_user_id ON activities(user_id);
CREATE INDEX idx_activities_created_at ON activities(created_at);
CREATE INDEX idx_team_invitations_token ON team_invitations(token);
CREATE INDEX idx_team_invitations_email ON team_invitations(email);
CREATE INDEX idx_team_invitations_status ON team_invitations(status);
CREATE INDEX idx_task_dependencies_task_id ON task_dependencies(task_id);
CREATE INDEX idx_task_dependencies_depends_on ON task_dependencies(depends_on_task_id);
CREATE INDEX idx_attachments_task_id ON attachments(task_id);
CREATE INDEX idx_time_entries_task_id ON time_entries(task_id);
CREATE INDEX idx_time_entries_user_id ON time_entries(user_id);

-- Composite indexes for common queries
CREATE INDEX idx_tasks_team_status ON tasks(team_id, status);
CREATE INDEX idx_tasks_assigned_status ON tasks(assigned_to, status);
CREATE INDEX idx_team_members_team_role ON team_members(team_id, role);

-- Triggers for updated_at timestamps
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_teams_updated_at BEFORE UPDATE ON teams
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_tasks_updated_at BEFORE UPDATE ON tasks
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_comments_updated_at BEFORE UPDATE ON comments
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Views for common queries
CREATE VIEW team_task_summary AS
SELECT 
    t.id as team_id,
    t.name as team_name,
    COUNT(CASE WHEN ta.status = 'todo' THEN 1 END) as todo_count,
    COUNT(CASE WHEN ta.status = 'in_progress' THEN 1 END) as in_progress_count,
    COUNT(CASE WHEN ta.status = 'review' THEN 1 END) as review_count,
    COUNT(CASE WHEN ta.status = 'done' THEN 1 END) as done_count,
    COUNT(ta.id) as total_tasks
FROM teams t
LEFT JOIN tasks ta ON t.id = ta.team_id
GROUP BY t.id, t.name;

CREATE VIEW user_task_workload AS
SELECT 
    u.id as user_id,
    u.name as user_name,
    u.email,
    COUNT(CASE WHEN t.status IN ('todo', 'in_progress', 'review') THEN 1 END) as active_tasks,
    COUNT(CASE WHEN t.status = 'done' THEN 1 END) as completed_tasks,
    AVG(CASE WHEN t.status = 'done' AND t.estimated_hours IS NOT NULL 
        THEN t.actual_hours::FLOAT / t.estimated_hours END) as avg_estimation_accuracy
FROM users u
LEFT JOIN tasks t ON u.id = t.assigned_to
GROUP BY u.id, u.name, u.email;

-- Sample data (optional - for development)
-- INSERT INTO users (email, name, firebase_uid) VALUES 
-- ('admin@example.com', 'Admin User', 'firebase_admin_uid'),
-- ('user1@example.com', 'John Doe', 'firebase_user1_uid'),
-- ('user2@example.com', 'Jane Smith', 'firebase_user2_uid');

-- Security: Row Level Security (RLS) policies
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE teams ENABLE ROW LEVEL SECURITY;
ALTER TABLE team_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE tasks ENABLE ROW LEVEL SECURITY;
ALTER TABLE comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE activities ENABLE ROW LEVEL SECURITY;

-- Example RLS policies (should be customized based on your auth system)
-- Users can only see their own data
CREATE POLICY users_policy ON users FOR ALL TO authenticated_user USING (id = current_user_id());

-- Team members can see team data they belong to
CREATE POLICY teams_policy ON teams FOR ALL TO authenticated_user 
USING (id IN (SELECT team_id FROM team_members WHERE user_id = current_user_id()));

-- Note: Implement current_user_id() function based on your authentication system