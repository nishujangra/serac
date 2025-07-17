# Serac

**Serac** is a Rust-native RBAC dashboard for managing fine-grained, privilege-based access with **speed**, **security**, and **clarity**.

---

## 🚀 Features

- ⚙️ **Fine-grained privilege control** with declarative policies
- 🧠 Built with **Rust + Rocket** for speed and safety
- 🖥️ Clean, minimal **web-based dashboard**
- 📦 Easily integrates with existing auth systems (JWT, OAuth, etc.)
- 📜 Human-readable access rules, ideal for audits and versioning

---

## 📦 Tech Stack

- **Rust** (Rocket, Serde, Diesel/SeaORM)
- **PostgreSQL** (or SQLite for development)
- **TailwindCSS** + **HTMX** or modern frontend (TBD)
- **Docker-ready** deployment (planned)

---

## 📂 Project Structure (WIP)

```bash
serac/
├── src/
│   ├── lib/           # Core RBAC logic
│   ├── routes/        # Rocket route handlers
│   └── main.rs        # App entrypoint
├── static/            # Assets (JS/CSS)
├── templates/         # HTML templates (if server-rendered)
├── Cargo.toml
└── README.md
````

---

## 🛠️ Getting Started (Dev)

```bash
git clone https://github.com/nishujangra/serac.git
cd serac
cargo run
```

Make sure you have:

* Rust (stable)
* PostgreSQL running

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

* [ ] Basic role/privilege UI
* [ ] API token support
* [ ] Rule versioning + audit logs
* [ ] Docker image
* [ ] OAuth/JWT integration

---

Made with 🦀 by [@nishujangra](https://github.com/nishujangra)