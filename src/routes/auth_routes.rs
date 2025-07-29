
use rocket::serde::json::{Json, json, Value};
use crate::models::user::{UserLogin, UserRegister, User};
use rocket::State;
use rocket::http::Status;

use argon2::{
    password_hash:: {
        rand_core::OsRng,
        PasswordHash, PasswordHasher, PasswordVerifier, SaltString
    },
    Argon2
};

// use sqlx::PgPool;

use rocket_dyn_templates::{Template, context};

#[get("/login")]
pub fn login_page() -> Template {
    Template::render("auth/login", context!{})
}

#[post("/login", format="application/json", data="<user>")]
pub fn login(user: Json<UserLogin>) -> Result<Json<Value>, Status> {
    let user = user.into_inner();
}

#[get("/register")]
pub fn register_page() -> Template {
    Template::render("auth/register", context!{})
}

#[post("/register", format="application/json", data="<user>")]
pub async fn register(user: Json<UserRegister> ) -> Result<Json<Value>, Status> {
    let user = user.into_inner();

    // Validate Email Address
    if !user.email.contains('@') {
        return Err(Status::BadRequest)
    }

    // Validate password and username
    if user.username.trim().is_empty() || user.password.len() < 8 {
        return Err(Status::BadRequest);
    }

    // Check for Password Confirmation
    if user.password != user.confirm_password {
        return Err(Status::BadRequest);
    }

    // Generate Salt
    let salt = SaltString::generate(&mut OsRng);

    // Argon2 instance with default params
    let argon2 = Argon2::default();

    // Hash password to PHC string ($argon2id$v=19$...)
    let password_hash = match argon2.hash_password(user.password.as_bytes(), &salt) {
        Ok(hash) => hash.to_string(),
        Err(_) => return Err(Status::InternalServerError),
    };

    Ok(Json(json!({
        "message": format!("User {} registered successfully", user.username),
        "user": {
            "username": user.username,
            "email": user.email,
            "first_name": user.first_name,
            "last_name": user.last_name,
            "role": user.role
        }
    })))
}