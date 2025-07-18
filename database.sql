--
-- PostgreSQL Database for SERAC (Security and Role Access Control)
-- Startup Internal Dashboard Schema
--
-- Author: Nishant <nishujangra@zohomail.in> or <ndjangra1027@gmail.com>
-- Created: 2024
-- Description: Database schema for a startup internal dashboard with RBAC
--              Focused on practical startup operations and team management
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

-- Roles table: Defines team roles in the startup
-- Simplified hierarchy focused on startup operations
CREATE TABLE Roles (
    role            CHAR(20) NOT NULL,
    level           SMALLINT NOT NULL CHECK (level >= 0),
    description     TEXT,
    PRIMARY KEY (role)
);

-- Add comment to Roles table
COMMENT ON TABLE Roles IS 'Defines team roles for startup internal operations';
COMMENT ON COLUMN Roles.role IS 'Unique role identifier (e.g., ADMIN, DEVELOPER, SUPPORT)';
COMMENT ON COLUMN Roles.level IS 'Hierarchical level - higher numbers indicate more privileges';
COMMENT ON COLUMN Roles.description IS 'Human-readable description of the role';

-- PrivilegeCategory table: Simplified categories for startup operations
CREATE TABLE PrivilegeCategory (
    category        CHAR(10) NOT NULL,
    description     TEXT,
    PRIMARY KEY (category)
);

-- Add comment to PrivilegeCategory table
COMMENT ON TABLE PrivilegeCategory IS 'Categories for organizing privileges in startup context';
COMMENT ON COLUMN PrivilegeCategory.category IS 'Category identifier (e.g., READ, WRITE, MANAGE)';
COMMENT ON COLUMN PrivilegeCategory.description IS 'Description of the privilege category';

-- Privilege table: Defines specific privileges for startup dashboard modules
CREATE TABLE Privilege (
    privilege       TEXT NOT NULL,
    category        CHAR(10) NOT NULL,
    description     TEXT,
    type            CHAR(16), -- e.g., 'URL', 'FUNCTION', 'RESOURCE'
    appid           CHAR(16), -- Application identifier
    PRIMARY KEY (privilege)
);

-- Add comment to Privilege table
COMMENT ON TABLE Privilege IS 'Defines specific privileges for startup dashboard modules';
COMMENT ON COLUMN Privilege.privilege IS 'Unique privilege identifier (e.g., URL path, function name)';
COMMENT ON COLUMN Privilege.category IS 'Category this privilege belongs to';
COMMENT ON COLUMN Privilege.type IS 'Type of privilege (URL, FUNCTION, RESOURCE, etc.)';
COMMENT ON COLUMN Privilege.appid IS 'Application identifier this privilege belongs to';

