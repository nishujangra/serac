use chrono::{DateTime, Utc};
use rocket::serde::{Serialize, Deserialize};

pub struct User {
    user_id: String,
    username: String,
    email: String,
    password_hash: String,
    first_name: String,
    last_name: String,
    is_active: bool,
    role: String,
    create_at: DateTime<Utc>,
    updated_at: DateTime<Utc>,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct UserLogin {
    pub username: String,
    pub email: String,
    pub password: String,
}

pub struct UserRegister {
    username: String,
    email: String,
    password: String,
    confirm_password: String,
    first_name: String,
    last_name: String,
    role: String,
}


pub fn check_role(user: User) -> String {
    return user.role
}

pub fn is_active_user(user: User) -> bool {
    return user.is_active == true
}