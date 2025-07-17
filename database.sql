--
-- PostgreSQL Database for the SERAC (Security and Role Access Control)
-- Privilege-based RBAC Dashboard Schema
--
-- Author: Nishant <nishujangra@zohomail.in> or <ndjangra1027@gmail.com>
-- Created: 2024
-- Description: Database schema for a comprehensive Role-Based Access Control system
--              with privilege management and user access control
--

-- Connect to the serac database
\c serac

-- =============================================================================
-- DROP EXISTING TABLES (in reverse dependency order)
-- =============================================================================
\echo ** DROPPING EXISTING TABLES (if any) **

-- Drop tables in reverse dependency order to avoid foreign key constraint issues
DROP TABLE IF EXISTS Access CASCADE;
DROP TABLE IF EXISTS Privilege CASCADE;
DROP TABLE IF EXISTS PrivilegeCategory CASCADE;
DROP TABLE IF EXISTS Roles CASCADE;
DROP TABLE IF EXISTS Users CASCADE;
DROP TABLE IF EXISTS Applications CASCADE;

-- =============================================================================
-- CREATE TABLES
-- =============================================================================
\echo ** CREATING TABLES **

-- =============================================================================
-- CORE RBAC TABLES
-- =============================================================================

-- Roles table: Defines different roles in the system with hierarchical levels
-- Higher level numbers indicate higher privileges
CREATE TABLE Roles (
    role            CHAR(16) NOT NULL,
    level           SMALLINT NOT NULL CHECK (level >= 0),
    description     TEXT,
    PRIMARY KEY (role)
);

-- Add comment to Roles table
COMMENT ON TABLE Roles IS 'Defines system roles with hierarchical privilege levels';
COMMENT ON COLUMN Roles.role IS 'Unique role identifier (e.g., ADMIN, USER, GUEST)';
COMMENT ON COLUMN Roles.level IS 'Hierarchical level - higher numbers indicate more privileges';
COMMENT ON COLUMN Roles.description IS 'Human-readable description of the role';

-- PrivilegeCategory table: Categorizes privileges for better organization
-- Examples: READ, WRITE, DELETE, ADMIN, etc.
CREATE TABLE PrivilegeCategory (
    category        CHAR(10) NOT NULL,
    description     TEXT,
    PRIMARY KEY (category)
);

-- Add comment to PrivilegeCategory table
COMMENT ON TABLE PrivilegeCategory IS 'Categories for organizing privileges (e.g., READ, WRITE, ADMIN)';
COMMENT ON COLUMN PrivilegeCategory.category IS 'Category identifier (e.g., READ, WRITE, DELETE)';
COMMENT ON COLUMN PrivilegeCategory.description IS 'Description of the privilege category';

-- Privilege table: Defines specific privileges that can be assigned to roles
-- Each privilege belongs to a category and can be associated with specific applications
CREATE TABLE Privilege (
    privilege       TEXT NOT NULL,
    category        CHAR(10) NOT NULL,
    description     TEXT,
    type            CHAR(16), -- e.g., 'URL', 'FUNCTION', 'RESOURCE'
    appid           CHAR(16), -- Application identifier
    PRIMARY KEY (privilege)
);

-- Add comment to Privilege table
COMMENT ON TABLE Privilege IS 'Defines specific privileges that can be assigned to roles';
COMMENT ON COLUMN Privilege.privilege IS 'Unique privilege identifier (e.g., URL path, function name)';
COMMENT ON COLUMN Privilege.category IS 'Category this privilege belongs to';
COMMENT ON COLUMN Privilege.type IS 'Type of privilege (URL, FUNCTION, RESOURCE, etc.)';
COMMENT ON COLUMN Privilege.appid IS 'Application identifier this privilege belongs to';

-- Access table: Junction table that maps privileges to roles
-- This defines which roles have access to which privileges
CREATE TABLE Access
(
    privilege   TEXT,
    role        CHAR(16),
    PRIMARY KEY (privilege, role),
    FOREIGN KEY (privilege) REFERENCES Privilege (privilege) ON UPDATE CASCADE
);

-- Add comment to Access table
COMMENT ON TABLE Access IS 'Maps privileges to roles - defines role-based access control';
COMMENT ON COLUMN Access.privilege IS 'Privilege identifier';
COMMENT ON COLUMN Access.role IS 'Role identifier';

-- =============================================================================
-- SUPPORTING TABLES
-- =============================================================================

-- Users table: Stores user information
CREATE TABLE Users (
    user_id         UUID PRIMARY KEY DEFAULT uuid_generate_v4(), -- https://www.postgresql.org/docs/current/functions-uuid.html
    username        VARCHAR(50) UNIQUE NOT NULL,
    email           VARCHAR(255) UNIQUE NOT NULL,
    password_hash   VARCHAR(255) NOT NULL,
    first_name      VARCHAR(100),
    last_name       VARCHAR(100),
    is_active       BOOLEAN DEFAULT TRUE,
    role            CHAR(16) REFERENCES Roles ON UPDATE CASCADE,
    created_at      TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Add comment to Users table
COMMENT ON TABLE Users IS 'Stores user account information';
COMMENT ON COLUMN Users.user_id IS 'Unique user identifier';
COMMENT ON COLUMN Users.username IS 'Unique username for login';
COMMENT ON COLUMN Users.email IS 'User email address';
COMMENT ON COLUMN Users.password_hash IS 'Hashed password for security';
COMMENT ON COLUMN Users.is_active IS 'Whether the user account is active';

-- Applications table: Stores information about applications in the system
CREATE TABLE Applications (
    appid           CHAR(16) PRIMARY KEY,
    name            VARCHAR(100) NOT NULL,
    description     TEXT,
    version         VARCHAR(20),
    is_active       BOOLEAN DEFAULT TRUE,
    created_at      TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Add comment to Applications table
COMMENT ON TABLE Applications IS 'Stores information about applications in the system';
COMMENT ON COLUMN Applications.appid IS 'Unique application identifier';
COMMENT ON COLUMN Applications.name IS 'Application name';
COMMENT ON COLUMN Applications.description IS 'Application description';
COMMENT ON COLUMN Applications.version IS 'Application version';
COMMENT ON COLUMN Applications.is_active IS 'Whether the application is active';

-- =============================================================================
-- INDEXES FOR PERFORMANCE
-- =============================================================================
\echo ** CREATING INDEXES **

-- Indexes for better query performance
CREATE INDEX idx_roles_level ON Roles(level);
CREATE INDEX idx_privilege_category ON Privilege(category);
CREATE INDEX idx_privilege_appid ON Privilege(appid);
CREATE INDEX idx_access_role ON Access(role);
CREATE INDEX idx_users_username ON Users(username);
CREATE INDEX idx_users_email ON Users(email);
CREATE INDEX idx_users_active ON Users(is_active);

-- =============================================================================
-- TRIGGERS FOR UPDATED_AT TIMESTAMPS
-- =============================================================================
\echo ** CREATING TRIGGERS **

-- Function to update the updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create triggers for updated_at columns
CREATE TRIGGER update_roles_updated_at BEFORE UPDATE ON Roles
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_privilege_updated_at BEFORE UPDATE ON Privilege
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON Users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_applications_updated_at BEFORE UPDATE ON Applications
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();