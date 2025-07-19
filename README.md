# Serac

**Serac** is a Rust-native RBAC (Role-Based Access Control) system built with Rocket framework for managing fine-grained, privilege-based access with **speed**, **security**, and **clarity**. Designed specifically for startup internal operations and team management.

> 🎯 **Showcase Project**: This is built as a comprehensive demonstration of RBAC dashboard capabilities, showcasing how modern access control systems can be implemented with Rust for startup environments.

---

## 🎯 Project Purpose

Serac serves as a **real-world showcase** of RBAC (Role-Based Access Control) implementation, demonstrating:

- **Practical RBAC Design**: How to structure role hierarchies for startup teams
- **Fine-Grained Permissions**: Granular access control across multiple modules
- **Modern Tech Stack**: Rust + PostgreSQL for performance and reliability
- **Startup-Ready Features**: Real operational modules (Projects, Billing, Tickets, Logs)
- **Security Best Practices**: Audit logging, API key management, compliance tracking
- **Scalable Architecture**: Clean separation of concerns and extensible design

This project is ideal for:
- **Developers** learning RBAC implementation patterns
- **Startups** looking for access control solutions
- **Teams** evaluating Rust for backend development
- **Architects** studying modern security system design

---

## 🚀 Features

- ⚙️ **Fine-grained privilege control** with declarative policies
- 🧠 Built with **Rust + Rocket** for speed and safety
- 🗄️ **PostgreSQL** database with comprehensive RBAC schema
- 🔐 **User authentication** and role-based access control
- 📦 **RESTful API** endpoints for user and auth management
- 📜 Human-readable access rules, ideal for audits and versioning
- 🏢 **Startup-focused modules**: Projects, Billing, Tickets, Logs
- 👥 **Team management** with department organization
- 🔑 **API key management** for project integrations
- 📊 **Audit logging** for compliance and security
- 💰 **Billing management** for subscription tracking

---

## 📦 Tech Stack

- **Backend**: Rust (Rocket 0.5.1, Serde, Chrono)
- **Database**: PostgreSQL with comprehensive RBAC schema
- **API**: RESTful endpoints with JSON responses
- **Authentication**: Role-based access control system
- **Templates**: Tera templating engine with Tailwind CSS

---

## 📂 Project Structure

```bash
serac/
├── src/
│   ├── main.rs           # Rocket app entrypoint and route mounting
│   ├── models/
│   │   ├── mod.rs        # Model module exports
│   │   └── user.rs       # User data structures and utilities
│   └── routes/
│       ├── mod.rs        # Route module exports
│       ├── auth_routes.rs # Authentication endpoints
│       └── user_routes.rs # User management endpoints
├── database.sql          # PostgreSQL schema with RBAC + operational tables
├── seed.sql             # Sample data and useful views
├── Cargo.toml           # Rust dependencies
├── templates/           # Web interface templates
│   ├── base.html.tera   # Base template
│   ├── index.html.tera  # Landing page
│   └── _partials/       # Template partials
└── README.md
```

---

## 🗄️ Database Schema

The system uses a comprehensive PostgreSQL schema with the following core components:

### **RBAC Core Tables:**
- **Roles**: Hierarchical role definitions with privilege levels
- **PrivilegeCategory**: Organization of privileges (READ, WRITE, DELETE, etc.)
- **Privilege**: Specific permissions with categories and application mapping
- **Access**: Role-privilege mapping for RBAC enforcement
- **Users**: User accounts with role assignments and department tracking
- **Applications**: Application registry for privilege organization

### **Startup Operational Tables:**
- **Projects**: Internal project management with status, priority, and budget tracking
- **ProjectApiKeys**: API key management for project integrations
- **Tickets**: Support ticket management system with customer tracking
- **TicketComments**: Comments and updates on support tickets
- **Billing**: Subscription and billing management with payment tracking
- **SystemLogs**: Application and system logs for monitoring
- **AuditLogs**: Security and compliance audit logs

---

## 🏢 Startup Dashboard Modules

### **Project Management**
- Track internal projects with status, priority, and budget
- Manage project ownership and team assignments
- API key management for project integrations
- Project lifecycle management (Active, Paused, Completed, Cancelled)

