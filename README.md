# Serac

**Serac** is a Rust-native RBAC (Role-Based Access Control) system built with Rocket framework for managing fine-grained, privilege-based access with **speed**, **security**, and **clarity**. 

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

---

## 🛠️ Getting Started

### Prerequisites

- Rust (stable)
- PostgreSQL database
- Cargo package manager

### Configuration

Serac uses a configuration system with both JSON and environment variables:

#### 1. Database Configuration (`config.json`)

Create a `config.json` file in the project root:

```json
{
    "pg_database": {
        "host": "localhost",
        "port": "5432",
        "user": "postgres",
        "db": "serac"
    }
}
```

#### 2. Environment Variables (`.env`)

Create a `.env` file for sensitive configuration:

```bash
# Psql Database password for db
PG_PASSWORD=root

# JWT SECRET
JWT_SECRET='serac-secret-key'
```

#### 3. Configuration Priority

1. Environment variables (highest priority)
2. `config.json` file
3. Default values (lowest priority)

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

3. **Configure the application**
```bash
# Edit with your database credentials
nano config.json
nano .env
```

4. **Run the application**
```bash
cargo run
```

The server will start on `http://localhost:8000`

---

## 📚 Documentation

- **[Authentication API](docs/auth.md)** - Complete authentication endpoints documentation
- **[Database Schema](database.sql)** - PostgreSQL schema with RBAC + operational tables
- **[Sample Data](seed.sql)** - Example data and useful database views

---

## 🔌 API Endpoints

### Authentication Endpoints
- `POST /auth/register` - Register new user
- `POST /auth/login` - User login
- `POST /auth/logout` - User logout
- `POST /auth/refresh` - Refresh access token

### Response Format
All endpoints return JSON responses with appropriate HTTP status codes.

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
* [x] JWT authentication implementation
* [ ] Role-based middleware
* [ ] Web-based dashboard UI
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