-- Access table: Maps privileges to roles for RBAC enforcement
CREATE TABLE Access
(
    privilege   TEXT,
    role        CHAR(20),
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

-- Users table: Stores team member information
CREATE TABLE Users (
    user_id         UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    username        VARCHAR(50) UNIQUE NOT NULL,
    email           VARCHAR(255) UNIQUE NOT NULL,
    password_hash   VARCHAR(255) NOT NULL,
    first_name      VARCHAR(100),
    last_name       VARCHAR(100),
    is_active       BOOLEAN DEFAULT TRUE,
    role            CHAR(20) REFERENCES Roles ON UPDATE CASCADE,
    department      VARCHAR(100), -- e.g., 'Engineering', 'Support', 'Finance'
    created_at      TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Add comment to Users table
COMMENT ON TABLE Users IS 'Stores team member account information';
COMMENT ON COLUMN Users.user_id IS 'Unique user identifier';
COMMENT ON COLUMN Users.username IS 'Unique username for login';
COMMENT ON COLUMN Users.email IS 'User email address';
COMMENT ON COLUMN Users.password_hash IS 'Hashed password for security';
COMMENT ON COLUMN Users.is_active IS 'Whether the user account is active';
COMMENT ON COLUMN Users.department IS 'Department or team the user belongs to';

-- Applications table: Stores information about dashboard modules
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
COMMENT ON TABLE Applications IS 'Stores information about dashboard modules';
COMMENT ON COLUMN Applications.appid IS 'Unique application identifier';
COMMENT ON COLUMN Applications.name IS 'Application name';
COMMENT ON COLUMN Applications.description IS 'Application description';
COMMENT ON COLUMN Applications.version IS 'Application version';
COMMENT ON COLUMN Applications.is_active IS 'Whether the application is active';






-- =============================================================================
-- STARTUP OPERATIONAL TABLES
-- =============================================================================

-- Projects table: Internal project management
CREATE TABLE Projects (
    project_id      UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name            VARCHAR(200) NOT NULL,
    description     TEXT,
    status          VARCHAR(20) DEFAULT 'ACTIVE' CHECK (status IN ('ACTIVE', 'PAUSED', 'COMPLETED', 'CANCELLED')),
    priority        VARCHAR(20) DEFAULT 'MEDIUM' CHECK (priority IN ('LOW', 'MEDIUM', 'HIGH', 'URGENT')),
    owner_id        UUID REFERENCES Users(user_id) ON DELETE SET NULL,
    team_lead_id    UUID REFERENCES Users(user_id) ON DELETE SET NULL,
    start_date      DATE,
    end_date        DATE,
    budget          DECIMAL(12,2),
    is_active       BOOLEAN DEFAULT TRUE,
    created_at      TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Add comment to Projects table
COMMENT ON TABLE Projects IS 'Internal project management for startup operations';
COMMENT ON COLUMN Projects.project_id IS 'Unique project identifier';
COMMENT ON COLUMN Projects.name IS 'Project name';
COMMENT ON COLUMN Projects.status IS 'Current project status';
COMMENT ON COLUMN Projects.priority IS 'Project priority level';
COMMENT ON COLUMN Projects.owner_id IS 'Project owner/manager';
COMMENT ON COLUMN Projects.team_lead_id IS 'Technical team lead';
COMMENT ON COLUMN Projects.budget IS 'Project budget in dollars';

-- Project API Keys table: API key management for projects
CREATE TABLE ProjectApiKeys (
    key_id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    project_id      UUID NOT NULL REFERENCES Projects(project_id) ON DELETE CASCADE,
    name            VARCHAR(100) NOT NULL,
    api_key         VARCHAR(255) UNIQUE NOT NULL,
    permissions     TEXT[], -- Array of allowed permissions
    is_active       BOOLEAN DEFAULT TRUE,
    expires_at      TIMESTAMP WITH TIME ZONE,
    last_used_at    TIMESTAMP WITH TIME ZONE,
    created_by      UUID REFERENCES Users(user_id) ON DELETE SET NULL,
    created_at      TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Add comment to ProjectApiKeys table
COMMENT ON TABLE ProjectApiKeys IS 'API key management for project integrations';
COMMENT ON COLUMN ProjectApiKeys.key_id IS 'Unique API key identifier';
COMMENT ON COLUMN ProjectApiKeys.project_id IS 'Project this API key belongs to';
COMMENT ON COLUMN ProjectApiKeys.name IS 'Human-readable name for the API key';
COMMENT ON COLUMN ProjectApiKeys.api_key IS 'The actual API key value';
COMMENT ON COLUMN ProjectApiKeys.permissions IS 'Array of permissions granted to this key';
COMMENT ON COLUMN ProjectApiKeys.expires_at IS 'When the API key expires';

-- Tickets table: Support ticket management
CREATE TABLE Tickets (
    ticket_id       UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title           VARCHAR(200) NOT NULL,
    description     TEXT NOT NULL,
    status          VARCHAR(20) DEFAULT 'OPEN' CHECK (status IN ('OPEN', 'IN_PROGRESS', 'RESOLVED', 'CLOSED')),
    priority        VARCHAR(20) DEFAULT 'MEDIUM' CHECK (priority IN ('LOW', 'MEDIUM', 'HIGH', 'URGENT')),
    category        VARCHAR(50), -- e.g., 'Technical', 'Billing', 'Feature Request'
    assigned_to     UUID REFERENCES Users(user_id) ON DELETE SET NULL,
    created_by      UUID NOT NULL REFERENCES Users(user_id) ON DELETE CASCADE,
    customer_email  VARCHAR(255),
    customer_name   VARCHAR(200),
    resolution      TEXT,
    resolved_at     TIMESTAMP WITH TIME ZONE,
    created_at      TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Add comment to Tickets table
COMMENT ON TABLE Tickets IS 'Support ticket management system';
COMMENT ON COLUMN Tickets.ticket_id IS 'Unique ticket identifier';
COMMENT ON COLUMN Tickets.title IS 'Ticket title/summary';
COMMENT ON COLUMN Tickets.status IS 'Current ticket status';
COMMENT ON COLUMN Tickets.priority IS 'Ticket priority level';
COMMENT ON COLUMN Tickets.category IS 'Ticket category for organization';
COMMENT ON COLUMN Tickets.assigned_to IS 'User assigned to handle the ticket';
COMMENT ON COLUMN Tickets.created_by IS 'User who created the ticket';
COMMENT ON COLUMN Tickets.customer_email IS 'Customer email for external tickets';
COMMENT ON COLUMN Tickets.resolution IS 'Resolution notes when ticket is closed';

-- Ticket Comments table: Comments on tickets
CREATE TABLE TicketComments (
    comment_id      UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    ticket_id       UUID NOT NULL REFERENCES Tickets(ticket_id) ON DELETE CASCADE,
    user_id         UUID NOT NULL REFERENCES Users(user_id) ON DELETE CASCADE,
    comment         TEXT NOT NULL,
    is_internal     BOOLEAN DEFAULT FALSE, -- Internal notes vs customer-visible
    created_at      TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Add comment to TicketComments table
COMMENT ON TABLE TicketComments IS 'Comments and updates on support tickets';
COMMENT ON COLUMN TicketComments.comment_id IS 'Unique comment identifier';
COMMENT ON COLUMN TicketComments.ticket_id IS 'Ticket this comment belongs to';
COMMENT ON COLUMN TicketComments.user_id IS 'User who made the comment';
COMMENT ON COLUMN TicketComments.is_internal IS 'Whether this is an internal note';

-- Billing table: Billing and subscription management
CREATE TABLE Billing (
    billing_id      UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    customer_id     VARCHAR(100), -- External customer identifier
    customer_email  VARCHAR(255),
    customer_name   VARCHAR(200),
    plan_name       VARCHAR(100) NOT NULL,
    plan_type       VARCHAR(20) DEFAULT 'SUBSCRIPTION' CHECK (plan_type IN ('SUBSCRIPTION', 'ONE_TIME', 'USAGE_BASED')),
    amount          DECIMAL(10,2) NOT NULL,
    currency        VARCHAR(3) DEFAULT 'USD',
    status          VARCHAR(20) DEFAULT 'PENDING' CHECK (status IN ('PENDING', 'PAID', 'FAILED', 'REFUNDED', 'CANCELLED')),
    billing_cycle   VARCHAR(20), -- e.g., 'MONTHLY', 'YEARLY', 'ONE_TIME'
    due_date        DATE,
    paid_at         TIMESTAMP WITH TIME ZONE,
    invoice_url     VARCHAR(500),
    notes           TEXT,
    created_at      TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Add comment to Billing table
COMMENT ON TABLE Billing IS 'Billing and subscription management';
COMMENT ON COLUMN Billing.billing_id IS 'Unique billing record identifier';
COMMENT ON COLUMN Billing.customer_id IS 'External customer identifier';
COMMENT ON COLUMN Billing.plan_name IS 'Name of the billing plan';
COMMENT ON COLUMN Billing.plan_type IS 'Type of billing plan';
COMMENT ON COLUMN Billing.amount IS 'Billing amount';
COMMENT ON COLUMN Billing.status IS 'Payment status';
COMMENT ON COLUMN Billing.billing_cycle IS 'Billing frequency';
COMMENT ON COLUMN Billing.due_date IS 'When payment is due';
COMMENT ON COLUMN Billing.paid_at IS 'When payment was received';

-- System Logs table: Application and system logs
CREATE TABLE SystemLogs (
    log_id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    level           VARCHAR(10) NOT NULL CHECK (level IN ('DEBUG', 'INFO', 'WARN', 'ERROR', 'FATAL')),
    category        VARCHAR(50) NOT NULL, -- e.g., 'AUTH', 'API', 'SYSTEM', 'SECURITY'
    message         TEXT NOT NULL,
    details         JSONB, -- Additional structured data
    user_id         UUID REFERENCES Users(user_id) ON DELETE SET NULL,
    ip_address      INET,
    user_agent      TEXT,
    request_id      VARCHAR(100), -- For tracking request flows
    created_at      TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Add comment to SystemLogs table
COMMENT ON TABLE SystemLogs IS 'System and application logs for monitoring and debugging';
COMMENT ON COLUMN SystemLogs.log_id IS 'Unique log entry identifier';
COMMENT ON COLUMN SystemLogs.level IS 'Log level (DEBUG, INFO, WARN, ERROR, FATAL)';
COMMENT ON COLUMN SystemLogs.category IS 'Log category for filtering';
COMMENT ON COLUMN SystemLogs.message IS 'Log message';
COMMENT ON COLUMN SystemLogs.details IS 'Additional structured data in JSON format';
COMMENT ON COLUMN SystemLogs.user_id IS 'User associated with this log entry';
COMMENT ON COLUMN SystemLogs.ip_address IS 'IP address of the request';
COMMENT ON COLUMN SystemLogs.request_id IS 'Request identifier for tracing';

-- Audit Logs table: Security and compliance audit logs
CREATE TABLE AuditLogs (
    audit_id        UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    action          VARCHAR(50) NOT NULL, -- e.g., 'LOGIN', 'LOGOUT', 'CREATE', 'UPDATE', 'DELETE'
    resource_type   VARCHAR(50), -- e.g., 'USER', 'PROJECT', 'TICKET', 'BILLING'
    resource_id     VARCHAR(100), -- ID of the affected resource
    user_id         UUID REFERENCES Users(user_id) ON DELETE SET NULL,
    ip_address      INET,
    user_agent      TEXT,
    old_values      JSONB, -- Previous values before change
    new_values      JSONB, -- New values after change
    success         BOOLEAN DEFAULT TRUE,
    error_message   TEXT,
    created_at      TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Add comment to AuditLogs table
COMMENT ON TABLE AuditLogs IS 'Security and compliance audit logs';
COMMENT ON COLUMN AuditLogs.audit_id IS 'Unique audit log identifier';
COMMENT ON COLUMN AuditLogs.action IS 'Action performed';
COMMENT ON COLUMN AuditLogs.resource_type IS 'Type of resource affected';
COMMENT ON COLUMN AuditLogs.resource_id IS 'ID of the affected resource';
COMMENT ON COLUMN AuditLogs.user_id IS 'User who performed the action';
COMMENT ON COLUMN AuditLogs.old_values IS 'Previous values before change';
COMMENT ON COLUMN AuditLogs.new_values IS 'New values after change';
COMMENT ON COLUMN AuditLogs.success IS 'Whether the action was successful';
COMMENT ON COLUMN AuditLogs.error_message IS 'Error message if action failed';






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
CREATE INDEX idx_users_department ON Users(department);

-- Project indexes
CREATE INDEX idx_projects_status ON Projects(status);
CREATE INDEX idx_projects_priority ON Projects(priority);
CREATE INDEX idx_projects_owner_id ON Projects(owner_id);
CREATE INDEX idx_projects_team_lead_id ON Projects(team_lead_id);
CREATE INDEX idx_projects_active ON Projects(is_active);
CREATE INDEX idx_projects_start_date ON Projects(start_date);
CREATE INDEX idx_projects_end_date ON Projects(end_date);

-- Project API Keys indexes
CREATE INDEX idx_project_api_keys_project_id ON ProjectApiKeys(project_id);
CREATE INDEX idx_project_api_keys_active ON ProjectApiKeys(is_active);
CREATE INDEX idx_project_api_keys_expires_at ON ProjectApiKeys(expires_at);
CREATE INDEX idx_project_api_keys_created_by ON ProjectApiKeys(created_by);

-- Ticket indexes
CREATE INDEX idx_tickets_status ON Tickets(status);
CREATE INDEX idx_tickets_priority ON Tickets(priority);
CREATE INDEX idx_tickets_category ON Tickets(category);
CREATE INDEX idx_tickets_assigned_to ON Tickets(assigned_to);
CREATE INDEX idx_tickets_created_by ON Tickets(created_by);
CREATE INDEX idx_tickets_customer_email ON Tickets(customer_email);
CREATE INDEX idx_tickets_created_at ON Tickets(created_at);

-- Ticket Comments indexes
CREATE INDEX idx_ticket_comments_ticket_id ON TicketComments(ticket_id);
CREATE INDEX idx_ticket_comments_user_id ON TicketComments(user_id);
CREATE INDEX idx_ticket_comments_created_at ON TicketComments(created_at);

-- Billing indexes
CREATE INDEX idx_billing_customer_id ON Billing(customer_id);
CREATE INDEX idx_billing_customer_email ON Billing(customer_email);
CREATE INDEX idx_billing_status ON Billing(status);
CREATE INDEX idx_billing_plan_type ON Billing(plan_type);
CREATE INDEX idx_billing_due_date ON Billing(due_date);
CREATE INDEX idx_billing_paid_at ON Billing(paid_at);
CREATE INDEX idx_billing_created_at ON Billing(created_at);

-- System Logs indexes
CREATE INDEX idx_system_logs_level ON SystemLogs(level);
CREATE INDEX idx_system_logs_category ON SystemLogs(category);
CREATE INDEX idx_system_logs_user_id ON SystemLogs(user_id);
CREATE INDEX idx_system_logs_created_at ON SystemLogs(created_at);
CREATE INDEX idx_system_logs_request_id ON SystemLogs(request_id);
CREATE INDEX idx_system_logs_ip_address ON SystemLogs(ip_address);

-- Audit Logs indexes
CREATE INDEX idx_audit_logs_action ON AuditLogs(action);
CREATE INDEX idx_audit_logs_resource_type ON AuditLogs(resource_type);
CREATE INDEX idx_audit_logs_resource_id ON AuditLogs(resource_id);
CREATE INDEX idx_audit_logs_user_id ON AuditLogs(user_id);
CREATE INDEX idx_audit_logs_success ON AuditLogs(success);
CREATE INDEX idx_audit_logs_created_at ON AuditLogs(created_at);
CREATE INDEX idx_audit_logs_ip_address ON AuditLogs(ip_address);




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

-- Project triggers
CREATE TRIGGER update_projects_updated_at BEFORE UPDATE ON Projects
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_project_api_keys_updated_at BEFORE UPDATE ON ProjectApiKeys
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Ticket triggers
CREATE TRIGGER update_tickets_updated_at BEFORE UPDATE ON Tickets
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Billing triggers
CREATE TRIGGER update_billing_updated_at BEFORE UPDATE ON Billing
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();