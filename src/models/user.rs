use rocket::serde::{Serialize, Deserialize};

#[derive(Serialize, Deserialize)]
pub struct User {
    pub user_id: String,
    pub username: String,
    pub email: String,
    pub password_hash: String,
    pub first_name: String,
    pub last_name: String,
    pub is_active: bool,
    pub role: String,
    pub department: Option<String>,
    pub created_at: i32,
    pub updated_at: i32,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct UserLogin {
    pub email: String,
    pub password: String,
}

#[derive(Deserialize)]
pub struct UserRegister {
    pub username: String,
    pub email: String,
    pub password: String,
    pub confirm_password: String,
    pub first_name: String,
    pub last_name: String,
    pub role: String,
}


pub fn check_role(user: User) -> String {
    return user.role
}

pub fn is_active_user(user: User) -> bool {
    return user.is_active == true
}