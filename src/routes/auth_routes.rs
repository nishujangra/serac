use crate::models::user::{UserLogin, UserRegister, User};
use crate::utils::jwt::{generate_token};

use rocket::serde::json::{Json, json, Value};
use rocket::State;
use rocket::http::Status;


use chrono::{Utc};

use uuid::Uuid;

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

    Ok(Json(json!({
        "username": user.username,
        "password": user.password
    })))
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
    
    let now = Utc::now();

    let new_user = User {
        user_id: Uuid::new_v4().to_string(),
        username: user.username,
        email: user.email,
        password_hash,
        first_name: user.first_name,
        last_name: user.last_name,
        is_active: true,
        role: user.role,
        created_at: now,
        updated_at: now
    };

    // Generate JSON web token
    let token = match generate_token(new_user.user_id.clone(), new_user.role.clone()) {
        Ok(t) => t,
        Err(_) => return Err(Status::InternalServerError),
    };
    
    Ok(Json(json!({
        "message": "User registered successfully",
        "token": token,
        "user": {
            "user_id": new_user.user_id,
            "username": new_user.username,
            "email": new_user.email,
            "first_name": new_user.first_name,
            "last_name": new_user.last_name,
            "role": new_user.role,
            "created_at": new_user.created_at,
            "updated_at": new_user.updated_at
        }
    })))
}