### **Support System**
- Customer support ticket management
- Ticket categorization and priority levels
- Internal and external comment system
- Assignment and resolution tracking

### **Billing & Finance**
- Subscription and one-time payment tracking
- Customer billing management
- Payment status monitoring
- Invoice URL storage and management

### **Logging & Monitoring**
- System logs for application monitoring
- Security audit logs for compliance
- IP address and user agent tracking
- Request tracing for debugging

---

## 🛠️ Getting Started

### Prerequisites

- Rust (stable)
- PostgreSQL database
- Cargo package manager

### Setup

1. **Clone the repository**
```bash
git clone https://github.com/nishujangra/serac.git
cd serac
```

2. **Set up the database**
```bash
# Create database
createdb serac

# Run schema
psql -d serac -f database.sql

# (Optional) Add sample data
psql -d serac -f seed.sql
```

3. **Run the application**
```bash
cargo run
```

The server will start on `http://localhost:8000`

---

## 🔌 API Endpoints

### Core Endpoints
- `GET /` - Health check and status
- `GET /api/user` - Get user information
- `GET /auth/login` - Login endpoint

### Planned Endpoints
- `GET /api/projects` - Project management
- `GET /api/tickets` - Support ticket system
- `GET /api/billing` - Billing management
- `GET /api/logs` - System and audit logs

### Response Format
All endpoints return JSON responses with appropriate HTTP status codes.

---

## 👥 Team Roles

The system supports the following startup-focused roles:

- **ADMIN** (100): Full access to all system modules
- **DEVELOPER** (80): Can manage projects, API keys, and logs
- **SUPPORT_AGENT** (60): Can access user data and tickets
- **ANALYST** (40): Read-only access to logs and dashboards
- **FINANCE** (30): Billing access without dev/log access
- **GUEST** (10): Minimal dashboard access

---

## 💡 Philosophy

> Access control should be **clear**, **auditable**, and **minimal**.
> Serac helps startups enforce least privilege — cleanly and confidently.

---

## 📜 License

GPLv3 - See [LICENSE.md](LICENSE.md) for full details.

This project is licensed under the GNU General Public License v3.0, which means:
- ✅ You can use, modify, and distribute this software
- ✅ You must share any modifications under the same license
- ✅ You must provide source code when distributing
- 🔒 Any derivative works must also be open source

For more information about GPLv3, visit: https://www.gnu.org/licenses/gpl-3.0.html

---

## ✨ Naming

A **serac** is a sharp, unstable glacial formation — a metaphor for the delicate, high-stakes structure of privilege boundaries in fast-moving startups.

---

## 🧭 Roadmap

* [x] Basic Rocket server setup
* [x] PostgreSQL RBAC schema
* [x] User and auth route structure
* [x] Core data models
* [ ] Startup operational tables (Projects, Tickets, Billing, Logs)
* [ ] Team management with departments
* [ ] API key management system
* [ ] Audit logging framework
* [ ] Database connection and ORM integration
* [ ] JWT authentication implementation
* [ ] Role-based middleware
* [ ] Web-based dashboard UI
* [ ] API token support
* [ ] Rule versioning + audit logs
* [ ] Docker deployment
* [ ] OAuth integration
* [ ] Real-time notifications
* [ ] Advanced reporting and analytics

---

## 🔧 Development

### Adding New Routes
1. Create route handler in `src/routes/`
2. Add module to `src/routes/mod.rs`
3. Mount in `src/main.rs`

### Database Changes
- Update `database.sql` for schema changes
- Add migration scripts for production deployments

### Adding New Modules
1. Create table in `database.sql`
2. Add corresponding indexes for performance
3. Create model in `src/models/`
4. Add routes in `src/routes/`
5. Update privilege definitions in `seed.sql`

---

## 📊 Database Views

The system includes useful views for startup operations:

- **`active_users_view`**: All active team members with roles and departments
- **`role_privileges_view`**: Role hierarchy with privilege counts
- **`application_privileges_view`**: Privileges organized by dashboard modules

---

Made with 🦀 by [@nishujangra](https://github.com/nishujangra)