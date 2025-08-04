use crate::models::user::{UserLogin, UserRegister, User};
use crate::utils::jwt::{generate_token};

use rocket::http::{Cookie, CookieJar, Status};
use rocket::serde::json::{Json, json, Value};
use rocket::State;


use chrono::{Utc};

use uuid::Uuid;

use argon2::{
    password_hash:: {
        rand_core::OsRng,
        PasswordHasher, SaltString
    },
    Argon2,
    PasswordVerifier,
    PasswordHash
};

use sqlx::PgPool;

use rocket_dyn_templates::{Template, context};

#[get("/login")]
pub fn login_page() -> Template {
    Template::render("auth/login", context!{})
}

#[post("/login", format="application/json", data="<user>")]
pub async fn login(user: Json<UserLogin>, db: &State<PgPool>) -> Result<Json<Value>, Status> {
    let user = user.into_inner();

    // Basic validations
    if !user.email.contains('@') || user.password.len() < 8 {
        return Err(Status::BadRequest);
    }

    // If user exists or not
    let user_exists = sqlx::query!(
        "SELECT * FROM users WHERE email = $1",
        user.email
    )
    .fetch_one(&**db)
    .await
    .map_err(|_| Status::Unauthorized)?;

    // Check password correct or not
    let db_hashed_password = user_exists.password_hash;
    let parsed_hash = match PasswordHash::new(&db_hashed_password) {
        Ok(hash) => hash,
        Err(_) => return Err(Status::InternalServerError),
    };

    let verifier = Argon2::default();
    if verifier.verify_password(user.password.as_bytes(), &parsed_hash).is_err() {
        return Err(Status::Unauthorized);
    }

    // generate token
    let token = match crate::utils::generate_token(row.user_id.clone(), row.role.clone()) {
        Ok(t) => t,
        Err(_) => return Err(Status::InternalServerError),
    };

    // save token to the cookie
    cookies.add(
        Cookie::build(("auth_token", token.clone()))
            .path("/")
            .http_only(true)
            .finish()
    );

    Ok(Json(json!({
        "email": user.email,
        "password": user.password,
        "token": token
    })))
}

#[get("/register")]
pub fn register_page() -> Template {
    Template::render("auth/register", context!{})
}

#[post("/register", format="application/json", data="<user>")]
pub async fn register<'r>(
    user: Json<UserRegister>, 
    db: &State<PgPool>, 
    cookies: &CookieJar<'r>
) -> Result<Json<Value>, Status> {
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

    // Check into DB for User
    let user_exists = sqlx::query_scalar!(
        "SELECT EXISTS(SELECT 1 FROM users WHERE username = $1)",
        user.username
    )
    .fetch_one(&**db)
    .await
    .unwrap_or(Some(false)) // If DB fails, assume username doesn't exist
    .unwrap_or(false);
    
    if user_exists {
        return Err(Status::Conflict); // HTTP 409
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
    
    let now_epoch: i32 = Utc::now().timestamp() as i32;

    let new_user = User {
        user_id: Uuid::new_v4().to_string(),
        username: user.username,
        email: user.email,
        password_hash,
        first_name: user.first_name,
        last_name: user.last_name,
        is_active: true,
        role: user.role,
        department: None, // Default to None for now
        created_at: now_epoch,
        updated_at: now_epoch
    };

    // Generate JSON web token
    let token = match generate_token(new_user.user_id.clone(), new_user.role.clone()) {
        Ok(t) => t,
        Err(_) => return Err(Status::InternalServerError),
    };

    // Store in secure, HttpOnly cookie
    cookies.add(
        Cookie::build(("auth_token", token.clone()))
            .path("/")
            .http_only(true)
            .finish()
    );

    // add user into DB
    sqlx::query!(
        "INSERT INTO users (
            user_id, username, email, password_hash, first_name, last_name, is_active, role, department, created_at, updated_at
        ) VALUES (
            $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11
        )",
        new_user.user_id,
        new_user.username,
        new_user.email,
        new_user.password_hash,
        new_user.first_name,
        new_user.last_name,
        new_user.is_active,
        new_user.role,
        new_user.department.as_deref(),
        new_user.created_at,
        new_user.updated_at
    )
    .execute(&**db)
    .await
    .unwrap();
    
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