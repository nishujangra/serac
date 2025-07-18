# Serac

**Serac** is a Rust-native RBAC (Role-Based Access Control) system built with Rocket framework for managing fine-grained, privilege-based access with **speed**, **security**, and **clarity**.

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
├── database.sql          # PostgreSQL schema with RBAC tables
├── seed.sql             # Sample data and useful views
├── Cargo.toml           # Rust dependencies
└── README.md
```

---

## 🗄️ Database Schema

The system uses a comprehensive PostgreSQL schema with the following core tables:

- **Roles**: Hierarchical role definitions with privilege levels
- **PrivilegeCategory**: Organization of privileges (READ, WRITE, DELETE, etc.)
- **Privilege**: Specific permissions with categories and application mapping
- **Access**: Role-privilege mapping for RBAC enforcement
- **Users**: User accounts with role assignments
- **Applications**: Application registry for privilege organization

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

### Response Format
All endpoints return JSON responses with appropriate HTTP status codes.

---

## 💡 Philosophy

> Access control should be **clear**, **auditable**, and **minimal**.
> Serac helps you enforce least privilege — cleanly and confidently.

---

## 📜 License

MIT

---

## ✨ Naming

A **serac** is a sharp, unstable glacial formation — a metaphor for the delicate, high-stakes structure of privilege boundaries.

---

## 🧭 Roadmap

* [x] Basic Rocket server setup
* [x] PostgreSQL RBAC schema
* [x] User and auth route structure
* [x] Core data models
* [ ] Database connection and ORM integration
* [ ] JWT authentication implementation
* [ ] Role-based middleware
* [ ] Web-based dashboard UI
* [ ] API token support
* [ ] Rule versioning + audit logs
* [ ] Docker deployment
* [ ] OAuth integration

---

## 🔧 Development

### Adding New Routes
1. Create route handler in `src/routes/`
2. Add module to `src/routes/mod.rs`
3. Mount in `src/main.rs`

### Database Changes
- Update `database.sql` for schema changes
- Add migration scripts for production deployments

---

Made with 🦀 by [@nishujangra](https://github.com/nishujangra)