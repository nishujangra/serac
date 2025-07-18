-- =============================================================================
-- SAMPLE DATA INSERTION: STARTUP INTERNAL DASHBOARD
-- =============================================================================
\echo ** INSERTING SAMPLE DATA FOR STARTUP DASHBOARD **

-- Insert default roles
INSERT INTO Roles (role, level, description) VALUES
    ('ADMIN', 100, 'Full access to all system modules'),
    ('DEVELOPER', 80, 'Can manage projects, API keys, and logs'),
    ('SUPPORT_AGENT', 60, 'Can access user data and tickets'),
    ('ANALYST', 40, 'Read-only access to logs and dashboards'),
    ('FINANCE', 30, 'Billing access without dev/log access'),
    ('GUEST', 10, 'Minimal dashboard access')
ON CONFLICT (role) DO NOTHING;

-- Insert privilege categories
INSERT INTO PrivilegeCategory (category, description) VALUES
    ('READ', 'Read-only access'),
    ('WRITE', 'Write/create access'),
    ('DELETE', 'Delete access'),
    ('ADMIN', 'Administrative access'),
    ('MANAGE', 'Management and configuration access')
ON CONFLICT (category) DO NOTHING;

-- Insert applications
INSERT INTO Applications (appid, name, description, version) VALUES
    ('DASHBOARD', 'Startup Dashboard', 'Core interface for internal ops', '1.0.0'),
    ('USERS', 'User Management', 'View and manage users', '1.0.0'),
    ('PROJECTS', 'Project Manager', 'Internal project and API key system', '1.0.0'),
    ('TICKETS', 'Support System', 'Track support tickets', '1.0.0'),
    ('LOGS', 'Log Viewer', 'System and audit logs', '1.0.0'),
    ('BILLING', 'Billing Center', 'Billing and finance access', '1.0.0')
ON CONFLICT (appid) DO NOTHING;

-- Insert privileges
INSERT INTO Privilege (privilege, category, description, type, appid) VALUES
    ('/dashboard', 'READ', 'Access internal dashboard', 'URL', 'DASHBOARD'),
    
    ('/users', 'READ', 'View user list', 'URL', 'USERS'),
    ('/users/create', 'WRITE', 'Create new user', 'URL', 'USERS'),
    ('/users/edit', 'WRITE', 'Edit existing user', 'URL', 'USERS'),
    ('/users/delete', 'DELETE', 'Delete user', 'URL', 'USERS'),

    ('/projects', 'READ', 'View projects', 'URL', 'PROJECTS'),
    ('/projects/manage', 'MANAGE', 'Create/edit projects', 'URL', 'PROJECTS'),
    ('/projects/api_keys', 'MANAGE', 'Manage project API keys', 'URL', 'PROJECTS'),

    ('/tickets', 'READ', 'View support tickets', 'URL', 'TICKETS'),
    ('/tickets/respond', 'WRITE', 'Respond to tickets', 'URL', 'TICKETS'),

    ('/logs', 'READ', 'View system logs', 'URL', 'LOGS'),
    ('/logs/audit', 'READ', 'View audit logs', 'URL', 'LOGS'),

    ('/billing', 'READ', 'View billing dashboard', 'URL', 'BILLING'),
    ('/billing/manage', 'WRITE', 'Update billing settings', 'URL', 'BILLING')
ON CONFLICT (privilege) DO NOTHING;

-- Assign privileges to roles
INSERT INTO Access (privilege, role) VALUES
    -- ADMIN: Full access
    ('/dashboard', 'ADMIN'),
    ('/users', 'ADMIN'),
    ('/users/create', 'ADMIN'),
    ('/users/edit', 'ADMIN'),
    ('/users/delete', 'ADMIN'),
    ('/projects', 'ADMIN'),
    ('/projects/manage', 'ADMIN'),
    ('/projects/api_keys', 'ADMIN'),
    ('/tickets', 'ADMIN'),
    ('/tickets/respond', 'ADMIN'),
    ('/logs', 'ADMIN'),
    ('/logs/audit', 'ADMIN'),
    ('/billing', 'ADMIN'),
    ('/billing/manage', 'ADMIN'),

    -- DEVELOPER: Project and API access + logs
    ('/dashboard', 'DEVELOPER'),
    ('/projects', 'DEVELOPER'),
    ('/projects/manage', 'DEVELOPER'),
    ('/projects/api_keys', 'DEVELOPER'),
    ('/logs', 'DEVELOPER'),

    -- SUPPORT_AGENT: Limited user and ticket access
    ('/dashboard', 'SUPPORT_AGENT'),
    ('/users', 'SUPPORT_AGENT'),
    ('/tickets', 'SUPPORT_AGENT'),
    ('/tickets/respond', 'SUPPORT_AGENT'),
    ('/logs', 'SUPPORT_AGENT'),

    -- ANALYST: Read-only access
    ('/dashboard', 'ANALYST'),
    ('/logs', 'ANALYST'),
    ('/logs/audit', 'ANALYST'),

    -- FINANCE: Billing access only
    ('/dashboard', 'FINANCE'),
    ('/billing', 'FINANCE'),
    ('/billing/manage', 'FINANCE'),

    -- GUEST: Dashboard only
    ('/dashboard', 'GUEST')
ON CONFLICT (privilege, role) DO NOTHING;